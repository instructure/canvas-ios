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

class GetAssignmentGroupRequestTests: XCTestCase {
    var req: GetAssignmentGroupsRequest!
    let courseID = "1"

    override func setUp() {
        super.setUp()
        req = GetAssignmentGroupsRequest(courseID: courseID)
    }

    func testPath() {
        XCTAssertEqual(req.path, "courses/1/assignment_groups")
    }

    func testQuery() {
        XCTAssertEqual(req.query, [.include([])])
    }

    func testQueryWithInclude() {
        req = GetAssignmentGroupsRequest(courseID: courseID, include: [.assignments])
        let expected: [APIQueryItem] = [.include(["assignments"])]
        XCTAssertEqual(req.query, expected)
    }

    func testQueryWithIncludeWithGradingPeriodID() {
        req = GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: "1", include: [.assignments])
        let expected: [APIQueryItem] = [.include(["assignments"]), .value("grading_period_id", "1")]
        XCTAssertEqual(req.query, expected)
    }

    func testModel() {
        let model = APIAssignmentGroup.make()
        XCTAssertNotNil(model)
    }
}
