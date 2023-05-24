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

class CourseSyncSelectorEntryTests: XCTestCase {

    func testCourseSelection() {
        var entry = CourseSyncSelectorEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncSelectorEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncSelectorEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: []
        )
        XCTAssertEqual(entry.selectionState, .deselected)
        XCTAssertEqual(entry.selectedTabsCount, 0)

        entry.selectCourse(selectionState: .selected)
        XCTAssertEqual(entry.selectionState, .selected)
        XCTAssertEqual(entry.selectedTabsCount, 2)

        entry.selectCourse(selectionState: .deselected)
        XCTAssertEqual(entry.selectionState, .deselected)
        XCTAssertEqual(entry.selectedTabsCount, 0)
    }

    func testTabSelection() {
        var entry = CourseSyncSelectorEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncSelectorEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncSelectorEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: []
        )
        XCTAssertEqual(entry.selectionState, .deselected)
        XCTAssertEqual(entry.selectedTabsCount, 0)

        entry.selectTab(index: 0, selectionState: .selected)
        XCTAssertEqual(entry.selectionState, .partiallySelected)
        XCTAssertEqual(entry.selectedTabsCount, 1)

        entry.selectTab(index: 1, selectionState: .deselected)
        XCTAssertEqual(entry.selectionState, .partiallySelected)
        XCTAssertEqual(entry.selectedTabsCount, 1)

        entry.selectCourse(selectionState: .selected)
        XCTAssertEqual(entry.selectedTabsCount, 2)
    }

    func testFileSelection() {
        var entry = CourseSyncSelectorEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncSelectorEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncSelectorEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: [
                CourseSyncSelectorEntry.File.make(id: "file1", displayName: "file1"),
                CourseSyncSelectorEntry.File.make(id: "file2", displayName: "file2"),
            ]
        )
        XCTAssertEqual(entry.selectionState, .deselected)
        XCTAssertEqual(entry.selectedTabsCount, 0)

        entry.selectFile(index: 0, selectionState: .selected)
        XCTAssertEqual(entry.selectedTabsCount, 1)
        XCTAssertEqual(entry.selectedFilesCount, 1)

        entry.selectFile(index: 1, selectionState: .deselected)
        XCTAssertEqual(entry.selectionState, .partiallySelected)
        XCTAssertEqual(entry.selectedTabsCount, 1)
        XCTAssertEqual(entry.selectedFilesCount, 1)
    }

    func testEverythingSelected() {
        var entry = CourseSyncSelectorEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncSelectorEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncSelectorEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: [
                CourseSyncSelectorEntry.File.make(id: "file1", displayName: "file1"),
                CourseSyncSelectorEntry.File.make(id: "file2", displayName: "file2"),
            ]
        )
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectTab(index: 0, selectionState: .selected)
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectTab(index: 1, selectionState: .deselected)
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectTab(index: 1, selectionState: .selected)
        XCTAssertEqual(entry.isEverythingSelected, true)

        entry.selectFile(index: 0, selectionState: .deselected)
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectFile(index: 0, selectionState: .selected)
        XCTAssertEqual(entry.isEverythingSelected, true)
    }

    func testSelectionCount() {
        var entry = CourseSyncSelectorEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncSelectorEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncSelectorEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: [
                CourseSyncSelectorEntry.File.make(id: "file1", displayName: "file1"),
                CourseSyncSelectorEntry.File.make(id: "file2", displayName: "file2"),
            ]
        )

        XCTAssertEqual(entry.selectionCount, 0)

        entry.selectTab(index: 1, selectionState: .selected)
        entry.selectFile(index: 0, selectionState: .selected)
        XCTAssertEqual(entry.selectionCount, 2)

        entry.selectFile(index: 1, selectionState: .deselected)
        XCTAssertEqual(entry.selectionCount, 1)

        entry.selectFile(index: 0, selectionState: .selected)
        entry.selectFile(index: 1, selectionState: .selected)
        XCTAssertEqual(entry.selectionCount, 2)
    }
}
