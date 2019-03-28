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

class ModuleItemTests: CoreTestCase {
    func testSave() {
        let item = APIModuleItem.make()
        let model = ModuleItem.save(item, in: databaseClient)
        XCTAssertEqual(model.id, item.id.value)
        XCTAssertEqual(model.title, item.title)
        XCTAssertEqual(model.moduleID, item.module_id.value)
        XCTAssertEqual(model.position, item.position)
        XCTAssertEqual(model.indent, item.indent)
        XCTAssertEqual(model.htmlURL, item.html_url)
        XCTAssertEqual(model.url, item.url)
        XCTAssertEqual(model.type, item.content)
    }

    func testType() {
        ModuleItem.make(["id": "1", "type": ModuleItemType.assignment("1").data])
        let item: ModuleItem = databaseClient.fetch().first!
        XCTAssertEqual(item.id, "1")
        XCTAssertEqual(item.type, .assignment("1"))
    }

    func testSavePublished() {
        let published = APIModuleItem.make(["published": true])
        XCTAssertTrue(ModuleItem.save(published, in: databaseClient).published)

        let notPublished = APIModuleItem.make(["published": false])
        XCTAssertFalse(ModuleItem.save(notPublished, in: databaseClient).published)

        let empty = APIModuleItem.make(["published": nil])
        XCTAssertFalse(ModuleItem.save(empty, in: databaseClient).published)
    }
}
