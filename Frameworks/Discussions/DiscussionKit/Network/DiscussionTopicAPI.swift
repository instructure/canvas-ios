//
//  DiscussionTopicAPI.swift
//  Discussions
//
//  Created by Ben Kraus on 3/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoLazy
import TooLegit

public class DiscussionTopicAPI {

    public class func getDiscussionTopic(session: Session, courseID: String, discussionTopicID: String) throws -> NSURLRequest {
        let path = "/api/v1/courses/\(courseID)/discussion_topics/\(discussionTopicID)"
        return try session.GET(path)
    }

    public class func getDiscussionTopics(session: Session, courseID: String) throws -> NSURLRequest {
        let path = "/api/v1/courses/\(courseID)/discussion_topics"
        return try session.GET(path)
    }
    
    public class func getDiscussionTopicView(session: Session, contextID: ContextID, topicID: String) throws -> NSURLRequest {
        let path = contextID.apiPath / "discussion_topics" / topicID / "view"
        return try session.GET(path)
    }
}
