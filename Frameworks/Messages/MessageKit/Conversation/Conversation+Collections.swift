//
//  Conversation+Collections.swift
//  Messages
//
//  Created by Nathan Armstrong on 6/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoPersistent
import ReactiveCocoa
import CoreData

extension Conversation {
    public static func collection(session: Session) throws -> FetchedCollection<Conversation> {
        let context = try session.messagesManagedObjectContext()
        let frc = fetchedResults(nil, sortDescriptors: ["workflowState".descending, "date".descending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }

    public static func syncSignalProducer(session: Session) throws -> SignalProducer<Void, NSError> {
        let context = try session.messagesManagedObjectContext()
        let remote = try getConversations(session)
        return syncSignalProducer(inContext: context, fetchRemote: remote).map { _ in () }
    }

    public static func refresher(session: Session) throws -> Refresher {
        let context = try session.messagesManagedObjectContext()
        let sync = try syncSignalProducer(session)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: cacheKey(context))
    }

    public class TableViewController: SoPersistent.TableViewController {

        public override func viewDidLoad() {
            super.viewDidLoad()
            tableView.estimatedRowHeight = 44
        }

        public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<Conversation>, refresher: Refresher?, viewModelFactory: Conversation->VM) {
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
    }
}
