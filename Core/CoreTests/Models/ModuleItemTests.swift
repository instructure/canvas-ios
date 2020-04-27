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

class ModuleItemTests: CoreTestCase {
    func testSave() {
        let item = APIModuleItem.make()
        let model = ModuleItem.save(item, forCourse: "1", in: databaseClient)
        XCTAssertEqual(model.id, item.id.value)
        XCTAssertEqual(model.title, item.title)
        XCTAssertEqual(model.moduleID, item.module_id.value)
        XCTAssertEqual(model.position, Double(item.position))
        XCTAssertEqual(model.indent, item.indent)
        XCTAssertEqual(model.htmlURL, item.html_url)
        XCTAssertEqual(model.url, item.url)
        XCTAssertEqual(model.type, item.content)
        XCTAssertEqual(model.courseID, "1")
        XCTAssertEqual(model.dueAt, item.content_details?.due_at)
    }

    func testSaveDueAt() {
        let item = APIModuleItem.make(content_details: .make(due_at: Date()))
        let model = ModuleItem.save(item, forCourse: "1", in: databaseClient)
        XCTAssertNotNil(model.dueAt)
        XCTAssertEqual(model.dueAt, item.content_details?.due_at)
    }

    func testType() {
        ModuleItem.make(from: .make(id: "1", content: .assignment("1")))
        let item: ModuleItem = databaseClient.fetch().first!
        XCTAssertEqual(item.id, "1")
        XCTAssertEqual(item.type, .assignment("1"))
    }

    func testSavePublished() {
        let published = APIModuleItem.make(published: true)
        XCTAssertTrue(ModuleItem.save(published, forCourse: "1", in: databaseClient).published ?? false)

        let notPublished = APIModuleItem.make(published: false)
        XCTAssertFalse(ModuleItem.save(notPublished, forCourse: "1", in: databaseClient).published ?? true)

        let empty = APIModuleItem.make(published: nil)
        XCTAssertNil(ModuleItem.save(empty, forCourse: "1", in: databaseClient).published)
    }
}
