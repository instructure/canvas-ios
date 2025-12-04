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

        XCTAssertTrue(viewModel.selectedVisibilityOptions.value.isEmpty)
        XCTAssertEqual(viewModel.selectedDateRangeStart.value, TodoDateRangeStart.fourWeeksAgo.toOptionItem())
        XCTAssertEqual(viewModel.selectedDateRangeEnd.value, TodoDateRangeEnd.thisWeek.toOptionItem())
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
        XCTAssertTrue(viewModel.selectedVisibilityOptions.value.contains(TodoVisibilityOption.showPersonalTodos.toOptionItem()))
        XCTAssertTrue(viewModel.selectedVisibilityOptions.value.contains(TodoVisibilityOption.showCompleted.toOptionItem()))
        XCTAssertFalse(viewModel.selectedVisibilityOptions.value.contains(TodoVisibilityOption.showCalendarEvents.toOptionItem()))
        XCTAssertEqual(viewModel.selectedDateRangeStart.value, TodoDateRangeStart.thisWeek.toOptionItem())
        XCTAssertEqual(viewModel.selectedDateRangeEnd.value, TodoDateRangeEnd.inTwoWeeks.toOptionItem())
    }

    func testToggleVisibility() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)
        let option = TodoVisibilityOption.showPersonalTodos.toOptionItem()

        // WHEN
        XCTAssertFalse(viewModel.selectedVisibilityOptions.value.contains(option))
        var updatedSet = viewModel.selectedVisibilityOptions.value
        updatedSet.insert(option)
        viewModel.selectedVisibilityOptions.send(updatedSet)

        // THEN
        XCTAssertTrue(viewModel.selectedVisibilityOptions.value.contains(option))

        // WHEN
        updatedSet = viewModel.selectedVisibilityOptions.value
        updatedSet.remove(option)
        viewModel.selectedVisibilityOptions.send(updatedSet)

        // THEN
        XCTAssertFalse(viewModel.selectedVisibilityOptions.value.contains(option))
    }

    func testSelectDateRangeStart() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)
        let option = TodoDateRangeStart.thisWeek.toOptionItem()

        // WHEN
        viewModel.selectedDateRangeStart.send(option)

        // THEN
        XCTAssertEqual(viewModel.selectedDateRangeStart.value, option)
    }

    func testSelectDateRangeEnd() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)
        let option = TodoDateRangeEnd.thisWeek.toOptionItem()

        // WHEN
        viewModel.selectedDateRangeEnd.send(option)

        // THEN
        XCTAssertEqual(viewModel.selectedDateRangeEnd.value, option)
    }

    func testApplyFiltersSavesToSessionDefaults() {
        // GIVEN
        let viewModel = TodoFilterViewModel(sessionDefaults: sessionDefaults)

        // WHEN
        var updatedSet = viewModel.selectedVisibilityOptions.value
        updatedSet.insert(TodoVisibilityOption.showPersonalTodos.toOptionItem())
        updatedSet.insert(TodoVisibilityOption.showCompleted.toOptionItem())
        viewModel.selectedVisibilityOptions.send(updatedSet)
        viewModel.selectedDateRangeStart.send(TodoDateRangeStart.thisWeek.toOptionItem())
        viewModel.selectedDateRangeEnd.send(TodoDateRangeEnd.inTwoWeeks.toOptionItem())
        viewModel.applyFilters()

        // THEN
        let savedFilters = sessionDefaults.todoFilterOptions
        XCTAssertNotNil(savedFilters)
        XCTAssertEqual(savedFilters?.visibilityOptions, [.showPersonalTodos, .showCompleted])
        XCTAssertEqual(savedFilters?.dateRangeStart, .thisWeek)
        XCTAssertEqual(savedFilters?.dateRangeEnd, .inTwoWeeks)
    }
}
