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
@testable import TestsFoundation
import CoreData

class GetModuleItemTests: CoreTestCase {
    func testUseCase() {
        let useCase = GetModuleItem(courseID: "1", moduleID: "2", itemID: "3")
        XCTAssertEqual(useCase.request.path, "courses/1/modules/2/items/3")
        XCTAssertEqual(useCase.cacheKey, "courses/1/modules/2/items/3")
        let match = ModuleItem.make(from: .make(id: "3"), forCourse: "1")
        let otherCourse = ModuleItem.make(from: .make(id: "3"), forCourse: "2")
        let otherID = ModuleItem.make(from: .make(id: "4"), forCourse: match.courseID)
        XCTAssertTrue(useCase.scope.predicate.evaluate(with: match))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: otherCourse))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: otherID))

        useCase.write(response: .make(id: "3", title: "write update"), urlResponse: nil, to: databaseClient)
        XCTAssertEqual(match.title, "write update")
    }
}
