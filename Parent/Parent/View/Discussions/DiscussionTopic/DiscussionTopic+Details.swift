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



import Foundation


import CoreData
import ReactiveSwift


extension DiscussionTopic {
    public static func predicate(_ discussionTopicID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", discussionTopicID)
    }

    public static func refresher(_ session: Session, courseID: String, discussionTopicID: String) throws -> Refresher {
        let context = try session.discussionsManagedObjectContext()
        let remote = try DiscussionTopic.getDiscussionTopic(session, courseID: courseID, discussionTopicID: discussionTopicID).map { [$0] }
        let pred = predicate(discussionTopicID)
        let sync = DiscussionTopic.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
        let key = cacheKey(context, [courseID, discussionTopicID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, courseID: String, discussionTopicID: String) throws -> ManagedObjectObserver<DiscussionTopic> {
        let pred = predicate(discussionTopicID)
        let context = try session.discussionsManagedObjectContext()
        return try ManagedObjectObserver<DiscussionTopic>(predicate: pred, inContext: context)
    }

    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel>(_ session: Session, courseID: String, discussionTopicID: String, detailsFactory: @escaping (DiscussionTopic)->[DVM]) throws -> TableViewDataSource where DVM: Equatable {
        let obs = try observer(session, courseID: courseID, discussionTopicID: discussionTopicID)
        let collection = FetchedDetailsCollection<DiscussionTopic, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }

    open class DetailViewController: TableViewController {
        open func prepare<DVM: TableViewCellViewModel>(_ observer: ManagedObjectObserver<DiscussionTopic>, refresher: Refresher? = nil, detailsFactory: @escaping (DiscussionTopic)->[DVM]) where DVM: Equatable {
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}


