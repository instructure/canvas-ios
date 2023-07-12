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

class CourseSyncEntryTests: XCTestCase {

    func testCourseId() {
        let testee = CourseSyncEntry(name: "",
                                     id: "courses/3",
                                     tabs: [],
                                     files: [])
        XCTAssertEqual(testee.courseId, "3")
    }

    func testFileId() {
        let testee = CourseSyncEntry.File(id: "courses/3/files/2",
                                          displayName: "",
                                          fileName: "",
                                          url: URL(string: "/")!,
                                          mimeClass: "",
                                          bytesToDownload: 0
        )
        XCTAssertEqual(testee.fileId, "2")
    }

    func testCourseSelection() {
        var entry = CourseSyncEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncEntry.Tab(id: "tab2", name: "tab2", type: .files),
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
        var entry = CourseSyncEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: []
        )
        XCTAssertEqual(entry.selectionState, .deselected)
        XCTAssertEqual(entry.selectedTabsCount, 0)

        entry.selectTab(id: "tab1", selectionState: .selected)
        XCTAssertEqual(entry.selectionState, .partiallySelected)
        XCTAssertEqual(entry.selectedTabsCount, 1)

        entry.selectTab(id: "tab2", selectionState: .deselected)
        XCTAssertEqual(entry.selectionState, .partiallySelected)
        XCTAssertEqual(entry.selectedTabsCount, 1)

        entry.selectCourse(selectionState: .selected)
        XCTAssertEqual(entry.selectedTabsCount, 2)
    }

    func testFileSelection() {
        var entry = CourseSyncEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: [
                CourseSyncEntry.File.make(id: "file1", displayName: "file1"),
                CourseSyncEntry.File.make(id: "file2", displayName: "file2"),
            ]
        )
        XCTAssertEqual(entry.selectionState, .deselected)
        XCTAssertEqual(entry.selectedTabsCount, 0)

        entry.selectFile(id: "file1", selectionState: .selected)
        XCTAssertEqual(entry.selectedTabsCount, 1)
        XCTAssertEqual(entry.selectedFilesCount, 1)

        entry.selectFile(id: "file2", selectionState: .deselected)
        XCTAssertEqual(entry.selectionState, .partiallySelected)
        XCTAssertEqual(entry.selectedTabsCount, 1)
        XCTAssertEqual(entry.selectedFilesCount, 1)
    }

    func testEverythingSelected() {
        var entry = CourseSyncEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: [
                CourseSyncEntry.File.make(id: "file1", displayName: "file1"),
                CourseSyncEntry.File.make(id: "file2", displayName: "file2"),
            ]
        )
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectTab(id: "tab1", selectionState: .selected)
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectTab(id: "tab2", selectionState: .deselected)
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectTab(id: "tab2", selectionState: .selected)
        XCTAssertEqual(entry.isEverythingSelected, true)

        entry.selectFile(id: "file1", selectionState: .deselected)
        XCTAssertEqual(entry.isEverythingSelected, false)

        entry.selectFile(id: "file1", selectionState: .selected)
        XCTAssertEqual(entry.isEverythingSelected, true)
    }

    func testSelectionCount() {
        var entry = CourseSyncEntry(
            name: "1",
            id: "1",
            tabs: [
                CourseSyncEntry.Tab(id: "tab1", name: "tab1", type: .assignments),
                CourseSyncEntry.Tab(id: "tab2", name: "tab2", type: .files),
            ],
            files: [
                CourseSyncEntry.File.make(id: "file1", displayName: "file1"),
                CourseSyncEntry.File.make(id: "file2", displayName: "file2"),
            ]
        )

        XCTAssertEqual(entry.selectionCount, 0)

        entry.selectTab(id: "tab2", selectionState: .selected)
        entry.selectFile(id: "file1", selectionState: .selected)
        XCTAssertEqual(entry.selectionCount, 2)

        entry.selectFile(id: "file2", selectionState: .deselected)
        XCTAssertEqual(entry.selectionCount, 1)

        entry.selectFile(id: "file1", selectionState: .selected)
        entry.selectFile(id: "file2", selectionState: .selected)
        XCTAssertEqual(entry.selectionCount, 2)
    }
}
