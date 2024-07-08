//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class APIEnrollmentTests: XCTestCase {
    func testEnrollUserRequest() {
        let enrollment = PostEnrollmentRequest.Body.Enrollment(user_id: "1", type: "teacher", enrollment_state: .active)
        let body = PostEnrollmentRequest.Body(enrollment: enrollment)
        let request = PostEnrollmentRequest(courseID: "1", body: body)

        XCTAssertEqual(request.path, "courses/1/enrollments")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }

    func testGetEnrollmentsRequest() {
        let request = GetEnrollmentsRequest(context: .currentUser, userID: "1", gradingPeriodID: "2", types: ["TeacherEnrollment"], includes: [.avatar_url])
        XCTAssertEqual(request.path, "users/self/enrollments")
        XCTAssertEqual(request.query, [
            .value("per_page", "100"),
            .include([GetEnrollmentsRequest.Include.avatar_url.rawValue]),
            .value("user_id", "1"),
            .value("grading_period_id", "2"),
            .array("type", ["TeacherEnrollment"])
        ])
    }

    func testGetEnrollmentsRequestForParentObservedStudents() {
        let request = GetEnrollmentsRequest(context: .currentUser, includes: [.observed_users, .avatar_url], states: GetEnrollmentsRequest.State.allForParentObserver, roles: [.observer])
        XCTAssertEqual(request.path, "users/self/enrollments")
        let expectedStates = GetEnrollmentsRequest.State.allForParentObserver.map { $0.rawValue }
        XCTAssertEqual(request.query, [
            .value("per_page", "100"),
            .include([GetEnrollmentsRequest.Include.observed_users.rawValue, GetEnrollmentsRequest.Include.avatar_url.rawValue]),
            .array("state", expectedStates),
            .array("role", ["ObserverEnrollment"])
        ])
    }
}
