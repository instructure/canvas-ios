//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import XCTest

class CourseListItemTests: CoreTestCase {

    func testRoles() {
        let apiCourse = APICourse.make(enrollments: [
            .make(role: "TeacherEnrollment"),
            .make(role: "StudentEnrollment"),
            .make(role: "StudentEnrollment"),
        ])
        let testee = CourseListItem.save(apiCourse, enrollmentState: .active, in: databaseClient)
        XCTAssertEqual(testee.roles, "Student, Teacher")
    }

    func testFavoriteButtonVisibleForCourseState() {
        let testData: [CourseWorkflowState?: Bool] = [
            .available: true,
            .completed: true,
            .deleted: false,
            .unpublished: false,
            nil: false,
        ]

        for testCase in testData {
            let apiCourse = APICourse.make(workflow_state: testCase.key)
            let testee = CourseListItem.save(apiCourse, enrollmentState: .active, in: databaseClient)
            XCTAssertEqual(testee.isFavoriteButtonVisible, testCase.value)
        }
    }

    func testFavoriteButtonVisibleForEnrollmentState() {
        let testData: [GetCoursesRequest.EnrollmentState: Bool] = [
            .completed: false,
            .invited_or_pending: false,
            .active: true,
        ]

        for testCase in testData {
            let apiCourse = APICourse.make(workflow_state: .available)
            let testee = CourseListItem.save(apiCourse, enrollmentState: testCase.key, in: databaseClient)
            XCTAssertEqual(testee.isFavoriteButtonVisible, testCase.value)
        }
    }
}
