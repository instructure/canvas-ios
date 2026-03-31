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

class PutSubmissionGradeRequestTests: CoreTestCase {

    func testPutSubmissionGradeRequest() {
        let submission = PutSubmissionGradeRequest.Body.Submission(excuse: nil, posted_grade: "10", seconds_late_override: nil)
        let body = PutSubmissionGradeRequest.Body(comment: nil, submission: submission)
        let request = PutSubmissionGradeRequest(courseID: "1", assignmentID: "2", userID: "3", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, body)
    }

    func testPutSubmissionGradeRequestLatePolicy() {
        var submission = PutSubmissionGradeRequest.Body.Submission(excuse: nil, posted_grade: "10", seconds_late_override: nil)
        XCTAssertNil(submission.late_policy_status)

        submission = PutSubmissionGradeRequest.Body.Submission(excuse: nil, posted_grade: "10", seconds_late_override: -1)
        XCTAssertNil(submission.late_policy_status)

        let days = 3 * 24 * 3600
        submission = PutSubmissionGradeRequest.Body.Submission(excuse: nil, posted_grade: "10", seconds_late_override: days)
        XCTAssertEqual(submission.late_policy_status, "late")
    }

    func testPutSubmissionGradeRequestComment() {
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(text: "comment", attempt: nil).text_comment, "comment")
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(mediaID: "1", type: .audio, forGroup: true, attempt: nil).text_comment, "This is a media comment")
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(mediaID: "1", type: .audio, attempt: nil).text_comment, "")
    }
}
