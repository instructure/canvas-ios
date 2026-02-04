//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Combine
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class CoursesInteractorInvitationsTests: StudentTestCase {

    private var testee: CoursesInteractorLive!

    override func setUp() {
        super.setUp()
        testee = CoursesInteractorLive(env: env)
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Accept Invitation Tests

    func testAcceptInvitation_makesCorrectRequest() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course1",
                enrollmentID: "enrollment1",
                isAccepted: true
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )
        api.mock(
            GetCourseRequest(courseID: "course1"),
            value: .make(id: "course1")
        )
        api.mock(
            GetEnrollmentsRequest(context: .course("course1")),
            value: [.make(id: "enrollment1")]
        )

        XCTAssertFinish(
            testee.acceptInvitation(courseId: "course1", enrollmentId: "enrollment1"),
            timeout: 5
        )
    }

    func testAcceptInvitation_successCompletesWithoutError() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course2",
                enrollmentID: "enrollment2",
                isAccepted: true
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )
        api.mock(
            GetCourseRequest(courseID: "course2"),
            value: .make(id: "course2")
        )
        api.mock(
            GetEnrollmentsRequest(context: .course("course2")),
            value: [.make(id: "enrollment2")]
        )

        XCTAssertFinish(
            testee.acceptInvitation(courseId: "course2", enrollmentId: "enrollment2"),
            timeout: 5
        )
    }

    func testAcceptInvitation_failurePropagatesError() {
        let testError = NSError(domain: "TestError", code: 123, userInfo: nil)
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course3",
                enrollmentID: "enrollment3",
                isAccepted: true
            ),
            error: testError
        )

        XCTAssertFailure(
            testee.acceptInvitation(courseId: "course3", enrollmentId: "enrollment3"),
            timeout: 5
        )
    }

    func testAcceptInvitation_passesCourseIdCorrectly() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "specificCourse",
                enrollmentID: "enrollment4",
                isAccepted: true
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )
        api.mock(
            GetCourseRequest(courseID: "specificCourse"),
            value: .make(id: "specificCourse")
        )
        api.mock(
            GetEnrollmentsRequest(context: .course("specificCourse")),
            value: [.make(id: "enrollment4")]
        )

        XCTAssertFinish(
            testee.acceptInvitation(courseId: "specificCourse", enrollmentId: "enrollment4"),
            timeout: 5
        )
    }

    func testAcceptInvitation_passesEnrollmentIdCorrectly() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course5",
                enrollmentID: "specificEnrollment",
                isAccepted: true
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )
        api.mock(
            GetCourseRequest(courseID: "course5"),
            value: .make(id: "course5")
        )
        api.mock(
            GetEnrollmentsRequest(context: .course("course5")),
            value: [.make(id: "specificEnrollment")]
        )

        XCTAssertFinish(
            testee.acceptInvitation(courseId: "course5", enrollmentId: "specificEnrollment"),
            timeout: 5
        )
    }

    // MARK: - Decline Invitation Tests

    func testDeclineInvitation_makesCorrectRequest() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course6",
                enrollmentID: "enrollment6",
                isAccepted: false
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )

        XCTAssertFinish(
            testee.declineInvitation(courseId: "course6", enrollmentId: "enrollment6"),
            timeout: 5
        )
    }

    func testDeclineInvitation_successCompletesWithoutError() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course7",
                enrollmentID: "enrollment7",
                isAccepted: false
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )

        XCTAssertFinish(
            testee.declineInvitation(courseId: "course7", enrollmentId: "enrollment7"),
            timeout: 5
        )
    }

    func testDeclineInvitation_failurePropagatesError() {
        let testError = NSError(domain: "TestError", code: 456, userInfo: nil)
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course8",
                enrollmentID: "enrollment8",
                isAccepted: false
            ),
            error: testError
        )

        XCTAssertFailure(
            testee.declineInvitation(courseId: "course8", enrollmentId: "enrollment8"),
            timeout: 5
        )
    }

    func testDeclineInvitation_passesCourseIdCorrectly() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "specificDeclineCourse",
                enrollmentID: "enrollment9",
                isAccepted: false
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )

        XCTAssertFinish(
            testee.declineInvitation(courseId: "specificDeclineCourse", enrollmentId: "enrollment9"),
            timeout: 5
        )
    }

    func testDeclineInvitation_passesEnrollmentIdCorrectly() {
        api.mock(
            HandleCourseInvitationRequest(
                courseID: "course10",
                enrollmentID: "specificDeclineEnrollment",
                isAccepted: false
            ),
            value: HandleCourseInvitationRequest.Response(success: true)
        )

        XCTAssertFinish(
            testee.declineInvitation(courseId: "course10", enrollmentId: "specificDeclineEnrollment"),
            timeout: 5
        )
    }
}
