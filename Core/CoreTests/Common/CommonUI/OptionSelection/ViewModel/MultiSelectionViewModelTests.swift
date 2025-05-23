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
import Combine

final class MultiSelectionViewModelTests: XCTestCase {

    private enum TestConstants {
        static let title = "some title"
        static let allItems: [OptionItem] = [
            .make(id: "0"),
            .make(id: "1"),
            .make(id: "2"),
            .make(id: "3")
        ]
        static let itemSet02: Set<OptionItem> = [
            .make(id: "0"),
            .make(id: "2")
        ]
        static let itemSet123: Set<OptionItem> = [
            .make(id: "1"),
            .make(id: "2"),
            .make(id: "3")
        ]
    }

    private var testee: MultiSelectionViewModel!
    private let inputSelectedOptions = CurrentValueSubject<Set<OptionItem>, Never>([])

    override func setUp() {
        super.setUp()
        testee = MultiSelectionViewModel(
            title: TestConstants.title,
            allOptions: TestConstants.allItems,
            selectedOptions: inputSelectedOptions
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func test_title() {
        XCTAssertEqual(testee.title, TestConstants.title)
    }

    func test_allOptions() {
        XCTAssertEqual(testee.allOptions, TestConstants.allItems)
    }

    func test_optionsCounts_whenSectionHasTitle() {
        XCTAssertEqual(testee.optionCount, TestConstants.allItems.count)
        XCTAssertEqual(testee.listLevelAccessibilityLabel, nil)
    }

    func test_optionsCounts_whenSectionHasNoTitle() {
        testee = MultiSelectionViewModel(
            title: nil,
            allOptions: TestConstants.allItems,
            selectedOptions: inputSelectedOptions
        )

        XCTAssertEqual(testee.optionCount, TestConstants.allItems.count)
        XCTAssertEqual(testee.listLevelAccessibilityLabel, "\(TestConstants.allItems.count) items")
    }

    func test_selectedOption_shouldMatchInputSubject() {
        inputSelectedOptions.send(TestConstants.itemSet02)
        XCTAssertEqual(testee.selectedOptions.value, TestConstants.itemSet02)

        testee.selectedOptions.send(TestConstants.itemSet123)
        XCTAssertEqual(inputSelectedOptions.value, TestConstants.itemSet123)
    }

    func test_didToggleSelection_whenTogglingOneItem() {
        // select item
        triggerSelection(at: 1)
        XCTAssertEqual(testee.selectedOptions.value, [TestConstants.allItems[1]])

        // select item again
        triggerSelection(at: 1)
        XCTAssertEqual(testee.selectedOptions.value, [TestConstants.allItems[1]])

        // deselect item
        triggerDeselection(at: 1)
        XCTAssertEqual(testee.selectedOptions.value, [])

        // deselect item again
        triggerDeselection(at: 1)
        XCTAssertEqual(testee.selectedOptions.value, [])
    }

    func test_didToggleSelection_whenTogglingMoreItems() {
        // select items
        triggerSelection(at: 1)
        triggerSelection(at: 2)
        XCTAssertEqual(testee.selectedOptions.value, [TestConstants.allItems[1], TestConstants.allItems[2]])

        // deselect one item
        triggerDeselection(at: 1)
        XCTAssertEqual(testee.selectedOptions.value, [TestConstants.allItems[2]])

        // deselect not selected item
        triggerDeselection(at: 3)
        XCTAssertEqual(testee.selectedOptions.value, [TestConstants.allItems[2]])
    }

    func test_allSelection() {
        let allItemsSet = Set(TestConstants.allItems)

        // none selected -> select all
        XCTAssertEqual(testee.allSelectionButtonTitle.contains("Select"), true)
        testee.didTapAllSelectionButton.send()
        XCTAssertEqual(testee.selectedOptions.value, allItemsSet)

        // some selected -> select all
        triggerDeselection(at: 1)
        XCTAssertEqual(testee.allSelectionButtonTitle.contains("Select"), true)
        testee.didTapAllSelectionButton.send()
        XCTAssertEqual(testee.selectedOptions.value, allItemsSet)

        // all selected -> deselect all
        XCTAssertEqual(testee.allSelectionButtonTitle.contains("Deselect"), true)
        testee.didTapAllSelectionButton.send()
        XCTAssertEqual(testee.selectedOptions.value, [])
    }

    func test_isOptionSelected() {
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[0]), false)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[1]), false)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[2]), false)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[3]), false)

        testee.selectedOptions.send(TestConstants.itemSet02)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[0]), true)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[1]), false)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[2]), true)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[3]), false)

        testee.selectedOptions.send(TestConstants.itemSet123)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[0]), false)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[1]), true)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[2]), true)
        XCTAssertEqual(testee.isOptionSelected(TestConstants.allItems[3]), true)
    }

    func test_dividerStyle() {
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.allItems[0]), .padded)
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.allItems[1]), .padded)
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.allItems[2]), .padded)
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.allItems[3]), .full)
    }

    private func triggerSelection(at index: Int) {
        testee.didToggleSelection.send((option: TestConstants.allItems[index], isSelected: true))
    }

    private func triggerDeselection(at index: Int) {
        testee.didToggleSelection.send((option: TestConstants.allItems[index], isSelected: false))
    }
}
