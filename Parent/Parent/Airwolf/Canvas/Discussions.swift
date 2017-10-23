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


import ReactiveSwift
import Marshal
import CanvasCore

extension DiscussionTopic {
    public static func getDiscussionTopicFromAirwolf(_ session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/courses/\(courseID)/discussion_topics/\(discussionTopicID)")
        return session.JSONSignalProducer(request)
    }

    public static func refresher(_ session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> Refresher {
        let remote = try DiscussionTopic.getDiscussionTopicFromAirwolf(session, studentID: studentID, courseID: courseID, discussionTopicID: discussionTopicID).map { [$0] }
        let context = try session.discussionsManagedObjectContext(studentID)
        let sync = DiscussionTopic.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [courseID, discussionTopicID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(_ session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> ManagedObjectObserver<DiscussionTopic> {
        let pred = predicate(discussionTopicID)
        let context = try session.discussionsManagedObjectContext(studentID)
        return try ManagedObjectObserver<DiscussionTopic>(predicate: pred, inContext: context)
    }
}
