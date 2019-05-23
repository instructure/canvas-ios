//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
                APIModuleItem.make(id: "2"),
            ]
        )
        Module.save(module, forCourse: "1", in: databaseClient)

        let modules: [Module] = databaseClient.fetch()
        XCTAssertEqual(modules.count, 1)

        let moduleItems: [ModuleItem] = databaseClient.fetch()
        XCTAssertEqual(moduleItems.count, 2)
    }
}
