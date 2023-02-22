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
        let testee = CourseListItem.save(apiCourse,
                                         enrollmentState: .active,
                                         in: databaseClient)
        XCTAssertEqual(testee.roles, "Student, Teacher")
    }

    func testCourseDetailsNotAvailableForUnpublishedCoursesInStudentApp() {
        let apiCourse = APICourse.make(workflow_state: .unpublished)
        let testee = CourseListItem.save(apiCourse,
                                         enrollmentState: .active,
                                         app: .student,
                                         in: databaseClient)
        XCTAssertFalse(testee.isCourseDetailsAvailable)
    }

    func testFavoriteButtonVisibility() {
        XCTAssertTrue(visibility(.active, .student, .available))
        XCTAssertFalse(visibility(.active, .student, .completed))
        XCTAssertFalse(visibility(.active, .student, .unpublished))
        XCTAssertFalse(visibility(.active, .student, .deleted))
        XCTAssertTrue(visibility(.active, .teacher, .available))
        XCTAssertFalse(visibility(.active, .teacher, .completed))
        XCTAssertTrue(visibility(.active, .teacher, .unpublished))
        XCTAssertFalse(visibility(.active, .teacher, .deleted))

        XCTAssertFalse(visibility(.invited_or_pending, .student, .available))
        XCTAssertFalse(visibility(.invited_or_pending, .student, .completed))
        XCTAssertFalse(visibility(.invited_or_pending, .student, .unpublished))
        XCTAssertFalse(visibility(.invited_or_pending, .student, .deleted))
        XCTAssertFalse(visibility(.invited_or_pending, .teacher, .available))
        XCTAssertFalse(visibility(.invited_or_pending, .teacher, .completed))
        XCTAssertFalse(visibility(.invited_or_pending, .teacher, .unpublished))
        XCTAssertFalse(visibility(.invited_or_pending, .teacher, .deleted))

        XCTAssertFalse(visibility(.completed, .student, .available))
        XCTAssertFalse(visibility(.completed, .student, .completed))
        XCTAssertFalse(visibility(.completed, .student, .unpublished))
        XCTAssertFalse(visibility(.completed, .student, .deleted))
        XCTAssertFalse(visibility(.completed, .teacher, .available))
        XCTAssertFalse(visibility(.completed, .teacher, .completed))
        XCTAssertFalse(visibility(.completed, .teacher, .unpublished))
        XCTAssertFalse(visibility(.completed, .teacher, .deleted))

    }

    private func visibility(_ enrollmentState: GetCoursesRequest.EnrollmentState,
                            _ app: AppEnvironment.App?,
                            _ workflowState: CourseWorkflowState?) -> Bool {
        CourseListItem.isFavoriteButtonVisible(enrollmentState: enrollmentState,
                                               app: app,
                                               workflowState: workflowState)
    }
}
