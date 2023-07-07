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

import XCTest
@testable import Core

class CourseEntrySelectionTests: XCTestCase {
    func testCourseOrdering() {
        let testee1: CourseEntrySelection = .course("0")
        let testee2: CourseEntrySelection = .course("1")

        let array = [testee1, testee2].sorted()

        XCTAssertEqual(array[0], testee1)
        XCTAssertEqual(array[1], testee2)
    }

    func testCourseAndTabOrdering() {
        let testee1: CourseEntrySelection = .tab("0", "0")
        let testee2: CourseEntrySelection = .tab("1", "1")

        let array = [testee1, testee2].sorted()

        XCTAssertEqual(array[0], testee1)
        XCTAssertEqual(array[1], testee2)
    }

    func testTabOrdering() {
        let testee1: CourseEntrySelection = .tab("0", "0")
        let testee2: CourseEntrySelection = .tab("0", "1")

        let array = [testee1, testee2].sorted()

        XCTAssertEqual(array[0], testee1)
        XCTAssertEqual(array[1], testee2)
    }

    func testCourseAndFileOrdering() {
        let testee1: CourseEntrySelection = .file("0", "1")
        let testee2: CourseEntrySelection = .file("1", "1")

        let array = [testee1, testee2].sorted()

        XCTAssertEqual(array[0], testee1)
        XCTAssertEqual(array[1], testee2)
    }

    func testFileOrdering() {
        let testee1: CourseEntrySelection = .file("0", "0")
        let testee2: CourseEntrySelection = .file("0", "1")

        let array = [testee1, testee2].sorted()

        XCTAssertEqual(array[0], testee1)
        XCTAssertEqual(array[1], testee2)
    }

    func testSelectionOrdering() {
        let testee1: CourseEntrySelection = .course("0")
        let testee2: CourseEntrySelection = .tab("0", "0")
        let testee3: CourseEntrySelection = .file("0", "0")

        let array = [testee1, testee2, testee3].sorted()

        XCTAssertEqual(array[0], testee1)
        XCTAssertEqual(array[1], testee2)
        XCTAssertEqual(array[2], testee3)
    }
}
