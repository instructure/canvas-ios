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
        ISO8601DateFormatter.string(from: self, timeZone: TimeZone(abbreviation: "UTC")!, formatOptions: .withInternetDateTime)
    }

    init?(fromISOString: String, formatOptions: ISO8601DateFormatter.Options? = nil) {
        let formatter = ISO8601DateFormatter()
        if let options = formatOptions {
            formatter.formatOptions = options
        }
        guard let date = formatter.date(from: fromISOString) else { return nil }
        self = date
    }

    // MARK: - Components

    var months: Int {
        Cal.currentCalendar.component(.month, from: self)
    }

    var daysOfMonth: Int {
        Cal.currentCalendar.component(.day, from: self)
    }

    var hours: Int {
        Cal.currentCalendar.component(.hour, from: self)
    }

    var minutes: Int {
        Cal.currentCalendar.component(.minute, from: self)
    }

    // MARK: - add methods

    func addYears(_ years: Int) -> Date {
        Cal.currentCalendar.date(byAdding: .year, value: years, to: self)
            ?? self
    }

    func addMonths(_ numberOfMonths: Int) -> Date {
        Cal.currentCalendar.date(byAdding: .month, value: numberOfMonths, to: self)
            ?? Date()
    }

    func addDays(_ days: Int) -> Date {
        Cal.currentCalendar.date(byAdding: .day, value: days, to: self)
            ?? Date()
    }

    func addHours(_ hours: Int) -> Date {
        Cal.currentCalendar.date(byAdding: .hour, value: hours, to: self)
            ?? Date()
    }

    func addMinutes(_ minutes: Int) -> Date {
        Cal.currentCalendar.date(byAdding: .minute, value: minutes, to: self)
            ?? Date()
    }

    func addSeconds(_ seconds: Int) -> Date {
        Cal.currentCalendar.date(byAdding: .second, value: seconds, to: self)
            ?? Date()
    }

    // MARK: - start/end methods

    func startOfMonth() -> Date {
        Cal.currentCalendar.date(from: Cal.currentCalendar.dateComponents([.year, .month], from: startOfDay()))
            ?? Date()
    }

    func endOfMonth() -> Date {
        Cal.currentCalendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth())
            ?? Date()
    }

    func startOfWeek() -> Date {
        Cal.currentCalendar.date(from: Cal.currentCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
            ?? Date()
    }

    func endOfWeek() -> Date {
        Cal.currentCalendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek())
            ?? Date()
    }

    func startOfDay() -> Date {
        Cal.currentCalendar.startOfDay(for: self)
    }

    func endOfDay() -> Date {
        Cal.currentCalendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay())
            ?? Date()
    }

    func startOfHour() -> Date {
        startOfDay().addHours(hours)
    }

    // MARK: - Formatters

    private static var relativeDateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static var relativeShortDateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        return formatter
    }()

    private static var relativeDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private static var relativeDateTimeFormatterWithDayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }()

    private static var intervalDateTimeFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    /**
     Date formatter to create a from-to string between two times within a day because no date component is displayed only hours and minutes.
     */
    private static var timeIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    /**
     This date formatter displays only the name of the weekday. E.g.: Monday, Saturday.
     */
    private static var weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE")
        return formatter
    }()

    /**
     This date formatter displays the full month name and the day of the month. E.g.: September 6.
     */
    private static var dayInMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMMd", options: 0, locale: NSLocale.current)
        return dateFormatter
    }()

    private static var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()

    private static var timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let _defaultFormatter = DateFormatter()
    private static func formatter(
        withFormat format: String,
        locale: Locale,
        calendar: Calendar
    ) -> DateFormatter {
        _defaultFormatter.locale = locale
        _defaultFormatter.calendar = calendar
        _defaultFormatter.dateFormat = format
        return _defaultFormatter
    }

    // MARK: - Formatted strings

    var dateOnlyString: String {
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .none)
    }

    var timeOnlyString: String {
        formatted(.dateTime.hour().minute())
    }

    var dateTimeString: String {
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .short)
    }

    func formatted(format: String, locale: Locale = .current, calendar: Calendar = Cal.currentCalendar) -> String {
        Date
            .formatter(withFormat: format, locale: locale, calendar: calendar)
            .string(from: self)
    }

    /**
     E.g.: Jul 14, 2021
     */
    var relativeDateOnlyString: String {
        Date.relativeDateOnlyFormatter.string(from: self)
    }

    /**
     E.g.: 8/16/21
     */
    var relativeShortDateOnlyString: String {
        Date.relativeShortDateOnlyFormatter.string(from: self)
    }

    var relativeDateTimeString: String {
        Date.relativeDateTimeFormatter.string(from: self)
    }

    var relativeDateTimeStringWithDayOfWeek: String {
        Date.relativeDateTimeFormatterWithDayOfWeek.string(from: self)
    }

    func intervalStringTo(_ to: Date) -> String {
        Date.intervalDateTimeFormatter.string(from: self, to: to)
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

    var dayString: String {
        Date.dayFormatter.string(from: self)
    }

    var timeString: String {
        Date.timeOnlyFormatter.string(from: self)
    }
}

extension DateFormatter {
    public convenience init(_ dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

#if DEBUG
public extension Date {
    static func make(calendar: Calendar = .current, year: Int, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute, second: second).date!
    }
}
#endif
