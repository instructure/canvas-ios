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

    // MARK: - Entity Mappings

    func testCourseTabMapping() {
        var data = CourseSyncEntry.Tab(id: "1", name: "Test", type: .assignments, isSelected: true)
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

    func testFileCourseTabMapping() {
        let data = CourseSyncEntry.Tab(id: "1", name: "Test", type: .files)
        let testee = data.makeViewModelItem()

        XCTAssertTrue(testee.isIndented)
    }

    func testCourseMapping() {
        var data = CourseSyncEntry(name: "test", id: "testID", tabs: [], files: [], isSelected: true)
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

    // MARK: - Separators

    func testClosedCourseSeparators() {
        let data: [CourseSyncEntry] = [
            .init(name: "Black Hole", id: "0", tabs: [], files: []),
            .init(name: "Cosmology", id: "1", tabs: [], files: []),
        ]
        let testee = data.makeViewModelItems()
        XCTAssertEqual(testee[0], .separator(isLight: true, isIndented: false))
        // Index 1 is a course
        XCTAssertEqual(testee[2], .separator(isLight: true, isIndented: false))
        // Index 3 is a course
        XCTAssertEqual(testee[4], .separator(isLight: true, isIndented: false))
    }

    func testCourseTabsSeparators() {
        var data: [CourseSyncEntry] = [
            .init(name: "Black Hole",
                  id: "0",
                  tabs: [
                    .init(id: "0", name: "Assignments", type: .assignments),
                    .init(id: "1", name: "People", type: .people),
                  ],
                  files: []),
        ]
        data[0].isCollapsed = false

        let testee = data.makeViewModelItems()
        XCTAssertEqual(testee[0], .separator(isLight: true, isIndented: false))
        // Index 1 is a course
        XCTAssertEqual(testee[2], .separator(isLight: true, isIndented: false))
        // Index 3 is Assignments tab
        XCTAssertEqual(testee[4], .separator(isLight: true, isIndented: false))
        // Index 5 is People tab
        XCTAssertEqual(testee[6], .separator(isLight: true, isIndented: false))
    }
}
