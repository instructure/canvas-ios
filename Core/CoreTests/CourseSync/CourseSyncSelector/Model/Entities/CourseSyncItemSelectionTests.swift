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
}
