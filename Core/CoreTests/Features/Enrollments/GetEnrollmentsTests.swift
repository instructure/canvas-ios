//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class GetEnrollmentsTests: CoreTestCase {

    func test_cacheKey_includesAllParameters() {
        let testee = GetEnrollments(
            context: .course("someCourseID"),
            userID: "someUserID",
            gradingPeriodID: "somePeriodID",
            types: ["type1", "type2"],
            includes: [.avatar_url],
            states: [.invited, .deleted],
            roles: [.teacher, .custom("someCustomRole")]
        )

        // THEN
        XCTAssertEqual(testee.cacheKey, """
        courses/someCourseID/enrollments?\
        per_page=100\
        &include[]=avatar_url\
        &state[]=invited&state[]=deleted\
        &role[]=TeacherEnrollment&role[]=someCustomRole\
        &user_id=someUserID\
        &grading_period_id=somePeriodID\
        &type[]=type1&type[]=type2
        """)
    }

    func test_scope_filtersWithoutUserID() {
        let testee = GetEnrollments(
            context: .course("someCourseID")
        )

        // THEN
        XCTAssertEqual(testee.scope.predicate.predicateFormat, """
        canvasContextID == "course_someCourseID" \
        AND id != nil
        """)
    }

    func test_scope_filtersWithUserID() {
        let testee = GetEnrollments(
            context: .course("someCourseID"),
            userID: "someUserID"
        )

        // THEN
        XCTAssertEqual(testee.scope.predicate.predicateFormat, """
        canvasContextID == "course_someCourseID" \
        AND id != nil \
        AND userID == "someUserID"
        """)
    }

    func test_modified_preservesDataForRootEnvironment() {
        let env = AppEnvironment()
        let testee = GetEnrollments(
            context: .course("someCourseID"),
            userID: "someUserID"
        )

        // WHEN
        let modified = testee.modified(for: env)

        // THEN
        XCTAssertEqual(modified.context.canvasContextID, "course_someCourseID")
        XCTAssertEqual(modified.request.userID, "someUserID")
    }

    func test_modified_expandsUserIDForNonRootEnvironment() {
        let session = LoginSession.make(accessToken: "7053~token", baseURL: URL(string: "https://canvas.instructure.com")!)
        let env = AppEnvironment()
        env.userDidLogin(session: session)

        let testee = GetEnrollments(
            context: .course("123"),
            userID: "456"
        )

        // WHEN
        let modified = testee.modified(for: env)

        // THEN
        XCTAssertEqual(modified.context.canvasContextID, "course_123")
        XCTAssertEqual(modified.request.userID, "70530000000000456")
    }

    func test_write_savesEnrollmentToDatabase() {
        let testee = GetEnrollments(
            context: .course("1"),
            gradingPeriodID: "period1"
        )

        let apiEnrollment = APIEnrollment.make(
            id: "123",
            course_id: "1",
            enrollment_state: .active,
            user_id: "456"
        )

        // WHEN
        testee.write(response: [apiEnrollment], urlResponse: nil, to: databaseClient)

        // THEN
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "123")
        XCTAssertNotNil(enrollment)
        XCTAssertEqual(enrollment?.id, "123")
    }

    func test_write_handlesNilResponse() {
        let testee = GetEnrollments(context: .course("1"))

        // WHEN
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        // THEN
        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 0)
    }

    func test_init_acceptsAllParameters() {
        // WHEN
        let testee = GetEnrollments(
            context: .course("course1"),
            userID: "user1",
            gradingPeriodID: "period1",
            types: ["StudentEnrollment"],
            includes: [.avatar_url, .observed_users],
            states: [.active, .invited],
            roles: [.student]
        )

        // THEN
        XCTAssertEqual(testee.context.canvasContextID, "course_course1")
        XCTAssertEqual(testee.gradingPeriodID, "period1")
    }
}

class GetCourseInvitationsTests: CoreTestCase {

    func test_cacheKey_returnsCorrectValue() {
        let testee = GetCourseInvitations()

        // THEN
        XCTAssertEqual(testee.cacheKey, "users/self/enrollments?state[]=invited")
    }

    func test_scope_filtersInvitations() {
        let testee = GetCourseInvitations()

        // THEN
        XCTAssertEqual(testee.scope.predicate.predicateFormat, "isFromInvitation == 1")
    }

