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

import Foundation
import XCTest
@testable import Core

class SubmissionCommentAccessibilityTests: CoreTestCase {

    private enum TestConstants {
        static let date = Date.make(year: 2048, month: 05, day: 06)
        static let fileSize = 589824
    }

    // MARK: - Label for header

    func test_labelForHeader_whenCommentIsForAttempt() {
        let comment = makeComment(
            attempt: 7,
            authorName: "Some Author",
            createdAt: TestConstants.date,
            comment: "This is ignored"
        )

        XCTAssertEqual(
            comment.accessibilityLabelForHeader,
            "Attempt 7, Submitted by Some Author, on \(TestConstants.date.dateTimeString)"
        )
    }

    func test_labelForHeader_whenCommentIsAudio() {
        let comment = makeComment(
            attempt: nil,
            authorName: "Some Author",
            createdAt: TestConstants.date,
            comment: "Comment text to be ignored",
            mediaType: .audio,
            mediaURL: .make()
        )

        XCTAssertEqual(
            comment.accessibilityLabelForHeader,
            "Some Author left an audio comment on \(TestConstants.date.dateTimeString)"
        )
    }

    func test_labelForHeader_whenCommentIsVideo() {
        let comment = makeComment(
            attempt: nil,
            authorName: "Some Author",
            createdAt: TestConstants.date,
            comment: "Comment text to be ignored",
            mediaType: .video,
            mediaURL: .make()
        )

        XCTAssertEqual(
            comment.accessibilityLabelForHeader,
            "Some Author left a video comment on \(TestConstants.date.dateTimeString)"
        )
    }

    func test_labelForHeader_whenCommentHasNoMediaURL_shouldBehaveAsTextComment() {
        let comment = makeComment(
            attempt: nil,
            authorName: "Some Author",
            createdAt: TestConstants.date,
            comment: "Comment text to be included",
            mediaType: .video,
            mediaURL: nil
        )

        XCTAssertEqual(
            comment.accessibilityLabelForHeader,
            "Some Author commented on \(TestConstants.date.dateTimeString): Comment text to be included"
        )
    }

    func test_labelForHeader_whenCommentIsText() {
        let comment = makeComment(
            attempt: nil,
            authorName: "Some Author",
            createdAt: TestConstants.date,
            comment: "Comment text to be included"
        )

        XCTAssertEqual(
            comment.accessibilityLabelForHeader,
            "Some Author commented on \(TestConstants.date.dateTimeString): Comment text to be included"
        )
    }

    // MARK: - Label for Attempt

    func test_labelForAttempt_whenAttemptIsText() {
        let comment = makeComment(attempt: 42, authorName: "To be ignored", comment: "To be ignored")
        let submission = makeSubmission(attempt: 7, type: .online_text_entry)
        submission.body = "Some submission text"

        XCTAssertEqual(
            comment.accessibilityLabelForAttempt(submission: submission),
            "Attempt 7, Text Entry, Some submission text"
        )
    }

    func test_labelForAttempt_whenAttemptIsExternalTool() {
        let comment = makeComment()
        let submission = makeSubmission(attempt: 7, type: .external_tool)

        XCTAssertEqual(
            comment.accessibilityLabelForAttempt(submission: submission),
            "Attempt 7, External Tool"
        )
    }

    // MARK: - Label for Attachment

    func test_labelForCommentAttachment() {
        let comment = makeComment(attempt: 42, authorName: "To be ignored", comment: "To be ignored")
        let file = makeFile(displayName: "Some file name", size: TestConstants.fileSize)

        XCTAssertEqual(
            comment.accessibilityLabelForCommentAttachment(file),
            "Attached file, Some file name, \(TestConstants.fileSize.humanReadableFileSize)"
        )
    }

    func test_labelForAttemptAttachment() {
        let comment = makeComment(attempt: 42, authorName: "author", comment: "Comment text")
        let file = makeFile(displayName: "Some file name", size: TestConstants.fileSize)
        let submission = makeSubmission(attempt: 7, type: .online_upload)

        XCTAssertEqual(
            comment.accessibilityLabelForAttemptAttachment(file, submission: submission),
            "Attempt 7, File Upload, Some file name, \(TestConstants.fileSize.humanReadableFileSize)"
        )
    }

    // MARK: - Private helpers

    private func makeComment(
        attempt: Int? = nil,
        authorName: String = "",
        createdAt: Date? = nil,
        comment commentString: String = "",
        mediaType: MediaCommentType? = nil,
        mediaURL: URL? = nil
    ) -> SubmissionComment {
        let comment = SubmissionComment.save(.make(), for: .make(), in: databaseClient)
        if let attempt {
            comment.id = "submission-1-\(attempt)"
        }
        comment.authorName = authorName
        comment.createdAt = createdAt
        comment.comment = commentString
        comment.mediaType = mediaType
        comment.mediaURL = mediaURL
        return comment
    }

    private func makeSubmission(
        attempt: Int = 0,
        type: SubmissionType? = nil
    ) -> Submission {
        let submission = Submission.save(.make(), in: databaseClient)
        submission.attempt = attempt
        submission.type = type
        return submission
    }

    private func makeFile(
        displayName: String? = nil,
        size: Int = 0
    ) -> File {
        let file = File.save(.make(), to: nil, in: databaseClient)
        file.displayName = displayName
        file.size = size
        return file
    }
}
