//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import TestsFoundation
@testable import Core

final class MultiSelectionOptionsTests: XCTestCase {

    private enum TestConstants {
        static let allItems: [OptionItem] = [
            .make(id: "0"),
            .make(id: "1"),
            .make(id: "2"),
            .make(id: "3")
        ]
        static let itemSet1: Set<OptionItem> = [
            .make(id: "0"),
            .make(id: "2")
        ]
        static let itemSet2: Set<OptionItem> = [
            .make(id: "1"),
            .make(id: "2"),
            .make(id: "3")
        ]
    }

    func test_init_whenInitialIsProvided_shouldPopulateSelected() {
        let testee = MultiSelectionOptions(
            all: TestConstants.allItems,
            initial: TestConstants.itemSet1
        )

        XCTAssertEqual(testee.selected.value, TestConstants.itemSet1)
    }

    func test_init_whenSelectedIsProvided_shouldPopulateInitial() {
        let testee = MultiSelectionOptions(
            all: TestConstants.allItems,
            selected: .init(TestConstants.itemSet1)
        )

        // select something else
        testee.selected.send(TestConstants.itemSet2)
        XCTAssertEqual(testee.selected.value, TestConstants.itemSet2)

        // reset to initial
        testee.resetSelection()
        XCTAssertEqual(testee.selected.value, TestConstants.itemSet1)
    }

    func test_reset_shouldReselectInitial() {
        let testee = MultiSelectionOptions(
            all: TestConstants.allItems,
            initial: TestConstants.itemSet1
        )
        testee.selected.send(TestConstants.itemSet2)

        testee.resetSelection()
        XCTAssertEqual(testee.selected.value, TestConstants.itemSet1)
    }

    func test_hasChanges() {
        let testee = MultiSelectionOptions(
            all: TestConstants.allItems,
            initial: TestConstants.itemSet1
        )

        // initial state
        XCTAssertEqual(testee.hasChanges, false)

        // set the same value
        testee.selected.send(TestConstants.itemSet1)
        XCTAssertEqual(testee.hasChanges, false)

        // set another value
        testee.selected.send(TestConstants.itemSet2)
        XCTAssertEqual(testee.hasChanges, true)

        // reset to initial value
        testee.resetSelection()
        XCTAssertEqual(testee.hasChanges, false)
    }

    func test_isAllSelected() {
        let testee = MultiSelectionOptions(all: TestConstants.allItems, initial: [])

        testee.selected.send(TestConstants.itemSet1)
        XCTAssertEqual(testee.isAllSelected, false)

        testee.selected.send(Set(TestConstants.allItems))
        XCTAssertEqual(testee.isAllSelected, true)

        testee.selected.send([])
        XCTAssertEqual(testee.isAllSelected, false)
    }

    func test_isAllUnselected() {
        let testee = MultiSelectionOptions(all: TestConstants.allItems, initial: [])

        testee.selected.send(TestConstants.itemSet1)
        XCTAssertEqual(testee.isAllUnselected, false)

        testee.selected.send(Set(TestConstants.allItems))
        XCTAssertEqual(testee.isAllUnselected, false)

        testee.selected.send([])
        XCTAssertEqual(testee.isAllUnselected, true)
    }
}
