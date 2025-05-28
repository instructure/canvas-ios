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

class CDSubmissionTests: CoreTestCase {
    func testSave() {
        let submissionId = "submission-123"
        let assignmentId = "assignment-456"
        let unreadCount = 3

        let comment = GetSubmissionCommentsResponse.Comment(
            id: "comment-1",
            attempt: 2,
            author: GetSubmissionCommentsResponse.Author(
                id: "author-1",
                avatarURL: "https://example.com/avatar.jpg",
                shortName: "Test Author"
            ),
            comment: "This is a test comment",
            read: false,
            updatedAt: Date(),
            createdAt: Date()
        )

        let edge = GetSubmissionCommentsResponse.Edge(node: comment)

        let connection = GetSubmissionCommentsResponse.CommentsConnection(
            pageInfo: nil,
            edges: [edge]
        )

        let submission = GetSubmissionCommentsResponse.Submission(
            unreadCommentCount: unreadCount,
            id: submissionId,
            commentsConnection: connection
        )

        let dataModel = GetSubmissionCommentsResponse.DataModel(submission: submission)

        let response = GetSubmissionCommentsResponse(data: dataModel)

        let savedSubmission = CDSubmission.save(response, assignmentID: assignmentId, in: databaseClient)

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
        let response = GetSubmissionCommentsResponse(data: nil)

        let savedSubmission = CDSubmission.save(response, assignmentID: "assignment-123", in: databaseClient)

        XCTAssertEqual(savedSubmission.id, "")
        XCTAssertEqual(savedSubmission.assignmentID, "assignment-123")
        XCTAssertEqual(savedSubmission.hasUnreadComment, false)
        XCTAssertTrue(savedSubmission.comments.isEmpty)
    }

    func testSaveWithNoComments() {
        let submission = GetSubmissionCommentsResponse.Submission(
            unreadCommentCount: 0,
            id: "submission-123",
            commentsConnection: nil
        )

        let response = GetSubmissionCommentsResponse(
            data: GetSubmissionCommentsResponse.DataModel(submission: submission)
        )

        let savedSubmission = CDSubmission.save(response, assignmentID: "assignment-123", in: databaseClient)

        XCTAssertEqual(savedSubmission.id, "submission-123")
        XCTAssertEqual(savedSubmission.assignmentID, "assignment-123")
        XCTAssertEqual(savedSubmission.hasUnreadComment, false)
        XCTAssertTrue(savedSubmission.comments.isEmpty)
    }
}
