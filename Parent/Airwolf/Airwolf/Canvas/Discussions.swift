//
//  Discussions.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/19/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import SoPersistent
import ReactiveCocoa
import Marshal
import DiscussionKit

extension DiscussionTopic {
    public static func getDiscussionTopicFromAirwolf(session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/courses/\(courseID)/discussion_topics/\(discussionTopicID)")
        return session.JSONSignalProducer(request)
    }

    public static func refresher(session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> Refresher {
        let remote = try DiscussionTopic.getDiscussionTopicFromAirwolf(session, studentID: studentID, courseID: courseID, discussionTopicID: discussionTopicID).map { [$0] }
        let context = try session.discussionsManagedObjectContext(studentID)
        let sync = DiscussionTopic.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [courseID, discussionTopicID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, studentID: String, courseID: String, discussionTopicID: String) throws -> ManagedObjectObserver<DiscussionTopic> {
        let pred = predicate(discussionTopicID)
        let context = try session.discussionsManagedObjectContext(studentID)
        return try ManagedObjectObserver<DiscussionTopic>(predicate: pred, inContext: context)
    }
}