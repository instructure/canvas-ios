//
//  DiscussionTopic+Details.swift
//  Discussions
//
//  Created by Ben Kraus on 3/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoPersistent
import CoreData
import ReactiveCocoa


extension DiscussionTopic {
    public static func predicate(discussionTopicID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", discussionTopicID)
    }

    public static func refresher(session: Session, courseID: String, discussionTopicID: String) throws -> Refresher {
        let context = try session.discussionsManagedObjectContext()
        let remote = try DiscussionTopic.getDiscussionTopic(session, courseID: courseID, discussionTopicID: discussionTopicID).map { [$0] }
        let pred = predicate(discussionTopicID)
        let sync = DiscussionTopic.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
        let key = cacheKey(context, [courseID, discussionTopicID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, courseID: String, discussionTopicID: String) throws -> ManagedObjectObserver<DiscussionTopic> {
        let pred = predicate(discussionTopicID)
        let context = try session.discussionsManagedObjectContext()
        return try ManagedObjectObserver<DiscussionTopic>(predicate: pred, inContext: context)
    }

    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel where DVM: Equatable>(session: Session, courseID: String, discussionTopicID: String, detailsFactory: DiscussionTopic->[DVM]) throws -> TableViewDataSource {
        let obs = try observer(session, courseID: courseID, discussionTopicID: discussionTopicID)
        let collection = FetchedDetailsCollection<DiscussionTopic, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }

    public class DetailViewController: TableViewController {
        private (set) public var observer: ManagedObjectObserver<DiscussionTopic>!

        public func prepare<DVM: TableViewCellViewModel where DVM: Equatable>(observer: ManagedObjectObserver<DiscussionTopic>, refresher: Refresher? = nil, detailsFactory: DiscussionTopic->[DVM]) {
            self.observer = observer
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}