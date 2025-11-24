//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI

public enum TodoVisibilityOption: String, CaseIterable, Codable, Hashable {
    case showPersonalTodos
    case showCalendarEvents
    case showCompleted
    case favouriteCoursesOnly

    var title: String {
        switch self {
        case .showPersonalTodos: String(localized: "Show Personal To-dos", bundle: .core)
        case .showCalendarEvents: String(localized: "Show Calendar Events", bundle: .core)
        case .showCompleted: String(localized: "Show Completed", bundle: .core)
        case .favouriteCoursesOnly: String(localized: "Favorite Courses Only", bundle: .core)
        }
    }
}

// MARK: - OptionItem Conversion

extension TodoVisibilityOption {
    func toOptionItem() -> OptionItem {
        OptionItem(
            id: rawValue,
            title: title
        )
    }

    static func from(optionItem: OptionItem) -> TodoVisibilityOption? {
        TodoVisibilityOption(rawValue: optionItem.id)
    }

    static let allOptionItems: [OptionItem] = allCases.map { $0.toOptionItem() }
}

// MARK: - Filtering

extension Set where Element == TodoVisibilityOption {

    func shouldInclude(plannableType: PlannableType) -> Bool {
        switch plannableType {
        case .planner_note:
            return contains(.showPersonalTodos)
        case .calendar_event:
            return contains(.showCalendarEvents)
        default:
            return true
        }
    }

    func shouldInclude(isCompleted: Bool, isSubmitted: Bool) -> Bool {
        if contains(.showCompleted) {
            return isCompleted || isSubmitted
        }
        return true
    }

    func shouldInclude(isFavorite: Bool?, hasNoCourse: Bool) -> Bool {
        if contains(.favouriteCoursesOnly) {
            return hasNoCourse || (isFavorite == true)
        }
        return true
    }
}
