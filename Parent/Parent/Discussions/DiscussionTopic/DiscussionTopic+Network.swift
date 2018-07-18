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

import Marshal
import ReactiveSwift

extension DiscussionTopic {
    public static func getDiscussionTopic(_ session: Session, courseID: String, discussionTopicID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try DiscussionTopicAPI.getDiscussionTopic(session, courseID: courseID, discussionTopicID: discussionTopicID)
        return session.JSONSignalProducer(request)
    }

    public static func getDiscussionTopics(_ session: Session, courseID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try DiscussionTopicAPI.getDiscussionTopics(session, courseID: courseID)
        return session.paginatedJSONSignalProducer(request)
    }
    
    public static func getDiscussionTopicView(_ session: Session, contextID: ContextID, topicID: String) -> SignalProducer<JSONObject, NSError> {
        return attemptProducer {
            try DiscussionTopicAPI.getDiscussionTopicView(session, contextID: contextID, topicID: topicID)
            }.flatMap(.latest, transform: session.JSONSignalProducer)
    }
}
