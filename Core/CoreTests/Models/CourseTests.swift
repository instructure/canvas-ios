//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core

class CourseTests: CoreTestCase {
    func testColor() {
        let a = Course.make()
        _ = Color.make()

        XCTAssertEqual(a.color, UIColor.red)
    }

    func testDefaultView() {
        let expected = CourseDefaultView.assignments
        let a = Course.make()
        a.defaultView = expected

        XCTAssertEqual(a.defaultView, expected)
    }

    func testEnrollmentRelationship() {
        let a = Course.make()
        let enrollment = Enrollment.make(course: a)
        a.enrollments = [enrollment]

        let pred = NSPredicate(format: "%K == %@", #keyPath(Course.id), a.id)
        let list: [Course] = databaseClient.fetch(pred, sortDescriptors: nil)
        let result = list.first
        let resultEnrollment = result?.enrollments?.first

        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.enrollments)
        XCTAssertNotNil(resultEnrollment)
        XCTAssertEqual(resultEnrollment?.canvasContextID, "course_1")
    }

    func testWidgetDisplayGradeNoEnrollments() {
        let c = Course.make(from: .make(enrollments: nil))
        XCTAssertEqual(c.displayGrade, "")
    }

    func testWidgetDisplayGradeNoStudentEnrollments() {
        let c = Course.make(from: .make(enrollments: [.make(role: "TeacherEnrollment")]))
        XCTAssertEqual(c.displayGrade, "")
    }

    func testWidgetDisplayGradeScore() {
        let c = Course.make(from: .make(enrollments: [.make(computed_current_score: 40.05)]))
        XCTAssertEqual(c.displayGrade, "40.05%")
    }

    func testWidgetDisplayGradeScoreAndGrade() {
        let c = Course.make(from: .make(enrollments: [ .make(
            computed_current_score: 40.05,
            computed_current_grade: "F-"
        ), ]))
        XCTAssertEqual(c.displayGrade, "40.05% - F-")
    }

    func testWidgetDisplayGradeNoScoreWithGrade() {
        let c = Course.make(from: .make(enrollments: [ .make(
            computed_current_score: nil,
            computed_current_grade: "B+"
        ), ]))
        XCTAssertEqual(c.displayGrade, "B+")
    }

    func testWidgetDisplayGradeNoScoreNoGrade() {
        let c = Course.make(from: .make(enrollments: [ .make(
            computed_current_score: nil,
            computed_current_grade: nil
        ), ]))
        XCTAssertEqual(c.displayGrade, "N/A")
    }

    func testWidgetDisplayGradeInCurrentMGP() {
        let c = Course.make(from: .make(enrollments: [ .make(
            multiple_grading_periods_enabled: true,
            current_grading_period_id: "1",
            current_period_computed_current_score: 90,
            current_period_computed_current_grade: "A-"
        ), ]))
        XCTAssertEqual(c.displayGrade, "90% - A-")
    }

    func testWidgetDisplayGradeNotInCurrentMGPWithTotals() {
        let c = Course.make(from: .make(enrollments: [ .make(
            computed_final_score: 85,
            computed_final_grade: "B",
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: true,
            current_grading_period_id: nil
        ), ]))
        XCTAssertEqual(c.displayGrade, "85% - B")
    }

    func testWidgetDisplayGradeNotInCurrentMGPWithoutTotals() {
        let c = Course.make(from: .make(enrollments: [ .make(
            multiple_grading_periods_enabled: true,
            totals_for_all_grading_periods_option: false,
            current_grading_period_id: nil
        ), ]))
        XCTAssertEqual(c.displayGrade, "N/A")
    }

    func testShowColorOverlay() {
        let c = Course.make(from: .make(image_download_url: nil))
        XCTAssertTrue(c.showColorOverlay(hideOverlaySetting: false))

        c.imageDownloadURL = URL(string: "https://google.com")!
        XCTAssertFalse(c.showColorOverlay(hideOverlaySetting: true))
        XCTAssertTrue(c.showColorOverlay(hideOverlaySetting: false))
    }
}
