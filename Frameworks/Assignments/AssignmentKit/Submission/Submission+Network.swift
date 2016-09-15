//
//  Submission+Network.swift
//  Assignments
//
//  Created by Nathan Lambson on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import Marshal

extension Submission {
    static func getSubmission(session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try SubmissionAPI.getSubmission(session, courseID: courseID, assignmentID: assignmentID)
        
        return session.JSONSignalProducer(request)
    }
}