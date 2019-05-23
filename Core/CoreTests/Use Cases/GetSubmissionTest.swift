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

import XCTest
@testable import Core

class GetSubmissionTest: CoreTestCase {
    func testItCreatesSubmission() {
        let context = ContextModel(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3"
        )

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        try! getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testItCreatesSubmissionHistory() {
        let context = ContextModel(.course, id: "1")
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3",
            attempt: 2,
            submission_history: [
                APISubmission.make(assignment_id: "2", user_id: "3", attempt: 2),
                APISubmission.make(assignment_id: "2", user_id: "3", attempt: 1),
            ]
        )
        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        try! getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testNoHistoryDoesntDelete() {
        let context = ContextModel(.course, id: "1")
        Submission.make([ "attempt": 2, "assignmentID": "2", "userID": "3", "late": false ])
        Submission.make([ "attempt": 1, "assignmentID": "2", "userID": "3" ])
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3",
            late: true,
            attempt: 2
        )

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        try! getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first(where: { $0.attempt == 2 })!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
        XCTAssertEqual(submission.late, true)
    }

    func testCacheKey() {
        let getSubmission = GetSubmission(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.cacheKey, "get-1-2-3-submission")
    }

    func testRequest() {
        let getSubmission = GetSubmission(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3")
        XCTAssertEqual(getSubmission.request.path, "courses/1/assignments/2/submissions/3")
    }

    func testScope() {
        let getSubmission = GetSubmission(context: ContextModel(.course, id: "1"), assignmentID: "2", userID: "3")
        let scope = Scope(
            predicate: NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(Submission.assignmentID),
                "2",
                #keyPath(Submission.userID),
                "3"
            ),
            order: [NSSortDescriptor(key: #keyPath(Submission.attempt), ascending: false)]
        )
        XCTAssertEqual(getSubmission.scope, scope)
    }

}
