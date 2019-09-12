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

@testable import Core
import XCTest

class GetAssignmentGroupUseCaseTests: XCTestCase {

    var useCase: GetAssignmentGroups!
    let courseID: String = "1"

    override func setUp() {
        super.setUp()
        useCase = GetAssignmentGroups(courseID: courseID)
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-assignmentGroup-\(courseID)")
    }

    func testScope() {
        let expectedScope = Scope.where(#keyPath(AssignmentGroup.courseID), equals: courseID, orderBy: #keyPath(AssignmentGroup.position), ascending: true, naturally: false)
        XCTAssertEqual(useCase.scope, expectedScope)
    }

    func testRequest() {
        XCTAssertEqual(useCase.request.courseID, courseID)
    }
}
