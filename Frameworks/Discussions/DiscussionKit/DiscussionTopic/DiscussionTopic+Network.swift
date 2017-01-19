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
