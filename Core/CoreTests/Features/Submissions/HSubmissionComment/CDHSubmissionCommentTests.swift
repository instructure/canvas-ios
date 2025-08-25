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

        let attachment1 = GetHSubmissionCommentsResponse.Attachment(
            id: "attachment-1",
            url: "https://example.com/file1.pdf",
            displayName: "file1.pdf"
        )
        let attachment2 = GetHSubmissionCommentsResponse.Attachment(
            id: "attachment-2",
            url: "https://example.com/file2.jpg",
            displayName: "file2.jpg"
        )

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
            attachments: [attachment1, attachment2]
        )

        let savedComment = CDHSubmissionComment.save(comment, assignmentID: assignmentId, in: databaseClient)

        XCTAssertEqual(savedComment.id, commentId)
        XCTAssertEqual(savedComment.attempt, attempt)
        XCTAssertEqual(savedComment.authorID, authorId)
        XCTAssertEqual(savedComment.authorName, authorName)
        XCTAssertEqual(savedComment.comment, commentText)
        XCTAssertEqual(savedComment.createdAt, createdAt)
        XCTAssertEqual(savedComment.isRead, true)

        let attachments = savedComment.attachments ?? []
        XCTAssertEqual(attachments.count, 2)

        let savedAttachments = attachments.sorted { $0.id < $1.id }
        XCTAssertEqual(savedAttachments[0].id, "attachment-1")
        XCTAssertEqual(savedAttachments[0].url, "https://example.com/file1.pdf")
        XCTAssertEqual(savedAttachments[0].displayName, "file1.pdf")
        XCTAssertEqual(savedAttachments[1].id, "attachment-2")
        XCTAssertEqual(savedAttachments[1].url, "https://example.com/file2.jpg")
        XCTAssertEqual(savedAttachments[1].displayName, "file2.jpg")
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
        XCTAssertEqual(savedComment.attachments?.count ?? 0, 0)
    }

    func testSaveExistingComment() {
        let attachment1 = GetHSubmissionCommentsResponse.Attachment(
            id: "attachment-1",
            url: "https://example.com/file1.pdf",
            displayName: "file1.pdf"
        )

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
            attachments: [attachment1]
        )

        let savedComment1 = CDHSubmissionComment.save(comment1, assignmentID: "assignment-123", in: databaseClient)

        let attachment2 = GetHSubmissionCommentsResponse.Attachment(
            id: "attachment-2",
            url: "https://example.com/file2.jpg",
            displayName: "file2.jpg"
        )

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
            attachments: [attachment2]
        )

        let savedComment2 = CDHSubmissionComment.save(comment2, assignmentID: "assignment-123", in: databaseClient)

        XCTAssertEqual(savedComment1, savedComment2)
        XCTAssertEqual(savedComment2.id, "comment-123")
        XCTAssertEqual(savedComment2.attempt, 2)
        XCTAssertEqual(savedComment2.authorID, "author-2")
        XCTAssertEqual(savedComment2.authorName, "Author 2")
        XCTAssertEqual(savedComment2.comment, "Updated comment")
        XCTAssertEqual(savedComment2.isRead, false)

        let attachments = savedComment2.attachments ?? []
        XCTAssertEqual(attachments.count, 1)

        let savedAttachment = attachments.first
        XCTAssertEqual(savedAttachment?.id, "attachment-2")
        XCTAssertEqual(savedAttachment?.url, "https://example.com/file2.jpg")
        XCTAssertEqual(savedAttachment?.displayName, "file2.jpg")
    }

    func testAttemptProperty() {
        let comment = databaseClient.insert() as CDHSubmissionComment

        comment.attemptFromAPI = nil
        XCTAssertNil(comment.attempt)

        comment.attemptFromAPI = NSNumber(value: 5)
        XCTAssertEqual(comment.attempt, 5)
    }
}
