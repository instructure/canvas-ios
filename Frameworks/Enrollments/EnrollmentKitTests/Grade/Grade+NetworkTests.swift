//
//  Grade+NetworkTests.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/16/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

@testable import EnrollmentKit
import XCTest
import SoPersistent
import TooLegit
import DoNotShipThis
import Marshal
import SoAutomated

class GradeNetworkTests: XCTestCase {
    let session = Session.na_mgp

    func testGrade_getGrades_succeedsWithGradesResponse() {
        let response = getGrades("grades-list", gradingPeriodID: nil)

        guard let grades = response, grade = grades.first, innerGrades: JSONObject = try? grade <| "grades" where grades.count == 1 else {
            XCTFail("unexpected response")
            return
        }

        XCTAssert(grade.keys.contains("course_id"), "it has a course_id")
        XCTAssertFalse(grade.keys.contains("grading_period_id"))
        XCTAssert(innerGrades.keys.contains("current_grade"), "it has a current_grade")
        XCTAssert(innerGrades.keys.contains("current_score"), "it has a current_score")
        XCTAssert(innerGrades.keys.contains("final_grade"), "it has a final_grade")
        XCTAssert(innerGrades.keys.contains("final_score"), "it has a final_score")
    }

    func testGrade_getGrades_includesGradingPeriodID() {
        let response = getGrades("grading-period-grades-list", gradingPeriodID: "1")

        guard let grades = response, grade = grades.first where grades.count == 1 else {
            XCTFail("unexpected response")
            return
        }

        XCTAssert(grade.keys.contains("grading_period_id"), "it has a grading_period_id")
    }

    func testGrade_getGrades_whenLoggedInAsATeacher_doesNotIncludeGrades() {
        let response = getGradesAsATeacher()

        guard let grade = response.first else {
            XCTFail("expected a grade")
            return
        }

        XCTAssertFalse(grade.keys.contains("grade"), "it does not include grades")
    }

    private func getGrades(fixture: Fixture, gradingPeriodID: String?) -> [JSONObject]? {
        var response: [JSONObject]?

        stub(session, fixture) { expectation in
            try Grade.getGrades(session, courseID: "1", gradingPeriodID: gradingPeriodID).startWithCompletedExpectation(expectation) { value in
                response = value
            }
        }

        return response
    }

    private func getGradesAsATeacher() -> [JSONObject] {
        var response: [JSONObject] = []
        let session = Session.teacher

        attempt {
            stub(session, "teacher-grades-list") { expectation in
                try Grade.getGrades(session, courseID: "1867097", gradingPeriodID: nil).startWithCompletedExpectation(expectation) { value in
                    response = value
                }
            }
        }

        return response
    }
}
