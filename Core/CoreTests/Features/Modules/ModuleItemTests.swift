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
        let item = APIModuleItem.make(pageId: "pageId")
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
        XCTAssertEqual(model.pageId, item.pageId)
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

    func testSaveCanBeUnpublished() {
        let unpublishable = APIModuleItem.make(unpublishable: true)
        XCTAssertEqual(ModuleItem.save(unpublishable, forCourse: "1", in: databaseClient).canBeUnpublished, true)

        let notUnpublishable = APIModuleItem.make(unpublishable: false)
        XCTAssertEqual(ModuleItem.save(notUnpublishable, forCourse: "1", in: databaseClient).canBeUnpublished, false)

        let empty = APIModuleItem.make(unpublishable: nil)
        XCTAssertEqual(ModuleItem.save(empty, forCourse: "1", in: databaseClient).canBeUnpublished, true)
    }

    func testVisibleWhenLocked() {
        let assignment = ModuleItem.make(from: .make(content: .assignment("1")))
        XCTAssertTrue(assignment.visibleWhenLocked)
        let quiz = ModuleItem.make(from: .make(content: .quiz("1")))
        XCTAssertTrue(quiz.visibleWhenLocked)
        let discussion = ModuleItem.make(from: .make(content: .discussion("1")))
        XCTAssertTrue(discussion.visibleWhenLocked)
    }

    func testIsLocked() {
        let item = ModuleItem.make()
        item.lockedForUser = true
        XCTAssertTrue(item.isLocked)
        item.lockedForUser = false
        XCTAssertFalse(item.isLocked)
    }

    func testIsQuizLTI() {
        var item = ModuleItem.make(from: .make(quiz_lti: true))
        XCTAssertEqual(item.isQuizLTI, true)

        item = ModuleItem.make(from: .make(quiz_lti: false))
        XCTAssertEqual(item.isQuizLTI, false)

        item = ModuleItem.make(from: .make(quiz_lti: nil))
        XCTAssertEqual(item.isQuizLTI, false)
    }
}
