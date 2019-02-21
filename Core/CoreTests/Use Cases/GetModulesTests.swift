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

import Foundation
@testable import Core
import XCTest

class GetModulesTests: CoreTestCase {
    let useCase = GetModules(courseID: "1")

    func testScopePredicate() {
        let yes = Module.make(["id": "1", "courseID": "1"], client: databaseClient)
        let no = Module.make(["id": "2", "courseID": "2"], client: databaseClient)
        XCTAssert(useCase.scope.predicate.evaluate(with: yes))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: no))
    }

    func testScopeOrder() {
        let one = Module.make(["id": "1", "position": 1], client: databaseClient)
        let two = Module.make(["id": "2", "position": 2], client: databaseClient)
        let three = Module.make(["id": "2", "position": 3], client: databaseClient)
        let order = useCase.scope.order[0]
        XCTAssertEqual(order.compare(one, to: two), .orderedAscending)
        XCTAssertEqual(order.compare(two, to: three), .orderedAscending)
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-modules-1")
    }

    func testRequest() {
        XCTAssertEqual(useCase.request.path, "courses/1/modules")
    }

    func testWrite() {
        let item = APIModule.make()
        try! useCase.write(response: [item], urlResponse: nil, to: databaseClient)

        let module: Module = databaseClient.fetch().first!
        XCTAssertEqual(module.id, item.id.value)
        XCTAssertEqual(module.courseID, "1")
    }
}
