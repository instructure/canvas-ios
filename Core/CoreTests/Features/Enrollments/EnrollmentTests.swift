//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import XCTest
@testable import Core

class EnrollmentTests: CoreTestCase {
    func testEnrollmentStateInitRawValue() {
        let enrollment = Enrollment.make(from: .make(enrollment_state: .invited))
        XCTAssertEqual(enrollment.state, .invited)
        enrollment.state = .active
        XCTAssertEqual(enrollment.stateRaw, EnrollmentState.active.rawValue)
        enrollment.stateRaw = nil
        XCTAssertEqual(enrollment.state, .inactive)
    }

    func testUpdateFromCourseAPI() {
        let apiEnrollment = APIEnrollment.make(
            computed_current_score: 10,
            current_grading_period_id: "1",
            current_period_computed_current_score: 20
        )

        let course = Course.make(from: .make(id: "1", enrollments: [apiEnrollment]))
        let model: Enrollment = databaseClient.insert()
        model.update(fromApiModel: apiEnrollment, course: course, in: databaseClient)

        XCTAssertEqual(model.role, "StudentEnrollment")
        XCTAssertEqual(model.roleID, apiEnrollment.role_id)
        XCTAssertEqual(model.state, apiEnrollment.enrollment_state)
        XCTAssertEqual(model.userID, apiEnrollment.user_id.value)
        XCTAssertEqual(model.multipleGradingPeriodsEnabled, apiEnrollment.multiple_grading_periods_enabled)
        XCTAssertEqual(model.computedCurrentScore, apiEnrollment.computed_current_score)
        XCTAssertEqual(model.computedFinalScore, apiEnrollment.computed_final_score)
        XCTAssertEqual(model.currentPeriodComputedCurrentScore, apiEnrollment.current_period_computed_current_score)
        XCTAssertEqual(model.currentPeriodComputedFinalScore, apiEnrollment.current_period_computed_final_score)
        XCTAssertEqual(model.canvasContextID, "course_1")
        XCTAssertEqual(model.grades.count, 2)
        let allGrades = model.grades.first { $0.gradingPeriodID == nil }
        XCTAssertNotNil(allGrades)
        XCTAssertEqual(allGrades?.currentScore, 10)
        let current = model.grades.first { $0.gradingPeriodID == "1" }
        XCTAssertNotNil(current)
        XCTAssertEqual(current?.currentScore, 20)
    }

    func testUpdateFromEnrollmentsAPI() {
        let apiEnrollment = APIEnrollment.make(
            id: "1",
            course_id: "4",
            enrollment_state: .active,
            type: "StudentEnrollment",
            user_id: "3",
            role: "StudentEnrollment",
            role_id: "2",
            grades: APIEnrollment.Grades(
                html_url: "/grades",
                current_grade: "A",
                final_grade: "F",
                current_score: 100,
                final_score: 50,
                override_grade: nil,
                override_score: nil,
                unposted_current_grade: nil,
                unposted_current_score: nil
            )
        )
        let enrollment: Enrollment = databaseClient.insert()
        enrollment.update(fromApiModel: apiEnrollment, course: nil, gradingPeriodID: nil, in: databaseClient)
        XCTAssertEqual(enrollment.id, "1")
        XCTAssertEqual(enrollment.role, "StudentEnrollment")
        XCTAssertEqual(enrollment.roleID, "2")
        XCTAssertEqual(enrollment.state, .active)
        XCTAssertEqual(enrollment.type, "StudentEnrollment")
        XCTAssertEqual(enrollment.userID, "3")
        XCTAssertEqual(enrollment.canvasContextID, "course_4")
        XCTAssertEqual(enrollment.grades.count, 1)
        let grade = enrollment.grades.first
        XCTAssertNil(grade?.gradingPeriodID)
        XCTAssertEqual(grade?.currentScore, 100)

    }

    func testIsStudentTeacherTA() {
        for type in [ "student", "StudentEnrollment", "StudentView" ] {
            let enrollment = Enrollment.make(from: .make(type: type))
            XCTAssertTrue(enrollment.isStudent)
            XCTAssertFalse(enrollment.isTeacher)
            XCTAssertFalse(enrollment.isTA)
        }
        for type in [ "teacher", "TeacherEnrollment" ] {
            let enrollment = Enrollment.make(from: .make(type: type))
            XCTAssertFalse(enrollment.isStudent)
            XCTAssertTrue(enrollment.isTeacher)
            XCTAssertFalse(enrollment.isTA)
        }
        for type in [ "ta", "TAEnrollment" ] {
            let enrollment = Enrollment.make(from: .make(type: type))
            XCTAssertFalse(enrollment.isStudent)
            XCTAssertFalse(enrollment.isTeacher)
            XCTAssertTrue(enrollment.isTA)
        }
    }

