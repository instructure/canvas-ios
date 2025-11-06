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

public enum TodoDateRangeEnd: String, CaseIterable, Codable {
    case today = "end-today"
    case thisWeek = "end-thisWeek"
    case nextWeek = "end-nextWeek"
    case inTwoWeeks = "end-inTwoWeeks"
    case inThreeWeeks = "end-inThreeWeeks"
    case inFourWeeks = "end-inFourWeeks"

    public var title: String {
        switch self {
        case .today:
            return String(localized: "Today", bundle: .core)
        case .thisWeek:
            return String(localized: "This Week", bundle: .core)
        case .nextWeek:
            return String(localized: "Next Week", bundle: .core)
        case .inTwoWeeks:
            return String(localized: "In 2 Weeks", bundle: .core)
        case .inThreeWeeks:
            return String(localized: "In 3 Weeks", bundle: .core)
        case .inFourWeeks:
            return String(localized: "In 4 Weeks", bundle: .core)
        }
    }

    public func endDate(relativeTo referenceDate: Date = Clock.now) -> Date {
        let weekStart = referenceDate.startOfWeek()

        switch self {
        case .today:
            return referenceDate.endOfDay()
        case .thisWeek:
            return weekStart.addWeeks(1).addSeconds(-1)
        case .nextWeek:
            return weekStart.addWeeks(2).addSeconds(-1)
        case .inTwoWeeks:
            return weekStart.addWeeks(3).addSeconds(-1)
        case .inThreeWeeks:
            return weekStart.addWeeks(4).addSeconds(-1)
        case .inFourWeeks:
            return weekStart.addWeeks(5).addSeconds(-1)
        }
    }

    public func subtitle(relativeTo referenceDate: Date = Clock.now) -> String {
        let dateString = endDate(relativeTo: referenceDate).shortDayMonth
        return String(localized: "Until \(dateString)", bundle: .core, comment: "Todo list date range filter subtitle showing the end date. The date is formatted as 'Day Month' (e.g., '15 Jan')")
    }
}

// MARK: - OptionItem Conversion

extension TodoDateRangeEnd {
    public func toOptionItem(relativeTo referenceDate: Date = Clock.now) -> OptionItem {
        OptionItem(
            id: rawValue,
            title: title,
            subtitle: subtitle(relativeTo: referenceDate)
        )
    }

    public static func from(optionItem: OptionItem) -> TodoDateRangeEnd? {
        TodoDateRangeEnd(rawValue: optionItem.id)
    }

    public static func allOptionItems(relativeTo referenceDate: Date = Clock.now) -> [OptionItem] {
        allCases.map { $0.toOptionItem(relativeTo: referenceDate) }
    }
}
