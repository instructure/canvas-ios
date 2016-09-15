//
//  Assignment+Network.swift
//  Assignments
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import Marshal

extension Assignment {
    static func getAssignments(session: Session, courseID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AssignmentAPI.getAssignments(session, courseID: courseID)

        return session.paginatedJSONSignalProducer(request)
    }

    static func getAssignment(session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AssignmentAPI.getAssignment(session, courseID: courseID, assignmentID: assignmentID)

        return session.JSONSignalProducer(request)
    }
}