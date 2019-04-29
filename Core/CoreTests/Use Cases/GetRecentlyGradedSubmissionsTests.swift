//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class GetRecentlyGradedSubmissionsTests: CoreTestCase {
    func testRequestUsesUserID() {
        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        XCTAssertEqual(useCase.request.userID, "1")
    }

    func testItCreatesSubmissionsWithAssignments() {
        let apiSubmission = APISubmission.make([
            "id": "1",
            "assignment_id": "2",
            "assignment": APIAssignmentNoSubmission.fixture(["id": "2"]),
        ])

        let useCase = GetRecentlyGradedSubmissions(userID: "1")
        try! useCase.write(response: [apiSubmission], urlResponse: nil, to: databaseClient)

        let submissions: [Submission] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(submissions.count, 1)
        XCTAssertEqual(submissions[0].id, "1")
        XCTAssertEqual(submissions[0].assignmentID, "2")

        let assignments: [Assignment] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(assignments.count, 1)
        XCTAssertEqual(assignments[0].id, "2")
        XCTAssertEqual(assignments[0].submission, submissions[0])
    }

    func testCache() {
        let useCase = GetRecentlyGradedSubmissions(userID: "self")
        XCTAssertEqual(useCase.cacheKey, "recently-graded-submissions")
    }

    func testScope() {
        let firstSubmission = Submission.make(["gradedAt": Date(fromISOString: "2019-04-29T18:17:21.890Z")])
        let secondSubmission = Submission.make(["gradedAt": Date(fromISOString: "2019-04-28T18:17:21.890Z")])

        let useCase = GetRecentlyGradedSubmissions(userID: "self")

        let submissions: [Submission] = databaseClient.fetch(predicate: useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(submissions.count, 2)
        XCTAssertEqual(submissions[0], firstSubmission)
        XCTAssertEqual(submissions[1], secondSubmission)
    }
}
