//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI
@testable import Core
import TestsFoundation

class ContextCardTests: CoreTestCase {

    override func setUp() {
        super.setUp()
        mockApiCalls()
    }

    func testHeader() {
        let controller = hostSwiftUIController(ContextCardView(model: ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "0")))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.userNameLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.userEmailLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.lastActivityLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.courseLabel"))
    }

    func testCurrentGrade() {
        let controller = hostSwiftUIController(ContextCardView(model: ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "0")))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.currentGradeLabel"))
        XCTAssertNil(tree?.find(id: "ContextCard.unpostedGradeLabel"))
        XCTAssertNil(tree?.find(id: "ContextCard.overrideGradeLabel"))
    }

    func testUnpostedGrade() {
        let enrollment = makeEnrollment(with: .make(current_grade: "A", final_grade: "B", current_score: 77, final_score: 88, unposted_current_grade: "B"))
        api.mock(GetEnrollments(context: .course("1"), states: [ .active ]), value: [ enrollment ])

        let controller = hostSwiftUIController(ContextCardView(model: ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "0")))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.currentGradeLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.unpostedGradeLabel"))
        XCTAssertNil(tree?.find(id: "ContextCard.overrideGradeLabel"))
    }

    func testOverrideGrade() {
        let enrollment = makeEnrollment(with: .make(current_grade: "A", final_grade: "B", current_score: 77, final_score: 88, override_grade: "C", unposted_current_grade: "B"))
        api.mock(GetEnrollments(context: .course("1"), states: [ .active ]), value: [ enrollment ])

        let controller = hostSwiftUIController(ContextCardView(model: ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "0")))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.currentGradeLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.unpostedGradeLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.overrideGradeLabel"))
    }

    func testSubmissions() {
        let controller = hostSwiftUIController(ContextCardView(model: ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "0")))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.submissionsTotalLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.submissionCell(1)"))
    }

    func testGradesViewWhenQuantitativeDataEnabled() {
        // Given
        let testee = ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "1")
        mockCourseAndAssignmentWith(restrict_quantitative_data: true)

        // When
        testee.viewAppeared()

        // Then
        XCTAssertEqual(testee.hideQuantitativeData, true)
    }

    func testGradesViewWhenQuantitativeDataDisabled() {
        // Given
        let testee = ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "1")
        mockCourseAndAssignmentWith(restrict_quantitative_data: false)

        // When
        testee.viewAppeared()

        // Then
        XCTAssertEqual(testee.hideQuantitativeData, false)
    }

    func testGradesViewWhenQuantitativeDataNotSpecified() {
        // Given
        let testee = ContextCardViewModel(courseID: "1", userID: "1", currentUserID: "1")
        mockCourseAndAssignmentWith(restrict_quantitative_data: nil)

        // When
        testee.viewAppeared()

        // Then
        XCTAssertEqual(testee.hideQuantitativeData, false)
    }

    private func mockCourseAndAssignmentWith(restrict_quantitative_data: Bool?) {
        let enrollment = makeEnrollment(with: .make(current_grade: "3", final_grade: "4", current_score: 77, final_score: 88))
        api.mock(GetCourseSingleUser(context: .course("1"), userID: "1"), value: makeUser(with: enrollment))
        api.mock(GetEnrollments(context: .course("1"), states: [ .active ]), value: [ enrollment ])

        api.mock(
            GetCourse(courseID: "1"),
            value: .make(
                settings: APICourseSettings(
                    usage_rights_required: nil,
                    syllabus_course_summary: nil,
                    restrict_quantitative_data: restrict_quantitative_data
                )
            )
        )
    }

    private func mockApiCalls() {
        let enrollment = makeEnrollment(with: .make(current_grade: "A", final_grade: "B", current_score: 77, final_score: 88))
        api.mock(GetCourseSingleUser(context: .course("1"), userID: "1"), value: makeUser(with: enrollment))
        api.mock(GetCourse(courseID: "1"), value: .make())
        api.mock(GetCourseSectionsRequest(courseID: "1"), value: [ .make() ])
        api.mock(GetSubmissionsForStudent(context: .course("1"), studentID: "1"), value: [ APISubmission.make(assignment: APIAssignment.make(), assignment_id: "1", submission_history: [])])
        api.mock(GetEnrollments(context: .course("1"), states: [ .active ]), value: [ enrollment ])
    }

    private func makeUser(with enrollment: APIEnrollment) -> APIUser {
        APIUser.make(id: "1", name: "Test User", login_id: "test", avatar_url: nil, enrollments: [enrollment], email: "test@test", pronouns: nil)
    }

    private func makeEnrollment(with grade: APIEnrollment.Grades) -> APIEnrollment {
        APIEnrollment.make(
            id: "1",
            course_id: "1",
            enrollment_state: .active,
            type: "StudentEnrollment",
            user_id: "1",
            last_activity_at: Date(),
            grades: grade
        )
    }
}
