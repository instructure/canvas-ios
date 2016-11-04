
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