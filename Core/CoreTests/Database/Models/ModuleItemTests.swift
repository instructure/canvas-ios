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
@testable import Core
import XCTest

class ModuleItemTests: CoreTestCase {
    func testSave() {
        let item = APIModuleItem.make()
        let model = ModuleItem.save(item, forCourse: "1", in: databaseClient)
        XCTAssertEqual(model.id, item.id.value)
        XCTAssertEqual(model.title, item.title)
        XCTAssertEqual(model.moduleID, item.module_id.value)
        XCTAssertEqual(model.position, item.position)
        XCTAssertEqual(model.indent, item.indent)
        XCTAssertEqual(model.htmlURL, item.html_url)
        XCTAssertEqual(model.url, item.url)
        XCTAssertEqual(model.type, item.content)
        XCTAssertEqual(model.courseID, "1")
        XCTAssertEqual(model.dueAt, item.content_details.due_at)
    }

    func testSaveDueAt() {
        let item = APIModuleItem.make(content_details: .make(due_at: Date()))
        let model = ModuleItem.save(item, forCourse: "1", in: databaseClient)
        XCTAssertNotNil(model.dueAt)
        XCTAssertEqual(model.dueAt, item.content_details.due_at)
    }

    func testType() {
        ModuleItem.make(["id": "1", "typeRaw": ModuleItemType.assignment("1").data])
        let item: ModuleItem = databaseClient.fetch().first!
        XCTAssertEqual(item.id, "1")
        XCTAssertEqual(item.type, .assignment("1"))
    }

    func testSavePublished() {
        let published = APIModuleItem.make(published: true)
        XCTAssertTrue(ModuleItem.save(published, forCourse: "1", in: databaseClient).published)

        let notPublished = APIModuleItem.make(published: false)
        XCTAssertFalse(ModuleItem.save(notPublished, forCourse: "1", in: databaseClient).published)

        let empty = APIModuleItem.make(published: nil)
        XCTAssertFalse(ModuleItem.save(empty, forCourse: "1", in: databaseClient).published)
    }
}
