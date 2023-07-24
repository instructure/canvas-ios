//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation
@testable import Core
import TestsFoundation

class GetAssignmentGroupsTests: CoreTestCase {

    let courseID = "1"

    func testProperties() {
        let useCase = GetAssignmentGroups(courseID: courseID)
        XCTAssertEqual(useCase.cacheKey, "courses/1/assignment_groups")
        XCTAssertEqual(useCase.request.courseID, courseID)
        XCTAssertEqual(useCase.scope.predicate, NSPredicate(key: #keyPath(AssignmentGroup.courseID), equals: courseID))
    }

    func testWrite() {
        let useCase = GetAssignmentGroups(courseID: courseID)
        useCase.write(response: [.make()], urlResponse: nil, to: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [AssignmentGroup]).count, 1)
    }
}
