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
import XCTest
@testable import Core
import TestsFoundation

class ModuleTests: CoreTestCase {
    func testSave() {
        let items = [APIModule.make(id: "1"), APIModule.make(id: "2")]
        Module.save(items, forCourse: "1", in: databaseClient)

        let modules: [Module] = databaseClient.fetch()
        let one = modules.first { $0.id == "1" }
        let two = modules.first { $0.id == "2" }
        XCTAssertNotNil(one)
        XCTAssertNotNil(two)
        XCTAssertEqual(one?.courseID, "1")
        XCTAssertEqual(two?.courseID, "1")
    }

    func testSaveItems() {
        let module = APIModule.make(
            items: [
                APIModuleItem.make(id: "1"),
                APIModuleItem.make(id: "2")
            ]
        )
        Module.save(module, forCourse: "1", in: databaseClient)

        let modules: [Module] = databaseClient.fetch()
        XCTAssertEqual(modules.count, 1)

        let moduleItems: [ModuleItem] = databaseClient.fetch()
        XCTAssertEqual(moduleItems.count, 2)
    }

    func testRequireSequentialLocking() {
        let apiModule = APIModule.make(
            require_sequential_progress: true,
            items: [
                APIModuleItem.make(id: "1", completion_requirement: .make(type: .must_view, completed: false, min_score: 0)),
                APIModuleItem.make(id: "2", completion_requirement: .make(type: .must_view, completed: false, min_score: 0)),
                APIModuleItem.make(id: "3", completion_requirement: .make(type: .must_view, completed: false, min_score: 0))
            ]
        )
        let module = Module.make(from: apiModule)
        XCTAssertFalse(module.items[0].isLocked)
        XCTAssertTrue(module.items[1].isLocked)
        XCTAssertTrue(module.items[2].isLocked)
        module.items.first?.completed = true
        XCTAssertFalse(module.items[0].isLocked)
        XCTAssertFalse(module.items[1].isLocked)
        XCTAssertTrue(module.items[2].isLocked)
    }
}
