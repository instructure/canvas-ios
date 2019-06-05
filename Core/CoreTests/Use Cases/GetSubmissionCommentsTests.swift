//
// Copyright (C) 2019-present Instructure, Inc.
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

import XCTest
@testable import Core

class GetSubmissionCommentsTests: CoreTestCase {
    func testItCreatesSubmission() {
        let context = ContextModel(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3"
        )

        let getSubmission = GetSubmissionComments(context: context, assignmentID: "2", userID: "3", submissionID: apiSubmission.id.value)
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testItCreatesSubmissionComments() {
        let context = ContextModel(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3",
            attempt: 2,
            submission_comments: [
                APISubmissionComment.make(id: "1"),
                APISubmissionComment.make(id: "2"),
            ],
            submission_history: [
                APISubmission.make(assignment_id: "2", user_id: "3", submission_type: .online_text_entry, attempt: 2),
                APISubmission.make(assignment_id: "2", user_id: "3", submission_type: .online_text_entry, attempt: 1),
            ]
        )
        let getSubmission = GetSubmissionComments(context: context, assignmentID: "2", userID: "3", submissionID: apiSubmission.id.value)
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let comments: [SubmissionComment] = databaseClient.fetch()
        XCTAssertEqual(comments.count, 4)
        XCTAssertEqual(comments.first?.submissionID, apiSubmission.id.value)
    }

    func testCacheKey() {
        let getSubmission = GetSubmissionComments(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3", submissionID: "4")
        XCTAssertEqual(getSubmission.cacheKey, "get-1-2-3-submission")
    }

    func testRequest() {
        let getSubmission = GetSubmissionComments(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3", submissionID: "4")
        XCTAssertEqual(getSubmission.request.path, "courses/1/assignments/2/submissions/3")
    }

    func testScope() {
        let getSubmission = GetSubmissionComments(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3", submissionID: "4")
        let scope = Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(SubmissionComment.submissionID), "4"),
            order: [NSSortDescriptor(key: #keyPath(SubmissionComment.createdAt), ascending: false)]
        )
        XCTAssertEqual(getSubmission.scope, scope)
    }

}
