//
//  GradeAPI.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/16/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import TooLegit

public class GradeAPI {
    public class func getGrades(session: Session, courseID: String, gradingPeriodID: String?) throws -> NSURLRequest {
        let path = api/v1/"courses/\(courseID)/enrollments"
        let parameters = Session.rejectNilParameters([
            "user_id": "self",
            "grading_period_id": gradingPeriodID,
            "enrollment_type": "student"
        ])

        return try session.GET(path, parameters: parameters)
    }
}
