//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Student

final class WeeklySummaryWidgetViewModelTests: StudentTestCase {

    // MARK: - Basic properties

    func test_basicProperties() {
        let testee = makeViewModel()

        XCTAssertEqual(testee.config.id, .weeklySummary)
        XCTAssertEqual(testee.isEditable, false)
        XCTAssertEqual(testee.isHiddenInEmptyState, false)
        XCTAssertEqual(testee.state, .loading)
    }

    // MARK: - refresh

    func test_refresh_shouldTransitionToDataState() {
        let testee = makeViewModel()
        XCTAssertEqual(testee.state, .loading)

        XCTAssertFinish(testee.refresh(ignoreCache: false), timeout: 5)

        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - Initial filter state

    func test_initialFilters() {
        let testee = makeViewModel()

        XCTAssertEqual(testee.missingFilter.id, "missing")
        XCTAssertEqual(testee.dueFilter.id, "due")
        XCTAssertEqual(testee.newGradesFilter.id, "newGrades")
        XCTAssertEqual(testee.expandedFilter, nil)
    }

    // MARK: - weekStartDate

    func test_weekStartDate_shouldBeMonday() {
        let testee = makeViewModel()

        let weekday = Calendar.current.component(.weekday, from: testee.weekStartDate)
        XCTAssertEqual(weekday, 2)
    }

    // MARK: - weekRangeText

    func test_weekRangeText_shouldFormatCorrectly() {
        let testee = makeViewModel()
        let endDate = testee.weekStartDate.addDays(6)
        let year = Calendar.current.component(.year, from: endDate)
        let expected = "\(testee.weekStartDate.shortDayMonth) - \(endDate.shortDayMonth) \(year)"

        XCTAssertEqual(testee.weekRangeText, expected)
    }

    // MARK: - Week navigation

    func test_weekNavigation_shouldAdjustWeekStartDateBySevenDays() {
        let testee = makeViewModel()
        let initial = testee.weekStartDate

        // WHEN navigating to previous week
        testee.navigateToPreviousWeek()
        // THEN
        XCTAssertEqual(testee.weekStartDate, initial.addDays(-7))

        // WHEN navigating back to next week
        testee.navigateToNextWeek()
        // THEN
        XCTAssertEqual(testee.weekStartDate, initial)
    }

    func test_weekNavigation_shouldUpdateWeekRangeText() {
        let testee = makeViewModel()
        let initialText = testee.weekRangeText

        testee.navigateToPreviousWeek()

        XCTAssertNotEqual(testee.weekRangeText, initialText)
        let endDate = testee.weekStartDate.addDays(6)
        let year = Calendar.current.component(.year, from: endDate)
        XCTAssertEqual(testee.weekRangeText, "\(testee.weekStartDate.shortDayMonth) - \(endDate.shortDayMonth) \(year)")
    }

    // MARK: - toggleFilter

    func test_toggleFilter_shouldExpandSelectedFilter() {
        let testee = makeViewModel()

        testee.toggleFilter(testee.missingFilter)

        XCTAssertEqual(testee.expandedFilter?.id, "missing")
    }

    func test_toggleFilter_whenSameFilter_shouldCollapse() {
        let testee = makeViewModel()
        testee.toggleFilter(testee.dueFilter)
        XCTAssertEqual(testee.expandedFilter?.id, "due")

        testee.toggleFilter(testee.dueFilter)

        XCTAssertEqual(testee.expandedFilter, nil)
    }

    func test_toggleFilter_whenDifferentFilter_shouldSwitchExpanded() {
        let testee = makeViewModel()
        testee.toggleFilter(testee.missingFilter)
        XCTAssertEqual(testee.expandedFilter?.id, "missing")

        testee.toggleFilter(testee.dueFilter)

        XCTAssertEqual(testee.expandedFilter?.id, "due")
    }

    func test_toggleFilter_shouldUpdateNamedFilterA11yStates() {
        let testee = makeViewModel()
        let expandedState = InstUI.CollapseButtonExpandedState(isExpanded: true)
        let collapsedState = InstUI.CollapseButtonExpandedState(isExpanded: false)

        testee.toggleFilter(testee.missingFilter)

        XCTAssertEqual(testee.missingFilter.accessibilityValue, expandedState.a11yValue)
        XCTAssertEqual(testee.dueFilter.accessibilityValue, collapsedState.a11yValue)
        XCTAssertEqual(testee.newGradesFilter.accessibilityValue, collapsedState.a11yValue)
    }

    // MARK: - layoutIdentifier

    func test_layoutIdentifier_shouldChangeWhenExpandedFilterChanges() {
        let testee = makeViewModel()
        let initial = testee.layoutIdentifier

        testee.toggleFilter(testee.missingFilter)

        XCTAssertNotEqual(testee.layoutIdentifier, initial)
    }

    func test_layoutIdentifier_shouldChangeWhenWeekChanges() {
        let testee = makeViewModel()
        let initial = testee.layoutIdentifier

        testee.navigateToNextWeek()

        XCTAssertNotEqual(testee.layoutIdentifier, initial)
    }

    // MARK: - Private helpers

    private func makeViewModel() -> WeeklySummaryWidgetViewModel {
        WeeklySummaryWidgetViewModel(config: .make(id: .weeklySummary))
    }
}
