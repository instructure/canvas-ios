//
//  DiscussionTopic+Network.swift
//  Discussions
//
//  Created by Ben Kraus on 3/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import Marshal
import ReactiveCocoa

extension DiscussionTopic {
    public static func getDiscussionTopic(session: Session, courseID: String, discussionTopicID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try DiscussionTopicAPI.getDiscussionTopic(session, courseID: courseID, discussionTopicID: discussionTopicID)
        return session.JSONSignalProducer(request)
    }

    public static func getDiscussionTopics(session: Session, courseID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try DiscussionTopicAPI.getDiscussionTopics(session, courseID: courseID)
        return session.paginatedJSONSignalProducer(request)
    }
}