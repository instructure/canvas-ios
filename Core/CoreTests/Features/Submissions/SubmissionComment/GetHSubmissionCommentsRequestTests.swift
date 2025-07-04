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

class GetHSubmissionCommentsRequestTests: CoreTestCase {
    func testInit() {
        let assignmentId = "assignment-123"
        let userId = "user-456"
        let request = GetHSubmissionCommentsRequest(assignmentId: assignmentId, userId: userId, forAttempt: 1, beforeCursor: "NDI", last: 5)

        XCTAssertEqual(request.variables.assignmentId, assignmentId)
        XCTAssertEqual(request.variables.userId, userId)
    }

    func testInputEquality() {
        let input1 = GetHSubmissionCommentsRequest.Input(userId: "user-1", assignmentId: "assignment-1", forAttempt: 1, beforeCursor: "NDI", last: 5)
        let input2 = GetHSubmissionCommentsRequest.Input(userId: "user-1", assignmentId: "assignment-1", forAttempt: 2, beforeCursor: "MDE", last: 5)
        let input3 = GetHSubmissionCommentsRequest.Input(userId: "user-2", assignmentId: "assignment-1", forAttempt: 3, beforeCursor: "CGE", last: 5)

        XCTAssertEqual(input1, input2)
        XCTAssertNotEqual(input1, input3)
    }

    func testQueryContainsExpectedFields() {
        let query = GetHSubmissionCommentsRequest.query

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
        let input = GetHSubmissionCommentsRequest.Input(userId: "user-123", assignmentId: "assignment-456", forAttempt: 10, beforeCursor: nil, last: nil)

        let encoder = JSONEncoder()
        let data = try encoder.encode(input)

        let decoder = JSONDecoder()
        let decodedInput = try decoder.decode(GetHSubmissionCommentsRequest.Input.self, from: data)

        XCTAssertEqual(decodedInput.userId, "user-123")
        XCTAssertEqual(decodedInput.assignmentId, "assignment-456")
        XCTAssertEqual(decodedInput.forAttempt, 10)
    }
}
