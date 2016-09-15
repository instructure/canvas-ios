//
//  Page+Collections.swift
//  Pages
//
//  Created by Joseph Davison on 5/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import Marshal

extension Page {

    var routingUrl: NSURL {
        let path = contextID.apiPath + "/pages/" + url
        return NSURL(fileURLWithPath: path)
    }

    public static func predicate(contextID: ContextID) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K = %@", "contextID", contextID.canvasContextID, "published", true)
    }

    public static func collectionAlphabetical(session: Session, contextID: ContextID) throws -> FetchedCollection<Page> {
        let predicate = Page.predicate(contextID)
        let descriptors = [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))]
        let context = try session.pagesManagedObjectContext()
        let frc = Page.fetchedResults(predicate, sortDescriptors: descriptors, sectionNameKeypath: nil, inContext: context)

        return try FetchedCollection(frc: frc)
    }

    public static func refresher(session: Session, contextID: ContextID) throws -> Refresher {
        let context = try session.pagesManagedObjectContext()

        let pages = try Page.getPages(session, contextID: contextID)
        let predicate = Page.predicate(contextID)
        let sync = Page.syncSignalProducer(predicate, inContext: context, fetchRemote: pages) {
            page, _ in
            page.contextID = contextID
        }
        let key = cacheKey(context, [contextID.canvasContextID, "collection"])

        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    // MARK: - Table View Controller

    public class TableViewController: SoPersistent.TableViewController {

        private (set) public var collection: FetchedCollection<Page>
        var route: (UIViewController, NSURL)->()

        public init(session: Session, contextID: ContextID, viewModelFactory: (Session, Page) -> ColorfulViewModel, route: (UIViewController, NSURL) -> ()) throws {
            self.route = route
            self.collection = try Page.collectionAlphabetical(session, contextID: contextID)

            super.init()

            self.refresher = try Page.refresher(session, contextID: contextID)
            self.dataSource = CollectionTableViewDataSource(collection: collection) { page in viewModelFactory(session, page) }
        }

        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            let page = collection[indexPath]

            route(self, page.routingUrl)
        }

        override public func viewDidLoad() {
            super.viewDidLoad()
            refresher!.refresh(false)
        }

    }

}
