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
import SoLazy
import TooLegit

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
