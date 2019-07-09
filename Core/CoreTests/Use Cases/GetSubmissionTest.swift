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
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

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
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 2)
        let submission = submissions.first!
        XCTAssertEqual(submission.assignmentID, "2")
        XCTAssertEqual(submission.userID, "3")
    }

    func testNoHistoryDoesntDelete() {
        let context = ContextModel(.course, id: "1")
        Submission.make(from: .make(assignment_id: "2", user_id: "3", late: false, attempt: 2))
        Submission.make(from: .make(assignment_id: "2", user_id: "3", attempt: 1))
        let apiSubmission = APISubmission.make(
            assignment_id: "2",
            user_id: "3",
            late: true,
            attempt: 2
        )

        let getSubmission = GetSubmission(context: context, assignmentID: "2", userID: "3")
        getSubmission.write(response: apiSubmission, urlResponse: nil, to: databaseClient)

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
