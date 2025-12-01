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

import Foundation

extension Analytics {

    public enum TodoEvent {
        case filterApplied(TodoFilterOptions)
        case itemMarkedDone
        case itemMarkedUndone
    }

    public func logTodoEvent(
        _ event: TodoEvent,
        additionalParams: [TodoEvent.Param: Any]? = nil
    ) {
        let allParams = (event.params ?? [:])
            .merging(additionalParams ?? [:], uniquingKeysWith: { $1 })
            .nilIfEmpty?
            .reduce(into: [String: Any]()) { partialResult, pair in
                partialResult[pair.key.rawValue] = pair.value
            }

        logEvent(event.analyticsEventName, parameters: allParams)
    }
}

extension Analytics.TodoEvent {

    public enum Param: String {
        case filter_personal_todos
        case filter_calendar_events
        case filter_show_completed
        case filter_favourite_courses
        case filter_selected_date_range_past
        case filter_selected_date_range_future
    }
}

private extension Analytics.TodoEvent {

    var analyticsEventName: String {
        switch self {
        case .filterApplied(let filterOptions):
            filterOptions.isDefault ? "todo_list_loaded_default_filter" : "todo_list_loaded_custom_filter"
        case .itemMarkedDone:
            "todo_item_marked_done"
        case .itemMarkedUndone:
            "todo_item_marked_undone"
        }
    }

    var params: [Param: Any]? {
        switch self {
        case .filterApplied(let filterOptions):
            return [
                .filter_personal_todos: filterOptions.visibilityOptions.contains(.showPersonalTodos),
                .filter_calendar_events: filterOptions.visibilityOptions.contains(.showCalendarEvents),
                .filter_show_completed: filterOptions.visibilityOptions.contains(.showCompleted),
                .filter_favourite_courses: filterOptions.visibilityOptions.contains(.favouriteCoursesOnly),
                .filter_selected_date_range_past: filterOptions.dateRangeStart.analyticsValue,
                .filter_selected_date_range_future: filterOptions.dateRangeEnd.analyticsValue
            ]
        case .itemMarkedDone, .itemMarkedUndone:
            return nil
        }
    }
}

extension TodoDateRangeStart {

    var analyticsValue: String {
        switch self {
        case .today: "today"
        case .thisWeek: "this_week"
        case .lastWeek: "one_week"
        case .twoWeeksAgo: "two_weeks"
        case .threeWeeksAgo: "three_weeks"
        case .fourWeeksAgo: "four_weeks"
        }
    }
}

extension TodoDateRangeEnd {

    var analyticsValue: String {
        switch self {
        case .today: "today"
        case .thisWeek: "this_week"
        case .nextWeek: "one_week"
        case .inTwoWeeks: "two_weeks"
        case .inThreeWeeks: "three_weeks"
        case .inFourWeeks: "four_weeks"
        }
    }
}
