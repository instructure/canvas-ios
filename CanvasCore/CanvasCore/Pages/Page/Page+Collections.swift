//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
