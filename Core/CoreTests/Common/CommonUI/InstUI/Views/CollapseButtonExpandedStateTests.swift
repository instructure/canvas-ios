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

final class CollapseButtonExpandedStateTests: CoreTestCase {

    private var testee: InstUI.CollapseButtonExpandedState!

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_whenExpandedTrue_shouldSetIsExpandedToTrue() {
        testee = InstUI.CollapseButtonExpandedState(isExpanded: true)

        XCTAssertContains(testee.a11yValue, "Expanded")
    }

    func test_init_whenExpandedFalse_shouldSetIsExpandedToFalse() {
        testee = InstUI.CollapseButtonExpandedState(isExpanded: false)

        XCTAssertContains(testee.a11yValue, "Collapsed")
    }

    // MARK: - a11yValue

    func test_a11yValue_whenExpanded_shouldReturnExpandedValue() {
        testee = .init(isExpanded: true)

        XCTAssertEqual(
            testee.a11yValue,
            InstUI.CollapseButtonExpandedState.expanded.a11yValue
        )
    }

    func test_a11yValue_whenCollapsed_shouldReturnCollapsedValue() {
        testee = .init(isExpanded: false)

        XCTAssertEqual(
            testee.a11yValue,
            InstUI.CollapseButtonExpandedState.collapsed.a11yValue
        )
    }

    // MARK: - a11yHint

    func test_a11yHint_whenExpanded_shouldReturnExpandedHint() {
        testee = .init(isExpanded: true)

        XCTAssertEqual(
            testee.a11yHint,
            InstUI.CollapseButtonExpandedState.expanded.a11yHint
        )
    }

    func test_a11yHint_whenCollapsed_shouldReturnCollapsedHint() {
        testee = .init(isExpanded: false)

        XCTAssertEqual(
            testee.a11yHint,
            InstUI.CollapseButtonExpandedState.collapsed.a11yHint
        )
    }

    // MARK: - a11yActionLabel

    func test_a11yActionLabel_whenExpanded_shouldReturnExpandedActionLabel() {
        testee = .init(isExpanded: true)

        XCTAssertEqual(
            testee.a11yActionLabel,
            InstUI.CollapseButtonExpandedState.expanded.a11yActionLabel
        )
    }

    func test_a11yActionLabel_whenCollapsed_shouldReturnCollapsedActionLabel() {
        testee = .init(isExpanded: false)

        XCTAssertEqual(
            testee.a11yActionLabel,
            InstUI.CollapseButtonExpandedState.collapsed.a11yActionLabel
        )
    }

    // MARK: - Static properties

    func test_expanded_shouldReturnCorrectStrings() {
        let expanded = InstUI.CollapseButtonExpandedState.expanded

        XCTAssertContains(expanded.a11yValue, "Expanded")
        XCTAssertEqual(expanded.a11yHint, "Double-tap to collapse")
        XCTAssertEqual(expanded.a11yActionLabel, "Collapse")
    }

    func test_collapsed_shouldReturnCorrectStrings() {
        let collapsed = InstUI.CollapseButtonExpandedState.collapsed

        XCTAssertContains(collapsed.a11yValue, "Collapsed")
        XCTAssertEqual(collapsed.a11yHint, "Double-tap to expand")
        XCTAssertEqual(collapsed.a11yActionLabel, "Expand")
    }
}
