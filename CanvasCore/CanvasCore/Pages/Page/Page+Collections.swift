//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit

import CoreData


import Marshal

extension Page {
    public static func collectionCacheKey(context: NSManagedObjectContext, contextID: ContextID) -> String {
        return cacheKey(context, [contextID.canvasContextID, "collection"])
    }

    public static func invalidateCache(session: Session, contextID: ContextID) throws {
        let context = try session.pagesManagedObjectContext()
        let key = collectionCacheKey(context: context, contextID: contextID)
        session.refreshScope.invalidateCache(key)
    }

    var routingUrl: URL {
        let path = contextID.apiPath + "/pages/" + url
        return URL(fileURLWithPath: path)
    }

    public static func predicate(_ contextID: ContextID) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == true", "contextID", contextID.canvasContextID, "published")
    }

    public static func collectionAlphabetical(_ session: Session, contextID: ContextID) throws -> FetchedCollection<Page> {
        let predicate = Page.predicate(contextID)
        let descriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        let context = try session.pagesManagedObjectContext()

        return try FetchedCollection(frc:
            context.fetchedResults(predicate, sortDescriptors: descriptors)
        )
    }

    public static func refresher(_ session: Session, contextID: ContextID) throws -> Refresher {
        let context = try session.pagesManagedObjectContext()

        let pages = try Page.getPages(session, contextID: contextID)
        let predicate = Page.predicate(contextID)
        let sync = Page.syncSignalProducer(predicate, inContext: context, fetchRemote: pages) { page, _ in
            page.contextID = contextID
        }
        let key = collectionCacheKey(context: context, contextID: contextID)

        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    // MARK: - Table View Controller

    open class TableViewController: CanvasCore.TableViewController, PageViewEventViewControllerLoggingProtocol {

        fileprivate (set) open var collection: FetchedCollection<Page>
        var route: (UIViewController, URL)->()
        fileprivate var contextID: ContextID

        public init(session: Session, contextID: ContextID, viewModelFactory: @escaping (Session, Page) -> ColorfulViewModel, route: @escaping (UIViewController, URL) -> ()) throws {
            self.route = route
            self.contextID = contextID
            self.collection = try Page.collectionAlphabetical(session, contextID: contextID)

            super.init()

            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44.0

            self.refresher = try Page.refresher(session, contextID: contextID)
            self.dataSource = CollectionTableViewDataSource(collection: collection) { page in viewModelFactory(session, page) }
        }

        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let page = collection[indexPath]

            route(self, page.routingUrl)
        }

        override open func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            startTrackingTimeOnViewController()
        }
        
        override open func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            let path = (contextID.apiPath + "/pages").pruneApiVersionFromPath()
            stopTrackingTimeOnViewController(eventName: path)
        }
    }

}
