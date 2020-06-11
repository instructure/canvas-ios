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

import Foundation
@testable import Core
import XCTest

class GetModulesTests: CoreTestCase {
    let useCase = GetModules(courseID: "1")

    func testScopePredicate() {
        let yes = Module.make(from: .make(id: "1"), forCourse: "1")
        let no = Module.make(from: .make(id: "2"), forCourse: "2")
        XCTAssert(useCase.scope.predicate.evaluate(with: yes))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: no))
    }

    func testScopeOrder() {
        let one = Module.make(from: .make(id: "1", position: 1))
        let two = Module.make(from: .make(id: "2", position: 2))
        let three = Module.make(from: .make(id: "3", position: 3))
        let order = useCase.scope.order[0]
        XCTAssertEqual(order.compare(one, to: two), .orderedAscending)
        XCTAssertEqual(order.compare(two, to: three), .orderedAscending)
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "courses/1/modules/items")
    }

    func testWrite() {
        useCase.write(response: .init(sections: [.init(module: .make(id: "1"), items: [.make(module_id: "1")])]), urlResponse: nil, to: databaseClient)
        let module: Module = databaseClient.fetch().first!
        XCTAssertEqual(module.id, "1")
        XCTAssertEqual(module.courseID, "1")
        let moduleItem: ModuleItem = databaseClient.fetch().first!
        XCTAssertEqual(moduleItem.moduleID, module.id)
        XCTAssertEqual(moduleItem.courseID, "1")
    }
}
