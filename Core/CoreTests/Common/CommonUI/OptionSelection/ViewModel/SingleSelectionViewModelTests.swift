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

final class SingleSelectionViewModelTests: XCTestCase {

    private enum TestConstants {
        static let title = "some title"
        static let items: [OptionItem] = [
            .make(id: "0"),
            .make(id: "1"),
            .make(id: "2"),
            .make(id: "3")
        ]
    }

    private var testee: SingleSelectionViewModel!
    private let inputSelectedOption = CurrentValueSubject<OptionItem?, Never>(nil)
    private let inputDidSelectOption = PassthroughSubject<OptionItem?, Never>()

    override func setUp() {
        super.setUp()
        testee = makeViewModel(
            selectedOptionSubject: inputSelectedOption,
            didSelectOption: nil
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
        XCTAssertEqual(testee.allOptions, TestConstants.items)
    }

    func test_optionCounts_whenSectionHasTitle() {
        XCTAssertEqual(testee.optionCount, TestConstants.items.count)
        XCTAssertEqual(testee.listLevelAccessibilityLabel, nil)
    }

    func test_optionCounts_whenSectionHasNoTitle() {
        testee = SingleSelectionViewModel(
            title: nil,
            allOptions: TestConstants.items,
            selectedOption: inputSelectedOption
        )

        XCTAssertEqual(testee.optionCount, TestConstants.items.count)
        XCTAssertEqual(testee.listLevelAccessibilityLabel, "List, \(TestConstants.items.count) items")
    }

    func test_selectedOption_whenDidSelectOptionIsNotUsed() {
        testee = makeViewModel(
            selectedOptionSubject: inputSelectedOption,
            didSelectOption: nil
        )

        inputSelectedOption.send(TestConstants.items[1])
        XCTAssertEqual(testee.selectedOption, TestConstants.items[1])
        XCTAssertEqual(testee.selectedOptionSubject.value, TestConstants.items[1])

        testee.selectedOptionSubject.send(TestConstants.items[3])
        XCTAssertEqual(testee.selectedOption, TestConstants.items[3])
        XCTAssertEqual(inputSelectedOption.value, TestConstants.items[3])
    }

    func test_selectedOption_whenDidSelectOptionIsUsed() {
        testee = makeViewModel(
            selectedOptionSubject: inputSelectedOption,
            didSelectOption: inputDidSelectOption
        )

        inputSelectedOption.send(TestConstants.items[1])
        XCTAssertEqual(testee.selectedOption, TestConstants.items[1])
        XCTAssertEqual(testee.selectedOptionSubject.value, TestConstants.items[1])
        XCTAssertNoOutput(inputDidSelectOption)

        testee.selectedOptionSubject.send(TestConstants.items[3])
        XCTAssertEqual(testee.selectedOption, TestConstants.items[3])
        XCTAssertEqual(inputSelectedOption.value, TestConstants.items[3])
        XCTAssertNoOutput(inputDidSelectOption)

        inputDidSelectOption.send(TestConstants.items[0])
        XCTAssertEqual(testee.selectedOption, TestConstants.items[0])
        XCTAssertEqual(inputSelectedOption.value, TestConstants.items[3])
        XCTAssertEqual(testee.selectedOptionSubject.value, TestConstants.items[3])

    }

    func test_dividerStyle() {
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.items[0]), .padded)
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.items[1]), .padded)
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.items[2]), .padded)
        XCTAssertEqual(testee.dividerStyle(for: TestConstants.items[3]), .full)
    }

    private func makeViewModel(
        title: String? = TestConstants.title,
        allOptions: [OptionItem] = TestConstants.items,
        selectedOptionSubject: CurrentValueSubject<OptionItem?, Never>,
        didSelectOption: PassthroughSubject<OptionItem?, Never>?
    ) -> SingleSelectionViewModel {
        .init(
            title: title,
            allOptions: allOptions,
            selectedOption: selectedOptionSubject,
            didSelectOption: didSelectOption
        )
    }
}
