//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

@testable import Core
import XCTest

class CourseSyncSelectorViewModelTests: XCTestCase {

    // MARK: - Course

    func testCourseMapping() {
        var data = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [])
        var testee = data.makeViewModelItem()

        XCTAssertTrue(testee.isSelected)
        XCTAssertEqual(testee.backgroundColor, .backgroundLight)
        XCTAssertEqual(testee.title, "test")
        XCTAssertNil(testee.subtitle)
        XCTAssertFalse(testee.isIndented)

        data.isCollapsed = true
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .closed)

        data.isCollapsed = false
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .opened)
    }

    func testCourseCollapsion() {
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [.init(id: "0", name: "Assignments", type: .assignments)], files: [])

        course.isCollapsed = true
        XCTAssertEqual([course].makeViewModelItems().count, 1)

        course.isCollapsed = false
        XCTAssertEqual([course].makeViewModelItems().count, 2)
    }

    // MARK: - Course Tabs

    func testCourseTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Test", type: .assignments)
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.backgroundColor, .backgroundLightest)
        XCTAssertEqual(testee.title, "Test")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.trailingIcon, .none)
        XCTAssertFalse(testee.isIndented)

        data.isSelected = true
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.isSelected)

        data.isSelected = false
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.isSelected)
    }

    func testFilesTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Files", type: .files)

        data.isCollapsed = true
        var testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .closed)

        data.isCollapsed = false
        testee = data.makeViewModelItem()
        XCTAssertEqual(testee.trailingIcon, .opened)
    }

    func testFilesTabCollapsion() {
        let file = CourseSyncEntry.File(id: "0", name: "test.txt", url: nil)
        var filesTab = CourseSyncEntry.Tab(id: "0", name: "Files", type: .files)

        filesTab.isCollapsed = true
        var course = CourseSyncEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        XCTAssertEqual([course].makeViewModelItems().count, 2)

        filesTab.isCollapsed = false
        course = CourseSyncEntry(name: "test", id: "testID", tabs: [filesTab], files: [file], isCollapsed: false)
        course.isCollapsed = false
        XCTAssertEqual([course].makeViewModelItems().count, 3)
    }

    // MARK: - Files

    func testFileItemMapping() {
        var data = CourseSyncEntry.File(id: "1", name: "testFile", url: nil)
        var testee = data.makeViewModelItem()

        XCTAssertEqual(testee.backgroundColor, .backgroundLightest)
        XCTAssertEqual(testee.title, "testFile")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.trailingIcon, .none)
        XCTAssertTrue(testee.isIndented)

        data.isSelected = true
        testee = data.makeViewModelItem()
        XCTAssertTrue(testee.isSelected)

        data.isSelected = false
        testee = data.makeViewModelItem()
        XCTAssertFalse(testee.isSelected)
    }
}
