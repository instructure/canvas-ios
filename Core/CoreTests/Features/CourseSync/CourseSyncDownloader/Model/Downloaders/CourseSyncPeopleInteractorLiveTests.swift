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

class CourseSyncPeopleInteractorLiveTests: CoreTestCase {

    private var testee: CourseSyncPeopleInteractorLive!

    override func setUp() {
        super.setUp()
        AppEnvironment.shared.currentSession = LoginSession.make()
        testee = CourseSyncPeopleInteractorLive(envResolver: envResolver)

        mockCourseColors()
        mockCourse()
        mockUsers()
        mockCourseSections()
    }

    override func tearDown() {
        super.tearDown()
        testee = nil
    }

    func testSuccessfulSync() {
        XCTAssertFinish(testee.getContent(courseId: "testCourse"))
    }

    func testColorSyncFailure() {
        mockCourseColorsFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    func testCourseSyncFailure() {
        mockCourseFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    func testUsersSyncFailure() {
        mockUsersFailure()
        XCTAssertFailure(testee.getContent(courseId: "testCourse"))
    }

    func testCourseSectionsSyncFailure() {
        mockCourseSectionsFailure()
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

    private func makeEnrollment() -> APIEnrollment {
        APIEnrollment.make(
            id: "1",
            course_id: "testCourse",
            enrollment_state: .active,
            type: "StudentEnrollment",
            user_id: "1",
            last_activity_at: Date(),
            current_grading_period_id: "1"
        )
    }

    // MARK: Users

    private let usersUseCase = GetContextUsers(context: .course("testCourse"))

    private func mockUsers() {
        let enrollment = makeEnrollment()
        let user = APIUser.make(id: "1", name: "Test User", login_id: "1", avatar_url: nil, enrollments: [enrollment], email: "test@test", pronouns: nil)
        api.mock(usersUseCase, value: [user])
    }

    private func mockUsersFailure() {
        api.mock(usersUseCase, error: NSError.instructureError(""))
    }

    // MARK: Course Sections

    private let courseSectionsUseCase = GetCourseSectionsRequest(courseID: "testCourse")
    private func mockCourseSections() {
        api.mock(courseSectionsUseCase, value: [ .make() ])
    }

    private func mockCourseSectionsFailure() {
        api.mock(courseSectionsUseCase, error: NSError.instructureError(""))
    }
}
