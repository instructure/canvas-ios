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
@testable import Core
import TestsFoundation

class TodoFilterViewModelTests: CoreTestCase {

    var sessionDefaults: SessionDefaults!

    override func setUp() {
        super.setUp()
        sessionDefaults = SessionDefaults(sessionID: "test-session")
    }

    override func tearDown() {
        sessionDefaults.reset()
        super.tearDown()
    }

    func testInitLoadsDefaultFiltersWhenNoSavedFilters() {
        // WHEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)

        // THEN
        XCTAssertEqual(viewModel.visibilityOptionItems.count, 4)
        XCTAssertEqual(viewModel.dateRangeStartItems.count, 6)
        XCTAssertEqual(viewModel.dateRangeEndItems.count, 6)

        XCTAssertTrue(viewModel.selectedVisibilityOptions.isEmpty)
        XCTAssertEqual(viewModel.selectedDateRangeStart, TodoDateRangeStart.lastWeek.toOptionItem())
        XCTAssertEqual(viewModel.selectedDateRangeEnd, TodoDateRangeEnd.nextWeek.toOptionItem())
    }

    func testInitLoadsSavedFilters() {
        // GIVEN
        let savedFilters = TodoFilterOptions(
            visibilityOptions: [.showPersonalTodos, .showCompleted],
            dateRangeStart: .thisWeek,
            dateRangeEnd: .inTwoWeeks
        )
        sessionDefaults.todoFilterOptions = savedFilters

        // WHEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)

        // THEN
        XCTAssertTrue(viewModel.selectedVisibilityOptions.contains(TodoVisibilityOption.showPersonalTodos.toOptionItem()))
        XCTAssertTrue(viewModel.selectedVisibilityOptions.contains(TodoVisibilityOption.showCompleted.toOptionItem()))
        XCTAssertFalse(viewModel.selectedVisibilityOptions.contains(TodoVisibilityOption.showCalendarEvents.toOptionItem()))
        XCTAssertEqual(viewModel.selectedDateRangeStart, TodoDateRangeStart.thisWeek.toOptionItem())
        XCTAssertEqual(viewModel.selectedDateRangeEnd, TodoDateRangeEnd.inTwoWeeks.toOptionItem())
    }

    func testToggleVisibility() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)
        let option = TodoVisibilityOption.showPersonalTodos.toOptionItem()

        // WHEN
        XCTAssertFalse(viewModel.selectedVisibilityOptions.contains(option))
        viewModel.selectedVisibilityOptions.insert(option)

        // THEN
        XCTAssertTrue(viewModel.selectedVisibilityOptions.contains(option))

        // WHEN
        viewModel.selectedVisibilityOptions.remove(option)

        // THEN
        XCTAssertFalse(viewModel.selectedVisibilityOptions.contains(option))
    }

    func testSelectDateRangeStart() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)
        let option = TodoDateRangeStart.thisWeek.toOptionItem()

        // WHEN
        viewModel.selectedDateRangeStart = option

        // THEN
        XCTAssertEqual(viewModel.selectedDateRangeStart, option)
    }

    func testSelectDateRangeEnd() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)
        let option = TodoDateRangeEnd.thisWeek.toOptionItem()

        // WHEN
        viewModel.selectedDateRangeEnd = option

        // THEN
        XCTAssertEqual(viewModel.selectedDateRangeEnd, option)
    }

    func testApplyFiltersSavesToSessionDefaults() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)

        // WHEN
        viewModel.selectedVisibilityOptions.insert(TodoVisibilityOption.showPersonalTodos.toOptionItem())
        viewModel.selectedVisibilityOptions.insert(TodoVisibilityOption.showCompleted.toOptionItem())
        viewModel.selectedDateRangeStart = TodoDateRangeStart.thisWeek.toOptionItem()
        viewModel.selectedDateRangeEnd = TodoDateRangeEnd.inTwoWeeks.toOptionItem()
        viewModel.applyFilters()

        // THEN
        let savedFilters = sessionDefaults.todoFilterOptions
        XCTAssertNotNil(savedFilters)
        XCTAssertEqual(savedFilters?.visibilityOptions, [.showPersonalTodos, .showCompleted])
        XCTAssertEqual(savedFilters?.dateRangeStart, .thisWeek)
        XCTAssertEqual(savedFilters?.dateRangeEnd, .inTwoWeeks)
    }
}
