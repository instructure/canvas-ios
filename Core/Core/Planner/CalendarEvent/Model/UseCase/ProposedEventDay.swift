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

struct ProposedEventDay: Equatable {
    let date: Date
    let calendar: Calendar

    init(date: Date, calendar: Calendar) {
        self.date = date
        self.calendar = calendar
    }

    private var weekComps: DateComponents {
        calendar.dateComponents(
            [.calendar, .weekday, .weekdayOrdinal, .month, .year],
            from: date
        )
    }

    private var dayComps: DateComponents {
        calendar.dateComponents(
            [.calendar, .day, .month, .year],
            from: date
        )
    }

    var isLastWeekdayInMonth: Bool {
        var copy = weekComps
        copy.weekdayOrdinal = copy.weekdayOrdinal.flatMap({ $0 + 1 })
        return copy.isValidDate == false
    }

    var weekday: Int { weekComps.weekday ?? 0 }
    var weekdayOrdinal: Int { weekComps.weekdayOrdinal ?? 0 }
    var weekdayOrdinalValued: WeekNumber? {
        if isLastWeekdayInMonth { return .last }
        return WeekNumber(rawValue: weekdayOrdinal)
    }

    var day: Int { dayComps.day ?? 0 }

    func title(as representation: Representation) -> String {
        switch representation {
        case .weekDay:
            let dayText = date.formatted(format: "EEEE", calendar: calendar)
            if let format = weekdayOrdinalValued?.standaloneFormat {
                return String(format: format, dayText)
            }
            return dayText
        case .monthDay:
            return String(format: "Day %i", day)
        case .yearDay:
            return date.formatted(format: "MMMM d", calendar: calendar)
        }
    }

    enum Representation {
        static let monthOptions: [Representation] = [.monthDay, .weekDay]

        case weekDay
        case monthDay
        case yearDay
    }
}

extension ProposedEventDay.Representation {
    func title(for eventDay: ProposedEventDay) -> String {
        return eventDay.title(as: self)
    }
}

// MARK: - Utils

extension Date {
    static let defaultFormatter = DateFormatter()

    func formatted(format: String, calendar: Calendar) -> String {
        Self.defaultFormatter.calendar = calendar
        Self.defaultFormatter.dateFormat = format
        return Self.defaultFormatter.string(from: self)
    }

    #if DEBUG
    init?(_ stringValue: String, format: String) {
        Self.defaultFormatter.dateFormat = format
        guard let parsed = Self.defaultFormatter.date(from: stringValue) else { return nil }
        self = parsed
    }
    #endif
}