    func test_request_requestsInvitedEnrollments() {
        let testee = GetCourseInvitations()

        // WHEN
        let request = testee.request

        // THEN
        XCTAssertEqual(request.context, .currentUser)
        XCTAssertEqual(request.states, [.invited])
    }

    func test_write_marksEnrollmentAsFromInvitation() {
        let testee = GetCourseInvitations()

        let apiEnrollment = APIEnrollment.make(
            id: "123",
            course_id: "456",
            enrollment_state: .invited
        )

        // WHEN
        testee.write(response: [apiEnrollment], urlResponse: nil, to: databaseClient)

        // THEN
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "123")
        XCTAssertNotNil(enrollment)
        XCTAssertEqual(enrollment?.isFromInvitation, true)
    }

    func test_write_ignoresEnrollmentWithoutCourseID() {
        let testee = GetCourseInvitations()

        let apiEnrollment = APIEnrollment.make(
            id: "123",
            course_id: nil,
            enrollment_state: .invited
        )

        // WHEN
        testee.write(response: [apiEnrollment], urlResponse: nil, to: databaseClient)

        // THEN
        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 0)
    }

    func test_write_ignoresEnrollmentWithNilID() {
        let testee = GetCourseInvitations()

        let apiEnrollment = APIEnrollment.make(
            id: nil,
            course_id: "456",
            enrollment_state: .invited
        )

        // WHEN
        testee.write(response: [apiEnrollment], urlResponse: nil, to: databaseClient)

        // THEN
        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 0)
    }
}

class HandleCourseInvitationTests: CoreTestCase {

    func test_cacheKey_returnsNil() {
        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "2",
            isAccepted: true
        )

        // THEN
        XCTAssertNil(testee.cacheKey)
    }

    func test_request_createsAcceptRequest() {
        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "2",
            isAccepted: true
        )

        // WHEN
        let request = testee.request

        // THEN
        XCTAssertEqual(request.courseID, "1")
        XCTAssertEqual(request.enrollmentID, "2")
        XCTAssertTrue(request.isAccepted)
    }

    func test_request_createsRejectRequest() {
        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "2",
            isAccepted: false
        )

        // WHEN
        let request = testee.request

        // THEN
        XCTAssertEqual(request.courseID, "1")
        XCTAssertEqual(request.enrollmentID, "2")
        XCTAssertFalse(request.isAccepted)
    }

    func test_write_setsEnrollmentToActiveWhenAccepted() {
        Enrollment.make(
            from: .make(id: "123", enrollment_state: .invited),
            in: databaseClient
        )

        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "123",
            isAccepted: true
        )

        let response = HandleCourseInvitationRequest.Response(success: true)

        // WHEN
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        // THEN
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "123")
        XCTAssertEqual(enrollment?.state, .active)
    }

    func test_write_setsEnrollmentToRejectedWhenRejected() {
        Enrollment.make(
            from: .make(id: "123", enrollment_state: .invited),
            in: databaseClient
        )

        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "123",
            isAccepted: false
        )

        let response = HandleCourseInvitationRequest.Response(success: true)

        // WHEN
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        // THEN
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "123")
        XCTAssertEqual(enrollment?.state, .rejected)
    }

    func test_write_doesNotUpdateOnFailedResponse() {
        Enrollment.make(
            from: .make(id: "123", enrollment_state: .invited),
            in: databaseClient
        )

        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "123",
            isAccepted: true
        )

        let response = HandleCourseInvitationRequest.Response(success: false)

        // WHEN
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        // THEN
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "123")
        XCTAssertEqual(enrollment?.state, .invited)
    }

    func test_write_doesNotUpdateOnNilResponse() {
        Enrollment.make(
            from: .make(id: "123", enrollment_state: .invited),
            in: databaseClient
        )

        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "123",
            isAccepted: true
        )

        // WHEN
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        // THEN
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "123")
        XCTAssertEqual(enrollment?.state, .invited)
    }

    func test_write_handlesNonExistentEnrollment() {
        let testee = HandleCourseInvitation(
            courseID: "1",
            enrollmentID: "999",
            isAccepted: true
        )

        let response = HandleCourseInvitationRequest.Response(success: true)

        // WHEN
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        // THEN
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "999")
        XCTAssertNil(enrollment)
    }
}
