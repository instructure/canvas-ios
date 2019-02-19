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



open class DiscussionTopicAPI {

    open class func getDiscussionTopic(_ session: Session, courseID: String, discussionTopicID: String) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/discussion_topics/\(discussionTopicID)"
        return try session.GET(path)
    }

    open class func getDiscussionTopics(_ session: Session, courseID: String) throws -> URLRequest {
        let path = "/api/v1/courses/\(courseID)/discussion_topics"
        return try session.GET(path)
    }
    
    open class func getDiscussionTopicView(_ session: Session, contextID: ContextID, topicID: String) throws -> URLRequest {
        let path = contextID.apiPath / "discussion_topics" / topicID / "view"
        return try session.GET(path)
    }
}
