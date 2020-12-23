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
    private func mockApiCalls() {
        api.mock(GetUserProfile(userID: "1"), value: APIProfile.make(id: "1", name: "Test User", primary_email: "test@test", login_id: "test", avatar_url: nil, calendar: nil, pronouns: nil)
        )
        api.mock(GetCourse(courseID: "1"), value: .make())
        api.mock(GetEnrollments(context: .course("1")), value: [ .make(
            id: "1",
            course_id: "1",
            enrollment_state: .active,
            type: "StudentEnrollment",
            user_id: "1",
            last_activity_at: Date(),
            grades: .make(
                current_grade: "A",
                final_grade: "B",
                current_score: 77,
                final_score: 88
            )
        ), ])
        api.mock(GetCourseSectionsRequest(courseID: "1"), value: [ .make() ])
        api.mock(GetSubmissionsForStudent(context: .course("1"), studentID: "1"), value: [ APISubmission.make(assignment: APIAssignment.make(), assignment_id: "1")])
    }

    func testHeader() {
        mockApiCalls()
        let controller = hostSwiftUIController(ContextCardView(courseID: "1", userID: "1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.userNameLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.userEmailLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.lastActivityLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.courseLabel"))
    }

    func testCurrentGrade() {
        mockApiCalls()
        let controller = hostSwiftUIController(ContextCardView(courseID: "1", userID: "1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.currentGradeLabel"))
        XCTAssertNil(tree?.find(id: "ContextCard.unpostedGradeLabel"))
        XCTAssertNil(tree?.find(id: "ContextCard.overrideGradeLabel"))
    }

    func testUnpostedGrade() {
        mockApiCalls()
        api.mock(GetEnrollments(context: .course("1")), value: [ .make(
            id: "1",
            course_id: "1",
            enrollment_state: .active,
            type: "StudentEnrollment",
            user_id: "1",
            last_activity_at: Date(),
            grades: .make(
                current_grade: "A",
                final_grade: "B",
                current_score: 77,
                final_score: 88,
                unposted_current_grade: "B"
            )
        ), ])
        let controller = hostSwiftUIController(ContextCardView(courseID: "1", userID: "1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.currentGradeLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.unpostedGradeLabel"))
        XCTAssertNil(tree?.find(id: "ContextCard.overrideGradeLabel"))
    }

    func testOverrideGrade() {
        mockApiCalls()
        api.mock(GetEnrollments(context: .course("1")), value: [ .make(
            id: "1",
            course_id: "1",
            enrollment_state: .active,
            type: "StudentEnrollment",
            user_id: "1",
            last_activity_at: Date(),
            grades: .make(
                current_grade: "A",
                final_grade: "B",
                current_score: 77,
                final_score: 88,
                override_grade: "C",
                unposted_current_grade: "B"
            )
        ), ])
        let controller = hostSwiftUIController(ContextCardView(courseID: "1", userID: "1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.currentGradeLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.unpostedGradeLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.overrideGradeLabel"))
    }

    func testSubmissions() {
        mockApiCalls()
        let controller = hostSwiftUIController(ContextCardView(courseID: "1", userID: "1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "ContextCard.submissionsTotalLabel"))
        XCTAssertNotNil(tree?.find(id: "ContextCard.submissionCell(1)"))
    }
}
