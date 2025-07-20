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

class CDHSubmissionCommentTests: CoreTestCase {
    func testSave() {
        let commentId = "comment-123"
        let authorId = "author-456"
        let authorName = "Test Author"
        let commentText = "This is a test comment"
        let createdAt = Date()
        let assignmentId = "assignment-789"
        let attempt = 3

        let comment = GetHSubmissionCommentsResponse.Comment(
            id: commentId,
            attempt: attempt,
            author: GetHSubmissionCommentsResponse.Author(
                id: authorId,
                avatarURL: "https://example.com/avatar.jpg",
                shortName: authorName
            ),
            comment: commentText,
            read: true,
            updatedAt: createdAt,
            createdAt: createdAt,
            attachments: nil
        )

        let savedComment = CDHSubmissionComment.save(comment, assignmentID: assignmentId, in: databaseClient)

        XCTAssertEqual(savedComment.id, commentId)
        XCTAssertEqual(savedComment.attempt, attempt)
        XCTAssertEqual(savedComment.authorID, authorId)
        XCTAssertEqual(savedComment.authorName, authorName)
        XCTAssertEqual(savedComment.comment, commentText)
        XCTAssertEqual(savedComment.createdAt, createdAt)
        XCTAssertEqual(savedComment.isRead, true)
    }

    func testSaveWithNilData() {
        let savedComment = CDHSubmissionComment.save(nil, assignmentID: "assignment-123", in: databaseClient)

        XCTAssertEqual(savedComment.id, "")
        XCTAssertNil(savedComment.attempt)
        XCTAssertNil(savedComment.authorID)
        XCTAssertNil(savedComment.authorName)
        XCTAssertNil(savedComment.comment)
        XCTAssertNil(savedComment.createdAt)
        XCTAssertEqual(savedComment.isRead, true)
    }

    func testSaveExistingComment() {
        let comment1 = GetHSubmissionCommentsResponse.Comment(
            id: "comment-123",
            attempt: 1,
            author: GetHSubmissionCommentsResponse.Author(
                id: "author-1",
                avatarURL: "https://example.com/avatar.jpg",
                shortName: "Author 1"
            ),
            comment: "First comment",
            read: true,
            updatedAt: Date(),
            createdAt: Date(),
            attachments: nil
        )

        let savedComment1 = CDHSubmissionComment.save(comment1, assignmentID: "assignment-123", in: databaseClient)

        let comment2 = GetHSubmissionCommentsResponse.Comment(
            id: "comment-123",
            attempt: 2,
            author: GetHSubmissionCommentsResponse.Author(
                id: "author-2",
                avatarURL: "https://example.com/avatar2.jpg",
                shortName: "Author 2"
            ),
            comment: "Updated comment",
            read: false,
            updatedAt: Date(),
            createdAt: Date(),
            attachments: nil
        )

        let savedComment2 = CDHSubmissionComment.save(comment2, assignmentID: "assignment-123", in: databaseClient)

        XCTAssertEqual(savedComment1, savedComment2) // Should be the same object
        XCTAssertEqual(savedComment2.id, "comment-123")
        XCTAssertEqual(savedComment2.attempt, 2)
        XCTAssertEqual(savedComment2.authorID, "author-2")
        XCTAssertEqual(savedComment2.authorName, "Author 2")
        XCTAssertEqual(savedComment2.comment, "Updated comment")
        XCTAssertEqual(savedComment2.isRead, false)
    }

    func testAttemptProperty() {
        let comment = databaseClient.insert() as CDHSubmissionComment

        comment.attemptFromAPI = nil
        XCTAssertNil(comment.attempt)

        comment.attemptFromAPI = NSNumber(value: 5)
        XCTAssertEqual(comment.attempt, 5)
    }
}
