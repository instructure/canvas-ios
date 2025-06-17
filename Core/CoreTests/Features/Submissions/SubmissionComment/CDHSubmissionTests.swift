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
import Foundation
import XCTest

class CDHSubmissionTests: CoreTestCase {
    func testSave() {
        let submissionId = "submission-123"
        let assignmentId = "assignment-456"
        let unreadCount = 3

        let comment = GetHSubmissionCommentsResponse.Comment(
            id: "comment-1",
            attempt: 2,
            author: GetHSubmissionCommentsResponse.Author(
                id: "author-1",
                avatarURL: "https://example.com/avatar.jpg",
                shortName: "Test Author"
            ),
            comment: "This is a test comment",
            read: false,
            updatedAt: Date(),
            createdAt: Date()
        )

        let edge = GetHSubmissionCommentsResponse.Edge(node: comment)

        let connection = GetHSubmissionCommentsResponse.CommentsConnection(
            pageInfo: nil,
            edges: [edge]
        )

        let submission = GetHSubmissionCommentsResponse.Submission(
            unreadCommentCount: unreadCount,
            id: submissionId,
            commentsConnection: connection
        )

        let dataModel = GetHSubmissionCommentsResponse.DataModel(submission: submission)

        let response = GetHSubmissionCommentsResponse(data: dataModel)

        let savedSubmission = CDHSubmission.save(response, assignmentID: assignmentId, in: databaseClient)

        XCTAssertEqual(savedSubmission.id, submissionId)
        XCTAssertEqual(savedSubmission.assignmentID, assignmentId)
        XCTAssertEqual(savedSubmission.hasUnreadComment, true)
        XCTAssertEqual(savedSubmission.comments.count, 1)

        let savedComment = savedSubmission.comments.first
        XCTAssertEqual(savedComment?.id, "comment-1")
        XCTAssertEqual(savedComment?.attempt, 2)
        XCTAssertEqual(savedComment?.authorID, "author-1")
        XCTAssertEqual(savedComment?.authorName, "Test Author")
        XCTAssertEqual(savedComment?.comment, "This is a test comment")
        XCTAssertEqual(savedComment?.isRead, false)
    }

    func testSaveWithEmptyData() {
        let response = GetHSubmissionCommentsResponse(data: nil)

        let savedSubmission = CDHSubmission.save(response, assignmentID: "assignment-123", in: databaseClient)

        XCTAssertEqual(savedSubmission.id, "")
        XCTAssertEqual(savedSubmission.assignmentID, "assignment-123")
        XCTAssertEqual(savedSubmission.hasUnreadComment, false)
        XCTAssertTrue(savedSubmission.comments.isEmpty)
    }

    func testSaveWithNoComments() {
        let submission = GetHSubmissionCommentsResponse.Submission(
            unreadCommentCount: 0,
            id: "submission-123",
            commentsConnection: nil
        )

        let response = GetHSubmissionCommentsResponse(
            data: GetHSubmissionCommentsResponse.DataModel(submission: submission)
        )

        let savedSubmission = CDHSubmission.save(response, assignmentID: "assignment-123", in: databaseClient)

        XCTAssertEqual(savedSubmission.id, "submission-123")
        XCTAssertEqual(savedSubmission.assignmentID, "assignment-123")
        XCTAssertEqual(savedSubmission.hasUnreadComment, false)
        XCTAssertTrue(savedSubmission.comments.isEmpty)
    }
}
