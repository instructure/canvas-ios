//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import Marshal
import ReactiveSwift
import CanvasCore
import Core

extension DiscussionTopic {
    public static func getDiscussionTopic(_ session: Session, courseID: String, discussionTopicID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try DiscussionTopicAPI.getDiscussionTopic(session, courseID: courseID, discussionTopicID: discussionTopicID)
        return session.JSONSignalProducer(request)
    }

    public static func getDiscussionTopics(_ session: Session, courseID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try DiscussionTopicAPI.getDiscussionTopics(session, courseID: courseID)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func getDiscussionTopicView(_ session: Session, contextID: Context, topicID: String) -> SignalProducer<JSONObject, NSError> {
        return attemptProducer {
            try DiscussionTopicAPI.getDiscussionTopicView(session, contextID: contextID, topicID: topicID)
            }.flatMap(.latest, session.JSONSignalProducer)
    }
}
