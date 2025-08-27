//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class CreateSubmissionRequestTests: CoreTestCase {

    func testCreateSubmissionRequest() {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: "a comment",
            group_comment: nil,
            submission_type: .online_text_entry,
            body: "yo",
            url: nil,
            file_ids: nil,
            media_comment_id: nil,
            media_comment_type: nil
        )
        let body = CreateSubmissionRequest.Body(submission: submission)
        let request = CreateSubmissionRequest(context: .course("1"), assignmentID: "2", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
        XCTAssertEqual(request.body?.comment?.text_comment, "a comment")
        XCTAssertEqual(request.body?.submission.group_comment, false)
        XCTAssertEqual(request.body?.submission.comment, nil)
    }

    func testCreateGroupSubmissionRequest() {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: "a comment",
            group_comment: true,
            submission_type: .online_text_entry,
            body: "yo",
            url: nil,
            file_ids: nil,
            media_comment_id: nil,
            media_comment_type: nil
        )
        let body = CreateSubmissionRequest.Body(submission: submission)
        let request = CreateSubmissionRequest(context: .course("1"), assignmentID: "2", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
        XCTAssertEqual(request.body?.comment?.text_comment, nil)
        XCTAssertEqual(request.body?.submission.group_comment, true)
        XCTAssertEqual(request.body?.submission.comment, "a comment")
    }
}
