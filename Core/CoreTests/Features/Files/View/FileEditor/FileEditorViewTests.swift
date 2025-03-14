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

class FileEditorViewTests: CoreTestCase {
    lazy var controller: CoreHostingController<FileEditorView> = {
        api.mock(GetCourseSettings(courseID: "1"), value: .make(usage_rights_required: true))
        return hostSwiftUIController(FileEditorView(context: .course("1"), fileID: "1"))
    }()

    func testFile() throws {
        api.mock(GetFile(context: .course("1"), fileID: "1"), value: .make(usage_rights: .make(
            use_justification: .creative_commons
        )))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "FileEditor.nameField"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.accessButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.unlockAtButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.lockAtButton"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.copyrightField"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.justificationButton"))
        // XCTAssertNotNil(tree?.find(id: "FileEditor.licenseButton")) // only passes when this test runs alone?!
    }

    func testScheduled() throws {
        api.mock(GetFile(context: .course("1"), fileID: "1"), value: .make(unlock_at: Clock.now))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "FileEditor.nameField"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.accessButton"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.unlockAtButton"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.lockAtButton"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.copyrightField"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.justificationButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.licenseButton"))
    }

    func testFolder() throws {
        api.mock(GetFolder(context: nil, folderID: "1"), value: .make())
        controller = hostSwiftUIController(FileEditorView(folderID: "1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "FileEditor.nameField"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.accessButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.unlockAtButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.lockAtButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.copyrightField"))
        XCTAssertNil(tree?.find(id: "FileEditor.justificationButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.licenseButton"))
    }

    func testScheduledFolder() throws {
        api.mock(GetFolder(context: nil, folderID: "1"), value: .make(lock_at: Clock.now))
        controller = hostSwiftUIController(FileEditorView(folderID: "1"))
        let tree = controller.testTree
        XCTAssertNotNil(tree?.find(id: "FileEditor.nameField"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.accessButton"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.unlockAtButton"))
        XCTAssertNotNil(tree?.find(id: "FileEditor.lockAtButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.copyrightField"))
        XCTAssertNil(tree?.find(id: "FileEditor.justificationButton"))
        XCTAssertNil(tree?.find(id: "FileEditor.licenseButton"))
    }
}
