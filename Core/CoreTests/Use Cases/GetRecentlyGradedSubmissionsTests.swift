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

class GetRecentlyGradedSubmissionsTests: CoreTestCase {
    func testRequestUsesUserID() {
        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        XCTAssertEqual(useCase.request.userID, "1")
    }

    func testItCreatesSubmissionsWithAssignments() {
        let apiSubmission = APISubmission.make(
            id: "1",
            assignment_id: "2",
            assignment: APIAssignmentNoSubmission.make(id: "2")
        )

        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        useCase.write(response: [apiSubmission], urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
        XCTAssertEqual(submissions[0].id, "1")
        XCTAssertEqual(submissions[0].assignmentID, "2")

        let assignments: [Assignment] = databaseClient.fetch()
        XCTAssertEqual(assignments.count, 1)
        XCTAssertEqual(assignments[0].id, "2")
        XCTAssertEqual(assignments[0].submission, submissions[0])
    }

    func testCache() {
        let useCase = GetRecentlyGradedSubmissions(userID: "self")
        XCTAssertEqual(useCase.cacheKey, "recently-graded-submissions")
    }

    func testScope() {
        let firstSubmission = Submission.make(from: APISubmission.make(assignment_id: "1", graded_at: Date(fromISOString: "2019-04-29T18:17:21.890Z")), in: databaseClient)
        let secondSubmission = Submission.make(from: APISubmission.make(assignment_id: "2", graded_at: Date(fromISOString: "2019-04-28T18:17:21.890Z")), in: databaseClient)

        let useCase = GetRecentlyGradedSubmissions(userID: "self")

        let submissions: [Submission] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(submissions.count, 2)
        XCTAssertEqual(submissions[0], firstSubmission)
        XCTAssertEqual(submissions[1], secondSubmission)
    }
}
