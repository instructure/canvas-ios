//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
@testable import Core

class GetSubmissionCommentsTests: CoreTestCase {
    func testItCreatesSubmission() {
        let context = Context(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3"
        )

        let getSubmission = GetSubmissionComments(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testItCreatesSubmissionComments() {
        let context = Context(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            attempt: 2,
            submission_comments: [
                APISubmissionComment.make(id: "1"),
                APISubmissionComment.make(id: "2")
            ],
            submission_history: [
                APISubmission.make(assignment_id: "2", attempt: 2, submission_type: .online_text_entry, user_id: "3"),
                APISubmission.make(assignment_id: "2", attempt: 1, submission_type: .online_text_entry, user_id: "3")
            ],
            submission_type: .online_text_entry,
            user_id: "3"
        )
        let getSubmission = GetSubmissionComments(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let comments: [SubmissionComment] = databaseClient.fetch()
        XCTAssertEqual(comments.count, 4)
        XCTAssertEqual(comments.first?.userID, apiSubmission.user_id.value)
    }

    func testCacheKey() {
        let getSubmission = GetSubmissionComments(context: .course("1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.cacheKey, "get-1-2-3-submission")
    }

    func testRequest() {
        let getSubmission = GetSubmissionComments(context: .course("1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.request.path, "courses/1/assignments/2/submissions/3")
    }

    func testScope() {
        let getSubmission = GetSubmissionComments(context: .course("1"), assignmentID: "2", userID: "3")
        let scope = Scope(
            predicate: NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(SubmissionComment.assignmentID),
                "2",
                #keyPath(SubmissionComment.userID),
                "3"
            ),
            order: [NSSortDescriptor(key: #keyPath(SubmissionComment.createdAt), ascending: false)]
        )
        XCTAssertEqual(getSubmission.scope, scope)
    }
}
