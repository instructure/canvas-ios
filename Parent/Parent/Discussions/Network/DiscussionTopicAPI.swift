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
import CanvasCore
import Core

open class DiscussionTopicAPI {

    open class func getDiscussionTopic(_ session: Session, courseID: String, discussionTopicID: String) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/discussion_topics/\(discussionTopicID)"
        return try session.GET(path)
    }

    open class func getDiscussionTopics(_ session: Session, courseID: String) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/discussion_topics"
        return try session.GET(path)
    }

    open class func getDiscussionTopicView(_ session: Session, contextID: Context, topicID: String) throws -> URLRequest {
        let path = "/api/v1/\(contextID.pathComponent)/discussion_topics/\(topicID)/view"
        return try session.GET(path)
    }
}
