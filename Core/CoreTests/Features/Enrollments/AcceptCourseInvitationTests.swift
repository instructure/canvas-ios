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

class AcceptCourseInvitationTests: CoreTestCase {

    func testScope_filtersCorrectEnrollment() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        XCTAssertEqual(testee.scope.predicate.predicateFormat, #"id == "enrollment1""#)
    }

    func testCacheKey_returnsNil() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        XCTAssertNil(testee.cacheKey)
    }

    func testTTL_returnsZero() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        XCTAssertEqual(testee.ttl, 0)
    }

    func testMakeRequest_makesAllThreeRequests() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        api.mock(
            HandleCourseInvitationRequest(courseID: "course1", enrollmentID: "enrollment1", isAccepted: true),
            value: HandleCourseInvitationRequest.Response(success: true)
        )
        api.mock(
            GetCourseRequest(courseID: "course1"),
            value: .make(id: "course1", name: "Test Course")
        )
        api.mock(
            GetEnrollmentsRequest(context: .course("course1")),
            value: [.make(id: "enrollment1", course_id: "course1", enrollment_state: .active)]
        )

        let expectation = expectation(description: "makeRequest completes")
        testee.makeRequest(environment: environment) { response, _, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertTrue(response?.success ?? false)
            XCTAssertEqual(response?.course?.name, "Test Course")
            XCTAssertEqual(response?.enrollments?.count, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testMakeRequest_failsWhenInvitationNotAccepted() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        api.mock(
            HandleCourseInvitationRequest(courseID: "course1", enrollmentID: "enrollment1", isAccepted: true),
            value: HandleCourseInvitationRequest.Response(success: false)
        )

        let expectation = expectation(description: "makeRequest completes")
        testee.makeRequest(environment: environment) { response, _, error in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testMakeRequest_propagatesHandleInvitationError() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")
        let testError = NSError(domain: "TestError", code: 123)

        api.mock(
            HandleCourseInvitationRequest(courseID: "course1", enrollmentID: "enrollment1", isAccepted: true),
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

    func testMakeRequest_handlesGetCourseFailureGracefully() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        api.mock(
            HandleCourseInvitationRequest(courseID: "course1", enrollmentID: "enrollment1", isAccepted: true),
            value: HandleCourseInvitationRequest.Response(success: true)
        )
        api.mock(
            GetCourseRequest(courseID: "course1"),
            error: NSError(domain: "TestError", code: 404)
        )
        api.mock(
            GetEnrollmentsRequest(context: .course("course1")),
            value: [.make(id: "enrollment1", course_id: "course1", enrollment_state: .active)]
        )

        let expectation = expectation(description: "makeRequest completes")
        testee.makeRequest(environment: environment) { response, _, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertTrue(response?.success ?? false)
            XCTAssertNil(response?.course)
            XCTAssertEqual(response?.enrollments?.count, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testMakeRequest_handlesGetEnrollmentsFailureGracefully() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        api.mock(
            HandleCourseInvitationRequest(courseID: "course1", enrollmentID: "enrollment1", isAccepted: true),
            value: HandleCourseInvitationRequest.Response(success: true)
        )
        api.mock(
            GetCourseRequest(courseID: "course1"),
            value: .make(id: "course1", name: "Test Course")
        )
        api.mock(
            GetEnrollmentsRequest(context: .course("course1")),
            error: NSError(domain: "TestError", code: 500)
        )

        let expectation = expectation(description: "makeRequest completes")
        testee.makeRequest(environment: environment) { response, _, error in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertTrue(response?.success ?? false)
            XCTAssertEqual(response?.course?.name, "Test Course")
            XCTAssertNil(response?.enrollments)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    func testWrite_savesCourseData() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")
        let apiCourse = APICourse.make(id: "course1", name: "Updated Course")
        let response = InvitationAcceptResponse(success: true, course: apiCourse, enrollments: nil)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let course: Course? = databaseClient.first(where: #keyPath(Course.id), equals: "course1")
        XCTAssertNotNil(course)
        XCTAssertEqual(course?.name, "Updated Course")
    }

    func testWrite_savesEnrollmentData() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")
        let apiEnrollments = [
            APIEnrollment.make(id: "enrollment1", course_id: "course1", enrollment_state: .active),
            APIEnrollment.make(id: "enrollment2", course_id: "course1", enrollment_state: .active)
        ]
        let response = InvitationAcceptResponse(success: true, course: nil, enrollments: apiEnrollments)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 2)
    }

    func testWrite_clearsIsFromInvitationFlag() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        Enrollment.make(
            from: .make(id: "enrollment1", course_id: "course1", enrollment_state: .invited),
            in: databaseClient
        )
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment1")
        enrollment?.isFromInvitation = true
        try? databaseClient.save()

        let apiEnrollments = [
            APIEnrollment.make(id: "enrollment1", course_id: "course1", enrollment_state: .active)
        ]
        let response = InvitationAcceptResponse(success: true, course: nil, enrollments: apiEnrollments)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let updatedEnrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment1")
        XCTAssertFalse(updatedEnrollment?.isFromInvitation ?? true)
    }

    func testWrite_doesNotClearIsFromInvitationForOtherEnrollments() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        Enrollment.make(
            from: .make(id: "enrollment2", course_id: "course1", enrollment_state: .invited),
            in: databaseClient
        )
        let enrollment: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment2")
        enrollment?.isFromInvitation = true
        try? databaseClient.save()

        let apiEnrollments = [
            APIEnrollment.make(id: "enrollment1", course_id: "course1", enrollment_state: .active),
            APIEnrollment.make(id: "enrollment2", course_id: "course1", enrollment_state: .invited)
        ]
        let response = InvitationAcceptResponse(success: true, course: nil, enrollments: apiEnrollments)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollment2: Enrollment? = databaseClient.first(where: #keyPath(Enrollment.id), equals: "enrollment2")
        XCTAssertTrue(enrollment2?.isFromInvitation ?? false)
    }

    func testWrite_handlesNilResponse() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")

        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let courses: [Course] = databaseClient.fetch()
        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 0)
        XCTAssertEqual(enrollments.count, 0)
    }

    func testWrite_handlesNilCourse() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")
        let response = InvitationAcceptResponse(success: true, course: nil, enrollments: nil)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let courses: [Course] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 0)
    }

    func testWrite_handlesNilEnrollments() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")
        let response = InvitationAcceptResponse(success: true, course: nil, enrollments: nil)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 0)
    }

    func testWrite_ignoresEnrollmentsWithoutID() {
        let testee = AcceptCourseInvitation(courseID: "course1", enrollmentID: "enrollment1")
        let apiEnrollments = [
            APIEnrollment.make(id: nil, course_id: "course1", enrollment_state: .active)
        ]
        let response = InvitationAcceptResponse(success: true, course: nil, enrollments: apiEnrollments)

        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let enrollments: [Enrollment] = databaseClient.fetch()
        XCTAssertEqual(enrollments.count, 0)
    }
}
