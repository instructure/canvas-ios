//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Core
@testable import Parent
import XCTest

class CourseListCellGradesTests: ParentTestCase {
    private let testee = CourseListCell()

    func testNoCourse() {
        XCTAssertEqual(testee.displayGrade(nil, studentID: "12"), "")
    }

    func testNoEnrollment() {
        var course = Course.make(from: .make(enrollments: nil))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "")

        course = Course.make(from: .make(enrollments: []))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "")
    }

    func testNoEnrollmentWhenQuantitativeDataEnabled() {
        var course = Course.make(from: .make(enrollments: nil, settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "")

        course = Course.make(from: .make(enrollments: [], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "")
    }

    func testHideGradesWithHideFinalGrades() {
        let course = Course.make(from: .make(hide_final_grades: true))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "")
    }

    func testHideGradesWithHideFinalGradesWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(hide_final_grades: true, settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "")
    }

    func testHideGradesWithoutHidingFinalGrades() {
        let course = Course.make(from: .make(enrollments: [.make(
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: false,
            current_grading_period_id: nil),
        ], hide_final_grades: false))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "N/A")
    }

    func testHideGradesWithoutHidingFinalGradesWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: false,
            current_grading_period_id: nil),
        ], hide_final_grades: false, settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "N/A")
    }

    // MARK: - Single Grading Period

    func testNoScoreNoGrade() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: nil,
            computed_current_grade: nil,
            multiple_grading_periods_enabled: false),
        ]))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "No Grade")
    }

    func testNoScoreNoGradeWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: nil,
            computed_current_grade: nil,
            multiple_grading_periods_enabled: false),
        ], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "No Grade")
    }

    func testNoScoreWithGrade() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: nil,
            computed_current_grade: "F",
            multiple_grading_periods_enabled: false),
        ]))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "F")
    }

    func testNoScoreWithGradeWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: nil,
            computed_current_grade: "F",
            multiple_grading_periods_enabled: false),
        ], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "F")
    }

    func testScoreWithoutGrade() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: 40,
            computed_current_grade: nil,
            multiple_grading_periods_enabled: false),
        ]))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "40%")
    }

    func testScoreWithoutGradeWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: 40,
            computed_current_grade: nil,
            multiple_grading_periods_enabled: false),
        ], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "N/A")
    }

    func testScoreWithGrade() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: 40,
            computed_current_grade: "C",
            multiple_grading_periods_enabled: false),
        ]))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "C   40%")
    }

    func testScoreWithGradeWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: 40,
            computed_current_grade: "C",
            multiple_grading_periods_enabled: false),
        ], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "C")
    }

    // MARK: - Multiple Grading Periods

    func testActiveGradingPeriodScoreWithGrade() {
        let course = Course.make(from: .make(enrollments: [.make(
            multiple_grading_periods_enabled: true,
            current_period_computed_current_score: 40,
            current_period_computed_current_grade: "C"),
        ]))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "C   40%")
    }

    func testActiveGradingPeriodScoreWithGradeWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            multiple_grading_periods_enabled: true,
            current_period_computed_current_score: 40,
            current_period_computed_current_grade: "C"),
        ], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "C")
    }

    func testNoActiveGradingPeriodWithTotalsForAllGradingPeriodsOptionScoreWithGrade() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: 40,
            computed_current_grade: "C",
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: true,
            current_grading_period_id: nil),
        ]))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "C   40%")
    }

    func testNoActiveGradingPeriodWithTotalsForAllGradingPeriodsOptionScoreWithGradeWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            computed_current_score: 40,
            computed_current_grade: "C",
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: true,
            current_grading_period_id: nil),
        ], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "C")
    }

    func testNoActiveGradingPeriodWithoutTotalsForAllGradingPeriodsOption() {
        let course = Course.make(from: .make(enrollments: [.make(
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: false,
            current_grading_period_id: nil),
        ]))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "N/A")
    }

    func testNoActiveGradingPeriodWithoutTotalsForAllGradingPeriodsOptionWhenQuantitativeDataEnabled() {
        let course = Course.make(from: .make(enrollments: [.make(
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: false,
            current_grading_period_id: nil),
        ], settings: .make(restrict_quantitative_data: true)))
        XCTAssertEqual(testee.displayGrade(course, studentID: "12"), "N/A")
    }
}
