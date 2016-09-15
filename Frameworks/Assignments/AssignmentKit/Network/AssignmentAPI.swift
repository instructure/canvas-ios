//
//  AssignmentAPI.swift
//  Assignments
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoLazy

public class AssignmentAPI {

    public class func getAssignments(session: Session, courseID: String) throws -> NSURLRequest {
        let path = "/api/v1/courses/\(courseID)/assignments"
        let parameters = Assignment.parameters
        
        return try session.GET(path, parameters: parameters)
    }

    public class func getAssignment(session: Session, courseID: String, assignmentID: String) throws -> NSURLRequest {
        let path = "/api/v1/courses/\(courseID)/assignments/\(assignmentID)"
        let parameters = Assignment.parameters
        
        return try session.GET(path, parameters: parameters)
    }

}

