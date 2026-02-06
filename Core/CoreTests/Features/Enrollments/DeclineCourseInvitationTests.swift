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

import XCTest
@testable import Core

class DeclineCourseInvitationTests: CoreTestCase {

    func testScope_filtersCorrectEnrollment() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        XCTAssertEqual(testee.scope.predicate.predicateFormat, #"id == "enrollment1""#)
    }

    func testCacheKey_returnsNil() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        XCTAssertNil(testee.cacheKey)
    }

    func testTTL_returnsZero() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        XCTAssertEqual(testee.ttl, 0)
    }

    func testMakeRequest_callsHandleInvitationRequest() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        api.mock(
            HandleCourseInvitationRequest(courseID: "course1", enrollmentID: "enrollment1", isAccepted: false),
            value: HandleCourseInvitationRequest.Response(success: true)
        )

        let expectation = expectation(description: "makeRequest completes")
        testee.makeRequest(environment: environment) { response, _, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertTrue(response?.success ?? false)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testMakeRequest_propagatesError() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")
        let testError = NSError(domain: "TestError", code: 456)

        api.mock(
            HandleCourseInvitationRequest(courseID: "course1", enrollmentID: "enrollment1", isAccepted: false),
            error: testError
        )

        let expectation = expectation(description: "makeRequest completes")
        testee.makeRequest(environment: environment) { response, _, error in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testWrite_deletesEnrollmentOnSuccess() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        Enrollment.make(
            from: .make(id: "enrollment1", course_id: "course1", enrollment_state: .invited),
            in: databaseClient
        )

        XCTAssertNotNil(databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment1") as Enrollment?)

        let response = HandleCourseInvitationRequest.Response(success: true)
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment1")
        XCTAssertNil(enrollment)
    }

    func testWrite_doesNotDeleteOnFailedResponse() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        Enrollment.make(
            from: .make(id: "enrollment1", course_id: "course1", enrollment_state: .invited),
            in: databaseClient
        )

        let response = HandleCourseInvitationRequest.Response(success: false)
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment1")
        XCTAssertNotNil(enrollment)
    }

    func testWrite_doesNotDeleteOnNilResponse() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        Enrollment.make(
            from: .make(id: "enrollment1", course_id: "course1", enrollment_state: .invited),
            in: databaseClient
        )

        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment1")
        XCTAssertNotNil(enrollment)
    }

    func testWrite_handlesNonExistentEnrollmentGracefully() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "nonexistent")

        let response = HandleCourseInvitationRequest.Response(success: true)
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 0)
    }

    func testWrite_onlyDeletesTargetEnrollment() {
        let testee = DeclineCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        Enrollment.make(
            from: .make(id: "enrollment1", course_id: "course1", enrollment_state: .invited),
            in: databaseClient
        )
        Enrollment.make(
            from: .make(id: "enrollment2", course_id: "course1", enrollment_state: .invited),
            in: databaseClient
        )

        let response = HandleCourseInvitationRequest.Response(success: true)
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollment1: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment1")
        let enrollment2: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment2")

        XCTAssertNil(enrollment1)
        XCTAssertNotNil(enrollment2)
    }
}
