//
//  GradingPeriodAPI.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit

public class GradingPeriodAPI {
    public class func getGradingPeriods(session: Session, courseID: String) throws -> NSURLRequest {
        let path = "/api/v1/courses/\(courseID)/grading_periods"
        return try session.GET(path)
    }
}
