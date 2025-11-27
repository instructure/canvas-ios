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

class TodoFilterOptionsAnalyticsTests: XCTestCase {

    // MARK: - Analytics Event Name

    func test_analyticsEventName_returnsDefaultEvent_whenFilterIsDefault() {
        // GIVEN
        let filterOptions = TodoFilterOptions.default

        // THEN
        XCTAssertEqual(filterOptions.analyticsEventName, "todo_list_loaded_default_filter")
    }

    func test_analyticsEventName_returnsCustomEvent_whenFilterIsNotDefault() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showPersonalTodos],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // THEN
        XCTAssertEqual(filterOptions.analyticsEventName, "todo_list_loaded_custom_filter")
    }

    // MARK: - Analytics Parameters

    func test_analyticsParameters_includesAllRequiredKeys() {
        // GIVEN
        let filterOptions = TodoFilterOptions.default

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertNotNil(parameters["filter_personal_todos"])
        XCTAssertNotNil(parameters["filter_calendar_events"])
        XCTAssertNotNil(parameters["filter_show_completed"])
        XCTAssertNotNil(parameters["filter_favourite_courses"])
        XCTAssertNotNil(parameters["filter_selected_date_range_past"])
        XCTAssertNotNil(parameters["filter_selected_date_range_future"])
    }

    func test_analyticsParameters_showPersonalTodos_isFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_personal_todos"] as? Bool, false)
    }

    func test_analyticsParameters_showPersonalTodos_isTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showPersonalTodos],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_personal_todos"] as? Bool, true)
    }

    func test_analyticsParameters_showCalendarEvents_isFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_calendar_events"] as? Bool, false)
    }

    func test_analyticsParameters_showCalendarEvents_isTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showCalendarEvents],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_calendar_events"] as? Bool, true)
    }

    func test_analyticsParameters_showCompleted_isFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_show_completed"] as? Bool, false)
    }

    func test_analyticsParameters_showCompleted_isTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.showCompleted],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_show_completed"] as? Bool, true)
    }

    func test_analyticsParameters_favouriteCourses_isFalse_whenNotIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_favourite_courses"] as? Bool, false)
    }

    func test_analyticsParameters_favouriteCourses_isTrue_whenIncluded() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [.favouriteCoursesOnly],
            dateRangeStart: .today,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_favourite_courses"] as? Bool, true)
    }

    func test_analyticsParameters_includesDateRangeStart() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .twoWeeksAgo,
            dateRangeEnd: .thisWeek
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_selected_date_range_past"] as? String, "two_weeks")
    }

    func test_analyticsParameters_includesDateRangeEnd() {
        // GIVEN
        let filterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .today,
            dateRangeEnd: .inThreeWeeks
        )

        // WHEN
        let parameters = filterOptions.analyticsParameters

        // THEN
        XCTAssertEqual(parameters["filter_selected_date_range_future"] as? String, "three_weeks")
    }

    // MARK: - TodoDateRangeStart Analytics Value

    func test_dateRangeStart_analyticsValue_today() {
        // THEN
        XCTAssertEqual(TodoDateRangeStart.today.analyticsValue, "today")
    }

    func test_dateRangeStart_analyticsValue_thisWeek() {
        // THEN
        XCTAssertEqual(TodoDateRangeStart.thisWeek.analyticsValue, "this_week")
    }

    func test_dateRangeStart_analyticsValue_lastWeek() {
        // THEN
        XCTAssertEqual(TodoDateRangeStart.lastWeek.analyticsValue, "one_week")
    }

    func test_dateRangeStart_analyticsValue_twoWeeksAgo() {
        // THEN
        XCTAssertEqual(TodoDateRangeStart.twoWeeksAgo.analyticsValue, "two_weeks")
    }

    func test_dateRangeStart_analyticsValue_threeWeeksAgo() {
        // THEN
        XCTAssertEqual(TodoDateRangeStart.threeWeeksAgo.analyticsValue, "three_weeks")
    }

    func test_dateRangeStart_analyticsValue_fourWeeksAgo() {
        // THEN
        XCTAssertEqual(TodoDateRangeStart.fourWeeksAgo.analyticsValue, "four_weeks")
    }

    // MARK: - TodoDateRangeEnd Analytics Value

    func test_dateRangeEnd_analyticsValue_today() {
        // THEN
        XCTAssertEqual(TodoDateRangeEnd.today.analyticsValue, "today")
    }

    func test_dateRangeEnd_analyticsValue_thisWeek() {
        // THEN
        XCTAssertEqual(TodoDateRangeEnd.thisWeek.analyticsValue, "this_week")
    }

    func test_dateRangeEnd_analyticsValue_nextWeek() {
        // THEN
        XCTAssertEqual(TodoDateRangeEnd.nextWeek.analyticsValue, "one_week")
    }

    func test_dateRangeEnd_analyticsValue_inTwoWeeks() {
        // THEN
        XCTAssertEqual(TodoDateRangeEnd.inTwoWeeks.analyticsValue, "two_weeks")
    }

    func test_dateRangeEnd_analyticsValue_inThreeWeeks() {
        // THEN
        XCTAssertEqual(TodoDateRangeEnd.inThreeWeeks.analyticsValue, "three_weeks")
    }

    func test_dateRangeEnd_analyticsValue_inFourWeeks() {
        // THEN
        XCTAssertEqual(TodoDateRangeEnd.inFourWeeks.analyticsValue, "four_weeks")
    }
}
