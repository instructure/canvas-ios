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
            "group"
        ]) ])
    }

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

    func testPutSubmissionGradeRequest() {
        let submission = PutSubmissionGradeRequest.Body.Submission(excuse: nil, posted_grade: "10", seconds_late_override: nil)
        let body = PutSubmissionGradeRequest.Body(comment: nil, submission: submission)
        let request = PutSubmissionGradeRequest(courseID: "1", assignmentID: "2", userID: "3", body: body)

        XCTAssertEqual(request.path, "courses/1/assignments/2/submissions/3")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, body)
    }

    func testPutSubmissionGradeRequestComment() {
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(text: "comment", attempt: nil).text_comment, "comment")
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(mediaID: "1", type: .audio, forGroup: true, attempt: nil).text_comment, "This is a media comment")
        XCTAssertEqual(PutSubmissionGradeRequest.Body.Comment(mediaID: "1", type: .audio, attempt: nil).text_comment, "")
    }

    func testGetSubmissionsRequest() {
        XCTAssertEqual(
            GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: nil, include: []).path,
            "courses/1/assignments/2/submissions"
        )
        XCTAssertEqual(GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: false, include: []).query, [
            .perPage(100),
            .include([]),
            .bool("grouped", false)
        ])
        XCTAssertEqual(GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: true, include: []).query, [
            .perPage(100),
            .include([]),
            .bool("grouped", true)
        ])
        XCTAssertEqual(GetSubmissionsRequest(context: .course("1"), assignmentID: "2", grouped: true, include: GetSubmissionsRequest.Include.allCases).query, [
            .perPage(100),
            .include([
                "rubric_assessment",
                "submission_comments",
                "submission_history",
                "total_scores",
                "user",
                "group",
                "assignment"
            ]),
            .bool("grouped", true)
        ])
    }

    func testGetRecentlyGradedSubmissionsRequest() {
        let request = GetRecentlyGradedSubmissionsRequest(userID: "self")
        XCTAssertEqual(request.path, "users/self/graded_submissions")
        XCTAssertEqual(request.query, [
            .perPage(3),
            .include(["assignment"]),
            .bool("only_current_submissions", true)
        ])
    }

    func testGetSubmissionSummaryRequest() {
        let req = GetSubmissionSummaryRequest(context: .course("1"), assignmentID: "2")
        XCTAssertEqual(req.path, "courses/1/assignments/2/submission_summary")
    }

    func testDecodeAPITurnItInData() {
        let json: Any = [
            "eula_agreement_timestamp": "123456",
            "attachment_1": [
                "status": "scored",
                "similarity_score": 0,
                "outcome_response": [
                    "outcomes_tool_placement_url": "https://canvas.instructure.com/tool/1"
                ]
            ],
            "submission_1": [
                "status": "scored"
            ]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        let turnItInData = try! JSONDecoder().decode(APITurnItInData.self, from: data)
        XCTAssertEqual(turnItInData.rawValue.keys.count, 2)
        XCTAssertEqual(turnItInData.rawValue["attachment_1"]?.status, "scored")
        XCTAssertEqual(turnItInData.rawValue["attachment_1"]?.similarity_score, 0)
        XCTAssertEqual(
            turnItInData.rawValue["attachment_1"]?.outcome_response?.outcomes_tool_placement_url?.rawValue.absoluteString,
            "https://canvas.instructure.com/tool/1"
        )
        XCTAssertEqual(turnItInData.rawValue["submission_1"]?.status, "scored")
    }

    func testSubmissionGroupDecode() {
        let json = """
            {
                "id": "28302",
                "assignment_id": "6799",
                "grade_matches_current_submission": true,
                "group": {
                    "id": "284",
                    "name": "Assignment 2"
                },
                "user_id": "12166",
                "workflow_state": "submitted"
            }
        """

        let testee = try? JSONDecoder().decode(APISubmission.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(testee?.group?.id?.value, "284")
        XCTAssertEqual(testee?.group?.name, "Assignment 2")
    }

    func testDecodesCommentAuthorWithSpaceInAvatarURL() {
        let json = """
            {
                "id": "1503",
                "display_name": "Test User",
                "avatar_image_url": "https://test.com/profile pic.jpg",
                "html_url": "https://test.com/courses/1/users/1",
                "pronouns": null
            }
        """

        let testee = try? JSONDecoder().decode(APISubmissionCommentAuthor.self, from: json.data(using: .utf8)!)
        XCTAssertNotNil(testee)
    }
}
