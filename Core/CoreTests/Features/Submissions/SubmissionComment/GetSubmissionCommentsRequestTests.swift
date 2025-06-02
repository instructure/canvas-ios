//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class GetSubmissionCommentsRequestTests: CoreTestCase {
    func testInit() {
        let assignmentId = "assignment-123"
        let userId = "user-456"
        let request = GetSubmissionCommentsRequest(assignmentId: assignmentId, userId: userId)

        XCTAssertEqual(request.variables.assignmentId, assignmentId)
        XCTAssertEqual(request.variables.userId, userId)
    }

    func testInputEquality() {
        let input1 = GetSubmissionCommentsRequest.Input(userId: "user-1", assignmentId: "assignment-1")
        let input2 = GetSubmissionCommentsRequest.Input(userId: "user-1", assignmentId: "assignment-1")
        let input3 = GetSubmissionCommentsRequest.Input(userId: "user-2", assignmentId: "assignment-1")

        XCTAssertEqual(input1, input2)
        XCTAssertNotEqual(input1, input3)
    }

    func testQueryContainsExpectedFields() {
        let query = GetSubmissionCommentsRequest.query

        XCTAssertTrue(query.contains("query GetSubmissionComments($assignmentId: ID!, $userId: ID!)"))
        XCTAssertTrue(query.contains("submission(assignmentId: $assignmentId, userId: $userId)"))
        XCTAssertTrue(query.contains("id: _id"))
        XCTAssertTrue(query.contains("unreadCommentCount"))
        XCTAssertTrue(query.contains("commentsConnection(sortOrder: asc, filter:{allComments: true})"))
        XCTAssertTrue(query.contains("pageInfo"))
        XCTAssertTrue(query.contains("edges"))
        XCTAssertTrue(query.contains("node"))
        XCTAssertTrue(query.contains("attempt"))
        XCTAssertTrue(query.contains("author"))
        XCTAssertTrue(query.contains("comment"))
        XCTAssertTrue(query.contains("read"))
        XCTAssertTrue(query.contains("createdAt"))
    }

    func testCodingInput() throws {
        let input = GetSubmissionCommentsRequest.Input(userId: "user-123", assignmentId: "assignment-456")

        let encoder = JSONEncoder()
        let data = try encoder.encode(input)

        let decoder = JSONDecoder()
        let decodedInput = try decoder.decode(GetSubmissionCommentsRequest.Input.self, from: data)

        XCTAssertEqual(decodedInput.userId, "user-123")
        XCTAssertEqual(decodedInput.assignmentId, "assignment-456")
    }
}
