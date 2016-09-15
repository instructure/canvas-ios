//
//  AssignmentGroupAPI.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit

public class AssignmentGroupAPI {

    public class func getAssignmentGroups(session: Session, courseID: String, gradingPeriodID: String? = nil) throws -> NSURLRequest {
        let path = "/api/v1/courses/\(courseID)/assignment_groups"

        var parameters = Assignment.parameters
        var include = parameters["include"] as? [String] ?? []

        if let gradingPeriodID = gradingPeriodID {
            parameters["grading_period_id"] = gradingPeriodID
            parameters["scope_assignments_to_student"] = true // ignored by server if user is not a student
            include.append("assignments")
        }

        parameters["include"] = include

        return try session.GET(path, parameters: parameters)
    }

}