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

class CourseSyncItemSelectionTests: XCTestCase {

    func testMappingToCourseEntrySelection() {
        let syncEntries = [
            CourseSyncEntry(name: "",
                            id: "1",
                            tabs: [],
                            files: [],
                            isCollapsed: false,
                            selectionState: .deselected,
                            isEverythingSelected: false,
                            state: .loading(nil)),
            CourseSyncEntry(name: "",
                            id: "2",
                            tabs: [
                                .init(id: "3", name: "", type: .files),
                                .init(id: "4", name: "", type: .files),
                            ],
                            files: [
                                .make(id: "5", displayName: ""),
                                .make(id: "6", displayName: ""),
                            ],
                            isCollapsed: false,
                            selectionState: .deselected,
                            isEverythingSelected: false,
                            state: .loading(nil)),
        ]

        let courseSelection = "2"
        XCTAssertEqual(courseSelection.toCourseEntrySelection(from: syncEntries), .course("2"))

        let tabSelection = "4"
        XCTAssertEqual(tabSelection.toCourseEntrySelection(from: syncEntries), .tab("2", "4"))

        let fileSelection = "6"
        XCTAssertEqual(fileSelection.toCourseEntrySelection(from: syncEntries), .file("2", "6"))
    }

    // MARK: - Mapping From An Array Of Course Sync Entities

    func testMapsSelectedCourseButNotTabsOrFiles() {
        let course = CourseSyncEntry(name: "",
                                     id: "course-1",
                                     tabs: [
                                        .init(id: "tab-pages", name: "", type: .pages, selectionState: .selected)
                                     ],
                                     files: [
                                        .init(id: "file-1", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .selected, bytesToDownload: 0),
                                     ],
                                     selectionState: .selected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), ["course-1"])
    }

    func testMapsSelectedFilesTabButNotFiles() {
        let course = CourseSyncEntry(name: "",
                                     id: "course-1",
                                     tabs: [
                                        .init(id: "tab-files", name: "", type: .files, selectionState: .selected),
                                     ],
                                     files: [
                                        .init(id: "file-1", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .selected, bytesToDownload: 0),
                                     ],
                                     selectionState: .partiallySelected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), ["tab-files"])
    }

    func testMapsSelectedTabs() {
        let course = CourseSyncEntry(name: "",
                                     id: "course-1",
                                     tabs: [
                                        .init(id: "tab-files-1", name: "", type: .files, selectionState: .selected),
                                        .init(id: "tab-files-2", name: "", type: .files, selectionState: .deselected),
                                     ],
                                     files: [],
                                     selectionState: .partiallySelected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), ["tab-files-1"])
    }

    func testMapsSelectedFiles() {
        let course = CourseSyncEntry(name: "",
                                     id: "course-1",
                                     tabs: [
                                        .init(id: "tab-files", name: "", type: .files, selectionState: .partiallySelected),
                                     ],
                                     files: [
                                        .init(id: "file-1", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .deselected, bytesToDownload: 0),
                                        .init(id: "file-2", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .selected, bytesToDownload: 0),
                                     ],
                                     selectionState: .partiallySelected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), ["file-2"])
    }
}
