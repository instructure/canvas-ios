//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class GetSubmissionSummaryTests: CoreTestCase {

    public func testProperties() {
        let testee = GetSubmissionSummary(context: .account("testAccount"), assignmentID: "3")
        XCTAssertEqual(testee.cacheKey, "accounts/testAccount/assignments/3/submission_summary")
        XCTAssertEqual(testee.scope, Scope.where(#keyPath(SubmissionSummary.assignmentID), equals: "3"))
        XCTAssertEqual(testee.request.context, .account("testAccount"))
        XCTAssertEqual(testee.request.assignmentID, "3")
    }

    public func testWrite() {
        SubmissionSummary.make(from: APISubmissionSummary(graded: 1, ungraded: 2, not_submitted: 3), assignmentID: "3")
        let apiResponse = APISubmissionSummary(graded: 3, ungraded: 2, not_submitted: 1)

        let testee = GetSubmissionSummary(context: .account("testAccount"), assignmentID: "3")
        testee.write(response: apiResponse, urlResponse: nil, to: databaseClient)

        let dbSubmissionSummaries: [SubmissionSummary] = databaseClient.fetch()
        XCTAssertEqual(dbSubmissionSummaries.count, 1)
        guard let dbSubmissionSummary = dbSubmissionSummaries.first else { return }
        XCTAssertEqual(dbSubmissionSummary.assignmentID, "3")
        XCTAssertEqual(dbSubmissionSummary.graded, 3)
        XCTAssertEqual(dbSubmissionSummary.ungraded, 2)
        XCTAssertEqual(dbSubmissionSummary.unsubmitted, 1)
    }
}
