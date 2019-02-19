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
        let request = GetSubmissionRequest(context: context, assignmentID: "2", userID: "3")
        let apiSubmission = APISubmission.make([
            "assignment_id": "2",
            "user_id": "3",
        ])
        api.mock(request, value: apiSubmission, response: nil, error: nil)

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3", env: environment)
        addOperationAndWait(getSubmission)

        XCTAssertEqual(getSubmission.errors.count, 0)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testItCreatesSubmissionHistory() {
        let context = ContextModel(.course, id: "1")
        let request = GetSubmissionRequest(context: context, assignmentID: "2", userID: "3")
        let apiSubmission = APISubmission.make([
            "attempt": 2,
            "assignment_id": "2",
            "user_id": "3",
            "submission_history": [
                APISubmission.fixture([ "attempt": 2, "assignment_id": "2", "user_id": "3" ]),
                APISubmission.fixture([ "attempt": 1, "assignment_id": "2", "user_id": "3" ]),
            ],
        ])
        api.mock(request, value: apiSubmission, response: nil, error: nil)

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3", env: environment)
        addOperationAndWait(getSubmission)

        XCTAssertEqual(getSubmission.errors.count, 0)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testNoHistoryDoesntDelete() {
        let context = ContextModel(.course, id: "1")
        let request = GetSubmissionRequest(context: context, assignmentID: "2", userID: "3")
        Submission.make([ "attempt": 2, "assignmentID": "2", "userID": "3", "late": false ])
        Submission.make([ "attempt": 1, "assignmentID": "2", "userID": "3" ])
        let apiSubmission = APISubmission.make([
            "attempt": 2,
            "assignment_id": "2",
            "user_id": "3",
            "late": true,
        ])
        api.mock(request, value: apiSubmission, response: nil, error: nil)

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3", env: environment)
        addOperationAndWait(getSubmission)

        XCTAssertEqual(getSubmission.errors.count, 0)
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first(where: { $0.attempt == 2 })!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
        XCTAssertEqual(submission.late, true)
    }
}
