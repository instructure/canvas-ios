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

class APISubmissionTests: CoreTestCase {
    func testGetSubmissionRequest() {
        XCTAssertEqual(GetSubmissionRequest(context: .course("1"), assignmentID: "2", userID: "3").path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(GetSubmissionRequest(context: .course("1"), assignmentID: "2", userID: "3").query, [ APIQueryItem.array("include", [
            "submission_comments",
            "submission_history",
            "user",
            "rubric_assessment",
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
        let request = CreateSubmissionRequest(context: .course("1"), assignmentID: "2", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
        XCTAssertEqual(request.body?.comment?.text_comment, "a comment")
    }

    func testPutSubmissionGradeRequest() {
        let submission = PutSubmissionGradeRequest.Body.Submission(posted_grade: "10")
        let body = PutSubmissionGradeRequest.Body(comment: nil, submission: submission)
        let request = PutSubmissionGradeRequest(courseID: "1", assignmentID: "2", userID: "3", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, body)
    }

    func testPutSubmissionGradeRequestComment() {
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(text: "comment").text_comment, "comment")
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(mediaID: "1", type: .audio, forGroup: true).text_comment, "This is a media comment")
        XCTAssertNil(PutSubmissionGradeRequest.Body.Comment(mediaID: "1", type: .audio).text_comment)
    }

    func testGetSubmissionsRequest() {
        XCTAssertEqual(
            GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: nil, include: []).path,
            "courses/1/assignments/2/submissions"
        )
        XCTAssertEqual(
            GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: false, include: []).queryItems,
            [
                URLQueryItem(name: "grouped", value: "false"),
            ]
        )
        XCTAssertEqual(
            GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: true, include: []).queryItems,
            [
                URLQueryItem(name: "grouped", value: "true"),
            ]
        )
        XCTAssertEqual(
            GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: true, include: GetSubmissionsRequest.Include.allCases).queryItems,
            [
                URLQueryItem(name: "include[]", value: "rubric_assessment"),
                URLQueryItem(name: "include[]", value: "submission_comments"),
                URLQueryItem(name: "include[]", value: "submission_history"),
                URLQueryItem(name: "include[]", value: "total_scores"),
                URLQueryItem(name: "include[]", value: "user"),
                URLQueryItem(name: "include[]", value: "group"),
                URLQueryItem(name: "grouped", value: "true"),
            ]
        )
    }

    func testGetRecentlyGradedSubmissionsRequest() {
        let request = GetRecentlyGradedSubmissionsRequest(userID: "self")
        XCTAssertEqual(request.path, "users/self/graded_submissions")
        XCTAssertEqual(request.query, [
            .perPage(3),
            .include(["assignment"]),
            .bool("only_current_submissions", true),
        ])
    }

    func testGetSubmissionSummaryRequest() {
        let req = GetSubmissionSummaryRequest(context: .course("1"), assignmentID: "2")
        XCTAssertEqual(req.path, "courses/1/assignments/2/submission_summary")
    }
}
