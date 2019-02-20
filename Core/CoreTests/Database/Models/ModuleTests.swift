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
import XCTest
@testable import Core
import TestsFoundation

class ModuleTests: CoreTestCase {
    func testSave() {
        let items = [APIModule.make(["id": "1"]), APIModule.make(["id": "2"])]
        Module.save(items, forCourse: "1", in: databaseClient)

        let modules: [Module] = databaseClient.fetch()
        let one = modules.first { $0.id == "1" }
        let two = modules.first { $0.id == "2" }
        XCTAssertNotNil(one)
        XCTAssertNotNil(two)
        XCTAssertEqual(one?.courseID, "1")
        XCTAssertEqual(two?.courseID, "1")
    }
}
