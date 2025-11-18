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

extension TodoFilterOptions {

    public var analyticsEventName: String {
        isDefault ? "todo_list_loaded_default_filter" : "todo_list_loaded_custom_filter"
    }

    public var analyticsParameters: [String: Any] {
        [
            "filter_personal_todos": visibilityOptions.contains(.showPersonalTodos),
            "filter_calendar_events": visibilityOptions.contains(.showCalendarEvents),
            "filter_show_completed": visibilityOptions.contains(.showCompleted),
            "filter_favourite_courses": visibilityOptions.contains(.favouriteCoursesOnly),
            "filter_selected_date_range_past": dateRangeStart.analyticsValue,
            "filter_selected_date_range_future": dateRangeEnd.analyticsValue
        ]
    }
}

extension TodoDateRangeStart {

    public var analyticsValue: String {
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

    public var analyticsValue: String {
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
