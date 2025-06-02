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

class PutSubmissionCommentTests: CoreTestCase {
    func testInit() {
        let commentUseCase = PutSubmissionComment(
            courseID: "course-123",
            assignmentID: "assignment-456",
            userID: "user-789",
            text: "Test comment",
            isGroupComment: true,
            attempt: 2
        )

        XCTAssertEqual(commentUseCase.courseID, "course-123")
        XCTAssertEqual(commentUseCase.assignmentID, "assignment-456")
        XCTAssertEqual(commentUseCase.userID, "user-789")
        XCTAssertEqual(commentUseCase.text, "Test comment")
        XCTAssertEqual(commentUseCase.isGroupComment, true)
        XCTAssertEqual(commentUseCase.attempt, 2)
        XCTAssertNil(commentUseCase.cacheKey)
    }

    func testRequest() {
        let commentUseCase = PutSubmissionComment(
            courseID: "course-123",
            assignmentID: "assignment-456",
            userID: "user-789",
            text: "Test comment",
            isGroupComment: true,
            attempt: 2
        )

        let request = commentUseCase.request

        XCTAssertEqual(request.courseID, "course-123")
        XCTAssertEqual(request.assignmentID, "assignment-456")
        XCTAssertEqual(request.userID, "user-789")
        XCTAssertEqual(request.body?.comment?.text_comment, "Test comment")
        XCTAssertEqual(request.body?.comment?.group_comment, true)
        XCTAssertEqual(request.body?.comment?.attempt, 2)
    }

    func testWrite() {
        let commentUseCase = PutSubmissionComment(
            courseID: "course-123",
            assignmentID: "assignment-456",
            userID: "user-789",
            text: "Test comment",
            isGroupComment: false,
            attempt: nil
        )

        let apiSubmission = APISubmission.make(
            assignment_id: "assignment-456",
            submission_comments: [
                APISubmissionComment.make(
                    id: "comment-123",
                    author_id: "author-123",
                    author_name: "Test Author",
                    author: APISubmissionCommentAuthor.make(display_name: "Test Author"),
                    comment: "Test comment",
                    created_at: Date()
                )
            ],
            user_id: "user-789"
        )

        commentUseCase.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)

        let submission = submissions.first
        XCTAssertEqual(submission?.assignmentID, "assignment-456")
        XCTAssertEqual(submission?.userID, "user-789")

        let comments: [SubmissionComment] = databaseClient.fetch()
        XCTAssertEqual(comments.count, 1)

        let comment = comments.first
        XCTAssertEqual(comment?.id, "comment-123")
        XCTAssertEqual(comment?.authorID, "author-123")
        XCTAssertEqual(comment?.authorName, "Test Author")
        XCTAssertEqual(comment?.comment, "Test comment")
    }

    func testWriteWithNilResponse() {
        let commentUseCase = PutSubmissionComment(
            courseID: "course-123",
            assignmentID: "assignment-456",
            userID: "user-789",
            text: "Test comment",
            isGroupComment: false,
            attempt: nil
        )

        commentUseCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 0)

        let comments: [SubmissionComment] = databaseClient.fetch()
        XCTAssertEqual(comments.count, 0)
    }
}
