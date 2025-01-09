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

final class SingleSelectionOptionsTests: XCTestCase {

    private enum TestConstants {
        static let items: [OptionItem] = [
            .make(id: "0"),
            .make(id: "1"),
            .make(id: "2"),
            .make(id: "3")
        ]
    }

    func test_init_whenInitialIsProvided_shouldPopulateSelected() {
        let testee = SingleSelectionOptions(
            all: TestConstants.items,
            initial: TestConstants.items[3]
        )

        XCTAssertEqual(testee.selected.value, TestConstants.items[3])
    }

    func test_init_whenSelectedIsProvided_shouldPopulateInitial() {
        let testee = SingleSelectionOptions(
            all: TestConstants.items,
            selected: .init(TestConstants.items[3])
        )

        // select something else
        testee.selected.send(TestConstants.items[1])
        XCTAssertEqual(testee.selected.value, TestConstants.items[1])

        // reset to initial
        testee.resetSelection()
        XCTAssertEqual(testee.selected.value, TestConstants.items[3])
    }

    func test_reset_shouldReselectInitial() {
        let testee = SingleSelectionOptions(
            all: TestConstants.items,
            initial: TestConstants.items[3]
        )
        testee.selected.send(TestConstants.items[1])

        testee.resetSelection()
        XCTAssertEqual(testee.selected.value, TestConstants.items[3])
    }

    func test_hasChanges() {
        let testee = SingleSelectionOptions(
            all: TestConstants.items,
            initial: TestConstants.items[3]
        )

        // initial state
        XCTAssertEqual(testee.hasChanges, false)

        // set the same value
        testee.selected.send(TestConstants.items[3])
        XCTAssertEqual(testee.hasChanges, false)

        // set another value
        testee.selected.send(TestConstants.items[1])
        XCTAssertEqual(testee.hasChanges, true)

        // reset to initial value
        testee.resetSelection()
        XCTAssertEqual(testee.hasChanges, false)
    }
}
