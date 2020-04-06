//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class GetAssignmentsByGroupTests: CoreTestCase {
    func testProperties() {
        let useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2")
        XCTAssertEqual(useCase.cacheKey, "courses/1/assignment_groups?grading_period_id=2")
        XCTAssertEqual(useCase.request.courseID, "1")
        XCTAssertEqual(useCase.scope.predicate, NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: "1"))
    }

    func testWrite() {
        let useCase = GetAssignmentsByGroup(courseID: "1", gradingPeriodID: "2")
        useCase.write(response: [.make()], urlResponse: nil, to: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [AssignmentGroup]).count, 1)
        useCase.reset(context: databaseClient)
        XCTAssertEqual((databaseClient.fetch() as [AssignmentGroup]).count, 0)
    }
}
