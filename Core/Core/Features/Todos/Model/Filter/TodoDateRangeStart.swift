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

public enum TodoDateRangeStart: String, CaseIterable, Codable {
    case fourWeeksAgo = "start-fourWeeksAgo"
    case threeWeeksAgo = "start-threeWeeksAgo"
    case twoWeeksAgo = "start-twoWeeksAgo"
    case lastWeek = "start-lastWeek"
    case thisWeek = "start-thisWeek"
    case today = "start-today"

    public var title: String {
        switch self {
        case .fourWeeksAgo:
            return String(localized: "4 Weeks Ago", bundle: .core)
        case .threeWeeksAgo:
            return String(localized: "3 Weeks Ago", bundle: .core)
        case .twoWeeksAgo:
            return String(localized: "2 Weeks Ago", bundle: .core)
        case .lastWeek:
            return String(localized: "Last Week", bundle: .core)
        case .thisWeek:
            return String(localized: "This Week", bundle: .core)
        case .today:
            return String(localized: "Today", bundle: .core)
        }
    }

    public func startDate(relativeTo referenceDate: Date = Clock.now) -> Date {
        let weekStart = referenceDate.startOfWeek()

        switch self {
        case .fourWeeksAgo:
            return weekStart.addWeeks(-4)
        case .threeWeeksAgo:
            return weekStart.addWeeks(-3)
        case .twoWeeksAgo:
            return weekStart.addWeeks(-2)
        case .lastWeek:
            return weekStart.addWeeks(-1)
        case .thisWeek:
            return weekStart
        case .today:
            return referenceDate.startOfDay()
        }
    }

    public func subtitle(relativeTo referenceDate: Date = Clock.now) -> String {
        let dateString = startDate(relativeTo: referenceDate).shortDayMonth
        return String(localized: "From \(dateString)", bundle: .core, comment: "Todo list date range filter subtitle showing the start date. The date is formatted as 'Day Month' (e.g., '15 Jan')")
    }
}

// MARK: - OptionItem Conversion

extension TodoDateRangeStart {
    public func toOptionItem(relativeTo referenceDate: Date = Clock.now) -> OptionItem {
        OptionItem(
            id: rawValue,
            title: title,
            subtitle: subtitle(relativeTo: referenceDate)
        )
    }

    public static func from(optionItem: OptionItem) -> TodoDateRangeStart? {
        TodoDateRangeStart(rawValue: optionItem.id)
    }

    public static func allOptionItems(relativeTo referenceDate: Date = Clock.now) -> [OptionItem] {
        allCases.map { $0.toOptionItem(relativeTo: referenceDate) }
    }
}
