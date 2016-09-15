//
//  GradeAPITests.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/20/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import EnrollmentKit

class GradeAPITests: XCTestCase {
    let session = Session.art

    func testGradeAPI_getGrades_setsCourseIDInURL() {
        let request = try! GradeAPI.getGrades(session, courseID: "1", gradingPeriodID: nil)
        XCTAssertEqual("/api/v1/courses/1/enrollments", request.URL?.relativePath, "it should have the correct path")
    }

    func testGradeAPI_getGrades_parametersWhenGradingPeriodIDIsNil() {
        let request = try! GradeAPI.getGrades(session, courseID: "1", gradingPeriodID: nil)
        XCTAssertEqual("enrollment_type=student&per_page=99&user_id=self", request.URL?.query, "it should have the correct parameters")
    }

    func testGradeAPI_getGrades_parametersWhenGradingPeriodIDIsNotNil() {
        let request = try! GradeAPI.getGrades(session, courseID: "1", gradingPeriodID: "1")
        XCTAssertEqual("enrollment_type=student&grading_period_id=1&per_page=99&user_id=self", request.URL?.query, "it should have the correct parameters")
    }
}
