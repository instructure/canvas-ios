//
//  Assignments.swift
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
import AssignmentKit

extension Assignment {
    public static func getAssignmentFromAirwolf(session: Session, studentID: String, courseID: String, assignmentID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/canvas/\(session.user.id)/\(studentID)/courses/\(courseID)/assignments/\(assignmentID)", parameters: Assignment.parameters)
        return session.JSONSignalProducer(request)
    }

    public static func refresher(session: Session, studentID: String, courseID: String, assignmentID: String) throws -> Refresher {
        let remote = try Assignment.getAssignmentFromAirwolf(session, studentID: studentID, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let context = try session.assignmentsManagedObjectContext(studentID)
        let sync = Assignment.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [studentID, courseID, assignmentID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, studentID: String, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Assignment> {
        let pred = predicate(courseID, assignmentID: assignmentID)
        let context = try session.assignmentsManagedObjectContext(studentID)
        return try ManagedObjectObserver<Assignment>(predicate: pred, inContext: context)
    }
}