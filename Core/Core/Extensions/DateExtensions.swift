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

    func addSeconds(_ seconds: Int) -> Date {
        Cal.currentCalendar.date(byAdding: .second, value: seconds, to: self) ?? Date()
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

    func startOfDay() -> Date {
        Cal.currentCalendar.startOfDay(for: self)
    }

    func endOfDay() -> Date {
        Cal.currentCalendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay()) ?? Date()
    }

    func startOfMonth() -> Date {
        return Cal.currentCalendar.date(from: Cal.currentCalendar.dateComponents([.year, .month], from: startOfDay())) ?? Date()
    }

    func endOfMonth() -> Date {
        return Cal.currentCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth()) ?? Date()
    }

    func removeTime() -> Date {
        Cal.currentCalendar.date(from: Cal.currentCalendar.dateComponents([.year, .month, .day], from: self)) ?? Date()
    }

    static var relativeDateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    static var relativeDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    static var relativeDateTimeFormatterWithDayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()
    static var intervalDateTimeFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    /**
     Date formatter to create a from-to string between two times within a day because no date component is displayed only hours and minutes.
     */
    static var timeIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    /**
     This date formatter displays only the name of the weekday. E.g.: Monday, Saturday.
     */
    static var weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter
    }()
    /**
     This date formatter displays the full month name and the day of the month. E.g.: September 6.
     */
    static var dayInMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMd", options: 0, locale: NSLocale.current)
        return dateFormatter
    }()
    static var timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    var dateOnlyString: String {
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }
    var dateTimeString: String {
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .short)
    }
    var relativeDateOnlyString: String {
        Date.relativeDateOnlyFormatter.string(from: self)
    }
    var relativeDateTimeString: String {
        Date.relativeDateTimeFormatter.string(from: self)
    }
    var relativeDateTimeStringWithDayOfWeek: String {
        Date.relativeDateTimeFormatterWithDayOfWeek.string(from: self)
    }
    func intervalStringTo(_ to: Date) -> String {
        return Date.intervalDateTimeFormatter.string(from: self, to: to)
    }
    /**
     E.g.: 8:30-10:30 PM
     */
    func timeIntervalString(to date: Date) -> String {
        Date.timeIntervalFormatter.string(from: self, to: date)
    }
    /**
     E.g.: Monday
     */
    var weekdayName: String {
        Date.weekdayFormatter.string(from: self)
    }
    /**
     E.g.: September 6.
     */
    var dayInMonth: String {
        Date.dayInMonthFormatter.string(from: self)
    }
    var timeString: String {
        Date.timeOnlyFormatter.string(from: self)
    }
}
