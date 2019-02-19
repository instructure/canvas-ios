//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core

class APISubmissionRequestableTests: CoreTestCase {
    func testGetSubmissionRequest() {
        XCTAssertEqual(GetSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3").path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(GetSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3").query, [ APIQueryItem.array("include", [
            "submission_history",
        ]), ])
    }

    func testCreateSubmissionRequest() {
        let submission = CreateSubmissionRequest.Body.Submission(
            text_comment: "a comment",
            submission_type: .online_text_entry,
            body: "yo",
            url: nil,
            file_ids: nil,
            media_comment_id: nil,
            media_comment_type: nil
        )
        let body = CreateSubmissionRequest.Body(submission: submission)
        let request = CreateSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "2", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
        XCTAssertEqual(request.body?.submission.text_comment, "a comment")
    }

    func testGradeSubmissionRequest() {
        let submission = PutSubmissionGradeRequest.Body.Submission(posted_grade: "10")
        let body = PutSubmissionGradeRequest.Body(submission: submission)
        let request = PutSubmissionGradeRequest(courseID: "1", assignmentID: "2", userID: "3", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, body)
    }
}
