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

import SwiftUI
import Combine
@testable import Core
import TestsFoundation
import XCTest

class PageEditorViewTests: CoreTestCase {
    lazy var controller: CoreHostingController<PageEditorView> = {
        api.mock(GetPageRequest(context: .course("1"), url: "page-1"), value: .make(
            body: "body",
            editing_roles: "teachers,students",
            html_url: URL(string: "/courses/1/pages/page-1")!,
            page_id: "1",
            published: true,
            title: "Page 1",
            url: "page-1"
        ))
        return hostSwiftUIController(PageEditorView(context: .course("1"), url: "page-1"))
    }()

    func testStudent() throws {
        environment.app = .student
        let tree = controller.testTree
        XCTAssertNil(tree?.find(id: "PageEditor.titleField"))
        XCTAssertNotNil(tree?.find(id: "PageEditor.titleText"))
        XCTAssertNil(tree?.find(id: "PageEditor.publishedToggle"))
        XCTAssertNil(tree?.find(id: "PageEditor.frontPageToggle"))
        XCTAssertNil(tree?.find(id: "PageEditor.editorsButton"))
        XCTAssertNil(tree?.find(id: "PageEditor.editorsPicker"))
    }

    func testTeacher() throws {
        environment.app = .teacher
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "PageEditor.titleField"))
        XCTAssertNil(tree?.find(id: "PageEditor.titleText"))
        XCTAssertNotNil(tree?.find(id: "PageEditor.publishedToggle"))
        XCTAssertNotNil(tree?.find(id: "PageEditor.frontPageToggle"))
        XCTAssertNotNil(tree?.find(id: "PageEditor.editorsButton"))
        XCTAssertNil(tree?.find(id: "PageEditor.editorsPicker"))
    }

    func testGroup() throws {
        api.mock(GetPageRequest(context: .group("1"), url: "page-1"), value: .make(
            body: "body",
            editing_roles: "members",
            html_url: URL(string: "/groups/1/pages/page-1")!,
            page_id: "1",
            published: true,
            title: "Page 1",
            url: "page-1"
        ))
        controller = hostSwiftUIController(PageEditorView(context: .group("1"), url: "page-1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "PageEditor.titleField"))
        XCTAssertNil(tree?.find(id: "PageEditor.titleText"))
        XCTAssertNil(tree?.find(id: "PageEditor.publishedToggle"))
        XCTAssertNil(tree?.find(id: "PageEditor.frontPageToggle"))
        XCTAssertNotNil(tree?.find(id: "PageEditor.editorsButton"))
        XCTAssertNil(tree?.find(id: "PageEditor.editorsPicker"))
    }
}
