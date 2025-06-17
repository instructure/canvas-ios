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

class GetHSubmissionCommentsUseCaseTests: CoreTestCase {
    func testInit() {
        let useCase = GetHSubmissionCommentsUseCase(userId: "user-123", assignmentId: "assignment-456")

        XCTAssertEqual(useCase.request.variables.userId, "user-123")
        XCTAssertEqual(useCase.request.variables.assignmentId, "assignment-456")
    }

    func testCacheKey() {
        let useCase = GetHSubmissionCommentsUseCase(userId: "user-123", assignmentId: "assignment-456")

        XCTAssertEqual(useCase.cacheKey, "Submission-assignment-456-user-123-Comments")
    }

    func testScope() {
        let useCase = GetHSubmissionCommentsUseCase(userId: "user-123", assignmentId: "assignment-456")

        let expectedScope = Scope.where(#keyPath(CDHSubmission.assignmentID), equals: "assignment-456")

        XCTAssertEqual(useCase.scope, expectedScope)
    }

    func testWriteWithValidResponse() {
        let comment = GetHSubmissionCommentsResponse.Comment(
            id: "comment-1",
            attempt: 1,
            author: GetHSubmissionCommentsResponse.Author(
                id: "author-1",
                avatarURL: "https://example.com/avatar.jpg",
                shortName: "Test Author"
            ),
            comment: "This is a test comment",
            read: true,
            updatedAt: Date(),
            createdAt: Date()
        )

        let edge = GetHSubmissionCommentsResponse.Edge(node: comment)
        let connection = GetHSubmissionCommentsResponse.CommentsConnection(
            pageInfo: nil,
            edges: [edge]
        )

        let submission = GetHSubmissionCommentsResponse.Submission(
            unreadCommentCount: 0,
            id: "submission-123",
            commentsConnection: connection
        )

        let dataModel = GetHSubmissionCommentsResponse.DataModel(submission: submission)
        let response = GetHSubmissionCommentsResponse(data: dataModel)

        let useCase = GetHSubmissionCommentsUseCase(userId: "user-123", assignmentId: "assignment-456")

        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let submissions: [CDHSubmission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)

        let savedSubmission = submissions.first
        XCTAssertEqual(savedSubmission?.id, "submission-123")
        XCTAssertEqual(savedSubmission?.assignmentID, "assignment-456")
        XCTAssertEqual(savedSubmission?.comments.count, 1)

        let savedComment = savedSubmission?.comments.first
        XCTAssertEqual(savedComment?.id, "comment-1")
        XCTAssertEqual(savedComment?.comment, "This is a test comment")
    }

    func testWriteWithNilResponse() {
        let useCase = GetHSubmissionCommentsUseCase(userId: "user-123", assignmentId: "assignment-456")

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let submissions: [CDHSubmission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)
    }
}
