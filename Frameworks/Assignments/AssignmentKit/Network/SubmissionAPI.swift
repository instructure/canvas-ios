//
//  SubmissionAPI.swift
//  Assignments
//
//  Created by Nathan Lambson on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoLazy

public class SubmissionAPI {
    
    public class func getSubmission(session: Session, courseID: String, assignmentID: String) throws -> NSURLRequest {
        let path = "/api/v1/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(session.user.id)"
        let parameters = Submission.parameters
        
        return try session.GET(path, parameters: parameters)
    }
    
}   