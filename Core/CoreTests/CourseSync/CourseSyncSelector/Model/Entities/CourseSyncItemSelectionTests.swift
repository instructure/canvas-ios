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
                                .init(id: "t1", name: "", type: .files),
                                .init(id: "t2", name: "", type: .files),
                            ],
                            files: [
                                .make(id: "f1", displayName: ""),
                                .make(id: "f2", displayName: ""),
                            ],
                            isCollapsed: false,
                            selectionState: .deselected,
                            isEverythingSelected: false,
                            state: .loading(nil)),
        ]

        let courseSelection = CourseSyncItemSelection(id: "2", selectionType: .course)
        XCTAssertEqual(courseSelection.toCourseEntrySelection(from: syncEntries), .course(1))

        let tabSelection = CourseSyncItemSelection(id: "t2", selectionType: .tab)
        XCTAssertEqual(tabSelection.toCourseEntrySelection(from: syncEntries), .tab(1, 1))

        let fileSelection = CourseSyncItemSelection(id: "f2", selectionType: .file)
        XCTAssertEqual(fileSelection.toCourseEntrySelection(from: syncEntries), .file(1, 1))
    }

    // MARK: - Mapping From Single Course Sync Entity

    func testInitFromCourseSyncEntry() {
        let deSelectedEntry = CourseSyncEntry(name: "", id: "1", tabs: [], files: [],
                                              selectionState: .deselected)
        XCTAssertNil(CourseSyncItemSelection(courseSyncEntry: deSelectedEntry))

        let partiallySelectedEntry = CourseSyncEntry(name: "", id: "2", tabs: [], files: [],
                                                     selectionState: .partiallySelected)
        XCTAssertNil(CourseSyncItemSelection(courseSyncEntry: partiallySelectedEntry))

        let selectedEntry = CourseSyncEntry(name: "", id: "3", tabs: [], files: [],
                                            selectionState: .selected)
        XCTAssertEqual(CourseSyncItemSelection(courseSyncEntry: selectedEntry),
                       .init(id: "3", selectionType: .course))
    }

    func testInitFromCourseSyncEntryTab() {
        let deSelectedEntry = CourseSyncEntry.Tab(id: "1", name: "", type: .pages, selectionState: .deselected)
        XCTAssertNil(CourseSyncItemSelection(courseSyncEntryTab: deSelectedEntry))

        let partiallySelectedEntry = CourseSyncEntry.Tab(id: "2", name: "", type: .pages, selectionState: .partiallySelected)
        XCTAssertNil(CourseSyncItemSelection(courseSyncEntryTab: partiallySelectedEntry))

        let selectedEntry = CourseSyncEntry.Tab(id: "3", name: "", type: .pages, selectionState: .selected)
        XCTAssertEqual(CourseSyncItemSelection(courseSyncEntryTab: selectedEntry),
                       .init(id: "3", selectionType: .tab))
    }

    func testInitFromCourseSyncEntryFile() {
        let deSelectedEntry = CourseSyncEntry.File(id: "1",
                                                   displayName: "",
                                                   fileName: "",
                                                   url: URL(string: "/")!,
                                                   mimeClass: "",
                                                   selectionState: .deselected)
        XCTAssertNil(CourseSyncItemSelection(courseSyncEntryFile: deSelectedEntry))

        let partiallySelectedEntry = CourseSyncEntry.File(id: "2",
                                                          displayName: "",
                                                          fileName: "",
                                                          url: URL(string: "/")!,
                                                          mimeClass: "",
                                                          selectionState: .partiallySelected)
        XCTAssertNil(CourseSyncItemSelection(courseSyncEntryFile: partiallySelectedEntry))

        let selectedEntry = CourseSyncEntry.File(id: "3",
                                                 displayName: "",
                                                 fileName: "",
                                                 url: URL(string: "/")!,
                                                 mimeClass: "",
                                                 selectionState: .selected)
        XCTAssertEqual(CourseSyncItemSelection(courseSyncEntryFile: selectedEntry),
                       .init(id: "3", selectionType: .file))
    }

    // MARK: - Mapping From An Array Of Course Sync Entities

    func testMapsSelectedCourseButNotTabsOrFiles() {
        let course = CourseSyncEntry(name: "",
                                     id: "1",
                                     tabs: [
                                        .init(id: "2", name: "", type: .pages, selectionState: .selected)
                                     ],
                                     files: [
                                        .init(id: "3", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .selected),
                                     ],
                                     selectionState: .selected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), [.init(id: "1", selectionType: .course)])
    }

    func testMapsSelectedFilesTabButNotFiles() {
        let course = CourseSyncEntry(name: "",
                                     id: "1",
                                     tabs: [
                                        .init(id: "2", name: "", type: .files, selectionState: .selected),
                                     ],
                                     files: [
                                        .init(id: "3", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .selected),
                                     ],
                                     selectionState: .partiallySelected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), [.init(id: "2", selectionType: .tab)])
    }

    func testMapsSelectedTabs() {
        let course = CourseSyncEntry(name: "",
                                     id: "1",
                                     tabs: [
                                        .init(id: "2", name: "", type: .files, selectionState: .selected),
                                        .init(id: "3", name: "", type: .files, selectionState: .deselected),
                                     ],
                                     files: [],
                                     selectionState: .partiallySelected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), [.init(id: "2", selectionType: .tab)])
    }

    func testMapsSelectedFiles() {
        let course = CourseSyncEntry(name: "",
                                     id: "1",
                                     tabs: [
                                        .init(id: "2", name: "", type: .files, selectionState: .partiallySelected),
                                     ],
                                     files: [
                                        .init(id: "3", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .deselected),
                                        .init(id: "4", displayName: "", fileName: "",
                                              url: URL(string: "/")!, mimeClass: "", selectionState: .selected),
                                     ],
                                     selectionState: .partiallySelected)
        XCTAssertEqual(CourseSyncItemSelection.make(from: [course]), [.init(id: "4", selectionType: .file)])
    }
}
