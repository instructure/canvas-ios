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

import XCTest
@testable import Core

class APIAssignmentRequestableTests: XCTestCase {
    func testGetAssignmentRequest() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [])
        XCTAssertEqual(request.path, "courses/1/assignments/2")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "include[]", value: "observed_users"),
        ])
        let allDates = GetAssignmentRequest(courseID: "1", assignmentID: "2", allDates: true, include: [])
        XCTAssertEqual(allDates.queryItems, [
            URLQueryItem(name: "include[]", value: "observed_users"),
            URLQueryItem(name: "all_dates", value: "true"),
        ])
        let notAllDates = GetAssignmentRequest(courseID: "1", assignmentID: "2", allDates: false, include: [])
        XCTAssertEqual(notAllDates.queryItems, [
            URLQueryItem(name: "include[]", value: "observed_users"),
        ])
    }

    func testGetAssignmentRequestWithSubmission() {
        let request = GetAssignmentRequest(courseID: "1", assignmentID: "2", include: [.submission])
        XCTAssertEqual(request.path, "courses/1/assignments/2")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "include[]", value: "submission"),
            URLQueryItem(name: "include[]", value: "observed_users"),
        ])
    }

    func testGetAssignmentsRequest() {
        var request = GetAssignmentsRequest(courseID: "1")
        XCTAssertEqual(request.path, "courses/1/assignments")
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "order_by", value: "position")])

        request = GetAssignmentsRequest(courseID: "1", orderBy: .name, perPage: 100)
        XCTAssertEqual(request.queryItems, [URLQueryItem(name: "order_by", value: "name"), URLQueryItem(name: "per_page", value: "100")])
    }

    func testCreateAssignmentRequest() {
        let assignment = APIAssignmentParameters(
            name: "A",
            description: "d",
            points_possible: 10,
            due_at: Date(),
            submission_types: [SubmissionType.online_upload],
            allowed_extensions: ["pdf"],
            published: true,
            grading_type: .percent,
            lock_at: nil,
            unlock_at: nil
        )
        let expectedBody = PostAssignmentRequest.Body(assignment: assignment)
        let request = PostAssignmentRequest(courseID: "1", body: expectedBody)

        XCTAssertEqual(request.path, "courses/1/assignments")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, expectedBody)
    }
}
