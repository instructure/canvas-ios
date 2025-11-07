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

    public var title: String {
        switch self {
        case .showPersonalTodos:
            return String(localized: "Show Personal To Dos", bundle: .core)
        case .showCalendarEvents:
            return String(localized: "Show Calendar Events", bundle: .core)
        case .showCompleted:
            return String(localized: "Show Completed", bundle: .core)
        case .favouriteCoursesOnly:
            return String(localized: "Favourite Courses Only", bundle: .core)
        }
    }
}

// MARK: - OptionItem Conversion

extension TodoVisibilityOption {
    public func toOptionItem() -> OptionItem {
        OptionItem(
            id: rawValue,
            title: title
        )
    }

    public static func from(optionItem: OptionItem) -> TodoVisibilityOption? {
        TodoVisibilityOption(rawValue: optionItem.id)
    }

    public static var allOptionItems: [OptionItem] {
        allCases.map { $0.toOptionItem() }
    }
}

// MARK: - Filtering

extension Set where Element == TodoVisibilityOption {

    public func shouldInclude(plannableType: PlannableType) -> Bool {
        switch plannableType {
        case .planner_note:
            return contains(.showPersonalTodos)
        case .calendar_event:
            return contains(.showCalendarEvents)
        default:
            return true
        }
    }

    public func shouldInclude(isCompleted: Bool, isSubmitted: Bool) -> Bool {
        if isCompleted || isSubmitted {
            return contains(.showCompleted)
        }
        return true
    }

    public func shouldInclude(isFavorite: Bool?, hasNoCourse: Bool) -> Bool {
        if contains(.favouriteCoursesOnly) {
            return hasNoCourse || (isFavorite == true)
        }
        return true
    }
}
