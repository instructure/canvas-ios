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

@testable import Core
import XCTest

class AnalyticsTodoEventTests: CoreTestCase {

    // MARK: - Analytics Event Name

    func test_logsDefaultEvent_whenFilterIsDefault() {
        // GIVEN
        let filterOptions = TodoFilterOptions.default

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEvent, "todo_list_loaded_default_filter")
    }

    func test_logsCustomEvent_whenFilterIsNotDefault() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showPersonalTodos],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEvent, "todo_list_loaded_custom_filter")
    }

    // MARK: - Analytics Parameters

    func test_logsAllRequiredParameters() {
        // GIVEN
        let filterOptions = TodoFilterOptions.default

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertNotNil(analytics.lastEventParameter("filter_personal_todos", ofType: Bool.self))
        XCTAssertNotNil(analytics.lastEventParameter("filter_calendar_events", ofType: Bool.self))
        XCTAssertNotNil(analytics.lastEventParameter("filter_show_completed", ofType: Bool.self))
        XCTAssertNotNil(analytics.lastEventParameter("filter_favourite_courses", ofType: Bool.self))
        XCTAssertNotNil(analytics.lastEventParameter("filter_selected_date_range_past", ofType: String.self))
        XCTAssertNotNil(analytics.lastEventParameter("filter_selected_date_range_future", ofType: String.self))
    }

    func test_logsShowPersonalTodos_asFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_personal_todos", ofType: Bool.self), false)
    }

    func test_logsShowPersonalTodos_asTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showPersonalTodos],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_personal_todos", ofType: Bool.self), true)
    }

    func test_logsShowCalendarEvents_asFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_calendar_events", ofType: Bool.self), false)
    }

    func test_logsShowCalendarEvents_asTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showCalendarEvents],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_calendar_events", ofType: Bool.self), true)
    }

    func test_logsShowCompleted_asFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_show_completed", ofType: Bool.self), false)
    }

    func test_logsShowCompleted_asTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showCompleted],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_show_completed", ofType: Bool.self), true)
    }

    func test_logsFavouriteCourses_asFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_favourite_courses", ofType: Bool.self), false)
    }

    func test_logsFavouriteCourses_asTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.favouriteCoursesOnly],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_favourite_courses", ofType: Bool.self), true)
    }

    func test_logsDateRangeStart() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .twoWeeksAgo,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_selected_date_range_past", ofType: String.self), "two_weeks")
    }

    func test_logsDateRangeEnd() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .inThreeWeeks
        )

        // WHEN
        Analytics.shared.logTodoEvent(.filterApplied(filterOptions))

        // THEN
        XCTAssertEqual(analytics.lastEventParameter("filter_selected_date_range_future", ofType: String.self), "three_weeks")
    }

    // MARK: - TodoDateRangeStart Analytics Value

    func test_dateRangeStart_analyticsValue() {
        // THEN
        XCTAssertEqual(TodoDateRangeStart.today.analyticsValue, "today")
        XCTAssertEqual(TodoDateRangeStart.thisWeek.analyticsValue, "this_week")
        XCTAssertEqual(TodoDateRangeStart.lastWeek.analyticsValue, "one_week")
        XCTAssertEqual(TodoDateRangeStart.twoWeeksAgo.analyticsValue, "two_weeks")
        XCTAssertEqual(TodoDateRangeStart.threeWeeksAgo.analyticsValue, "three_weeks")
        XCTAssertEqual(TodoDateRangeStart.fourWeeksAgo.analyticsValue, "four_weeks")
    }

    // MARK: - TodoDateRangeEnd Analytics Value

    func test_dateRangeEnd_analyticsValue() {
        XCTAssertEqual(TodoDateRangeEnd.today.analyticsValue, "today")
        XCTAssertEqual(TodoDateRangeEnd.thisWeek.analyticsValue, "this_week")
        XCTAssertEqual(TodoDateRangeEnd.nextWeek.analyticsValue, "one_week")
        XCTAssertEqual(TodoDateRangeEnd.inTwoWeeks.analyticsValue, "two_weeks")
        XCTAssertEqual(TodoDateRangeEnd.inThreeWeeks.analyticsValue, "three_weeks")
        XCTAssertEqual(TodoDateRangeEnd.inFourWeeks.analyticsValue, "four_weeks")
    }

    // MARK: - Item Marked Done/Undone Events

    func test_logsItemMarkedDone() {
        // WHEN
        Analytics.shared.logTodoEvent(.itemMarkedDone)

        // THEN
        XCTAssertEqual(analytics.lastEvent, "todo_item_marked_done")
        XCTAssertNil(analytics.lastEventParameters)
    }

    func test_logsItemMarkedUndone() {
        // WHEN
        Analytics.shared.logTodoEvent(.itemMarkedUndone)

        // THEN
        XCTAssertEqual(analytics.lastEvent, "todo_item_marked_undone")
        XCTAssertNil(analytics.lastEventParameters)
    }
}
