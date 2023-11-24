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

@testable import Core
import XCTest

class CourseSyncGradesInteractorLiveTests: CoreTestCase {
    private let testee = CourseSyncGradesInteractorLive(userId: "testUser")

    override func setUp() {
        super.setUp()
        mockCourseColors()
        mockGradingPeriods()
        mockCourse()
        mockEnrollments()
        mockAssignments()
    }

    func testSuccessfulSync() {
        XCTAssertFinish(testee.getContent(courseId: "testCourse"))
    }

    func testColorSyncFailure() {
        mockCourseColorsFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    func testGradingPeriodsSyncFailure() {
        mockGradingPeriodsFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    func testCourseSyncFailure() {
        mockCourseFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    func testEnrollmentsSyncFailure() {
        mockEnrollmentsFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    func testAssignmentsSyncFailure() {
        mockAssignmentsFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    // MARK: - Helpers

    // MARK: Colors

    private func mockCourseColors() {
        api.mock(GetCustomColors(), value: .init(custom_colors: [:]))
    }

    private func mockCourseColorsFailure() {
        api.mock(GetCustomColors(), error: NSError.instructureError(""))
    }

    // MARK: Grading Periods

    private func mockGradingPeriods() {
        api.mock(GetGradingPeriods(courseID: "testCourse"),
                 value: [])
    }

    private func mockGradingPeriodsFailure() {
        api.mock(GetGradingPeriods(courseID: "testCourse"),
                 error: NSError.instructureError(""))
    }

    // MARK: Course

    private func mockCourse() {
        let mockEnrollment = APIEnrollment.make(enrollment_state: .active,
                                                type: "StudentEnrollment",
                                                user_id: "testUser",
                                                current_grading_period_id: "testGradingPeriod")
        api.mock(GetCourse(courseID: "testCourse"),
                 value: .make(id: "testCourse", enrollments: [mockEnrollment]))
    }

    private func mockCourseFailure() {
        api.mock(GetCourse(courseID: "testCourse"),
                 error: NSError.instructureError(""))
    }

    // MARK: Enrollments

    private let enrollmentUseCase = GetEnrollments(context: .course("testCourse"),
                                                   userID: "testUser",
                                                   gradingPeriodID: "testGradingPeriod",
                                                   types: ["StudentEnrollment"],
                                                   states: [.active])
    private func mockEnrollments() {
        api.mock(enrollmentUseCase,
                 value: [])
    }

    private func mockEnrollmentsFailure() {
        api.mock(enrollmentUseCase,
                 error: NSError.instructureError(""))
    }

    // MARK: Assignments

    private let assignmentsUseCase = GetAssignmentsByGroup(courseID: "testCourse",
                                                           gradingPeriodID: "testGradingPeriod",
                                                           gradedOnly: true)
    private func mockAssignments() {
        api.mock(assignmentsUseCase,
                 value: [])
    }

    private func mockAssignmentsFailure() {
        api.mock(assignmentsUseCase,
                 error: NSError.instructureError(""))
    }
}
