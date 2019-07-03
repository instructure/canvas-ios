//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        let request = GetAssignmentsRequest(courseID: "1")
        XCTAssertEqual(request.path, "courses/1/assignments?per_page=100")
        XCTAssertEqual(request.queryItems, [])
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
