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