    func testFormattedRole() {
        XCTAssertEqual(Enrollment.make(from: .make(role: "StudentEnrollment")).formattedRole, "Student")
        XCTAssertEqual(Enrollment.make(from: .make(role: "TeacherEnrollment")).formattedRole, "Teacher")
        XCTAssertEqual(Enrollment.make(from: .make(role: "TaEnrollment")).formattedRole, "TA")
        XCTAssertEqual(Enrollment.make(from: .make(role: "ObserverEnrollment")).formattedRole, "Observer")
        XCTAssertEqual(Enrollment.make(from: .make(role: "DesignerEnrollment")).formattedRole, "Designer")
        XCTAssertEqual(Enrollment.make(from: .make(role: "Custom Role")).formattedRole, "Custom Role")
        let enrollment = databaseClient.insert() as Enrollment
        enrollment.role = nil
        XCTAssertNil(enrollment.formattedRole)
    }

    func testCurrentScore() {
        let enrollment: Enrollment = databaseClient.insert()
        let currentPeriod = APIEnrollment.make(
            grades: nil,
            current_grading_period_id: "1",
            current_period_computed_current_score: 10
        )
        let allPeriods = APIEnrollment.make(
            grades: .make(current_score: 100)
        )
        enrollment.update(fromApiModel: currentPeriod, course: nil, in: databaseClient)
        enrollment.update(fromApiModel: allPeriods, course: nil, gradingPeriodID: nil, in: databaseClient)
        XCTAssertEqual(enrollment.currentScore, 10)
        XCTAssertEqual(enrollment.currentScore(gradingPeriodID: "1"), 10)
        XCTAssertEqual(enrollment.currentScore(gradingPeriodID: nil), 100)
    }

    func testFormattedCurrentScore() {
        let enrollment: Enrollment = databaseClient.insert()
        XCTContext.runActivity(named: "When totalsForAllGradingPeriodsOption is true") { _ in
            let currentPeriod = APIEnrollment.make(
                grades: nil,
                multiple_grading_periods_enabled: true,
                totals_for_all_grading_periods_option: true,
                current_grading_period_id: "1",
                current_period_computed_current_score: 10
            )
            let allPeriods = APIEnrollment.make(
                grades: .make(current_score: 100)
            )
            enrollment.update(fromApiModel: currentPeriod, course: nil, in: databaseClient)
            enrollment.update(fromApiModel: allPeriods, course: nil, gradingPeriodID: nil, in: databaseClient)
            XCTAssertEqual(enrollment.formattedCurrentScore(gradingPeriodID: "1"), "10%")
            XCTAssertEqual(enrollment.formattedCurrentScore(gradingPeriodID: nil), "100%")
        }

        XCTContext.runActivity(named: "When totalsForAllGradingPeriodsOption is false") { _ in
            let currentPeriod = APIEnrollment.make(
                grades: nil,
                multiple_grading_periods_enabled: true,
                totals_for_all_grading_periods_option: false,
                current_grading_period_id: "1",
                current_period_computed_current_score: 10
            )
            let allPeriods = APIEnrollment.make(
                grades: .make(current_score: 100),
                totals_for_all_grading_periods_option: false
            )
            enrollment.update(fromApiModel: currentPeriod, course: nil, in: databaseClient)
            enrollment.update(fromApiModel: allPeriods, course: nil, gradingPeriodID: nil, in: databaseClient)
            XCTAssertEqual(enrollment.formattedCurrentScore(gradingPeriodID: "1"), "10%")
            XCTAssertEqual(enrollment.formattedCurrentScore(gradingPeriodID: nil), "N/A")
        }

        XCTContext.runActivity(named: "When totalsForAllGradingPeriodsOption is false and MGP false") { _ in
            let currentPeriod = APIEnrollment.make(
                grades: nil,
                multiple_grading_periods_enabled: false,
                totals_for_all_grading_periods_option: nil,
                current_grading_period_id: "1",
                current_period_computed_current_score: 10
            )
            let allPeriods = APIEnrollment.make(
                grades: .make(current_score: 100)
            )
            enrollment.update(fromApiModel: currentPeriod, course: nil, in: databaseClient)
            enrollment.update(fromApiModel: allPeriods, course: nil, gradingPeriodID: nil, in: databaseClient)
            XCTAssertEqual(enrollment.formattedCurrentScore(gradingPeriodID: "1"), "10%")
            XCTAssertEqual(enrollment.formattedCurrentScore(gradingPeriodID: nil), "100%")

        }
    }
    func testObservedUser() {
        let observedUser = APIUser.make()
        let enrollment = Enrollment.make(from: .make(observed_user: observedUser))
        XCTAssertEqual(enrollment.observedUser?.id, observedUser.id.value)
    }
}
