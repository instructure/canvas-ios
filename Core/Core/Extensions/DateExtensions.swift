//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public extension Date {
    func isoString() -> String {
        return ISO8601DateFormatter.string(from: self, timeZone: TimeZone(abbreviation: "UTC")!, formatOptions: .withInternetDateTime)
    }

    init?(fromISOString: String, formatOptions: ISO8601DateFormatter.Options? = nil) {
        let formatter = ISO8601DateFormatter()
        if let options = formatOptions {
            formatter.formatOptions = options
        }
        guard let date = formatter.date(from: fromISOString) else { return nil }
        self = date
    }

    func addYears(_ years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }

    func addMinutes(_ minutes: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .minute, value: minutes, to: self)
        return endDate ?? Date()
    }

    func addDays(_ days: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: self)
        return endDate ?? Date()
    }

    func addMonths(_ numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
        return endDate ?? Date()
    }

    func startOfWeek() -> Date {
        return Cal.currentCalendar.date(from: Cal.currentCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? Date()
    }

    func endOfWeek() -> Date {
        let start = startOfWeek()
        return Cal.currentCalendar.date(byAdding: .weekOfYear, value: 1, to: start) ?? Date()
    }

    static var dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        return formatter
    }()

    var dateMediumString: String {
        if Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: Clock.now) {
            return Date.dateOnlyFormatter.string(from: self)
        }
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
}
