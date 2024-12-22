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

    var inCalendar: CalendarCalculation {
        return CalendarCalculation(calendar: Cal.currentCalendar, date: self)
    }

    func inCalendar(_ calendar: Calendar) -> CalendarCalculation {
        return CalendarCalculation(calendar: calendar, date: self)
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

public struct CalendarCalculation {
    public let calendar: Calendar
    public let date: Date
}

public extension CalendarCalculation {
    private static func now(in calendar: Calendar) -> CalendarCalculation {
        return CalendarCalculation(calendar: calendar, date: .now)
    }

    // MARK: - Components

    var months: Int {
        calendar.component(.month, from: date)
    }

    var daysOfMonth: Int {
        calendar.component(.day, from: date)
    }

    var hours: Int {
        calendar.component(.hour, from: date)
    }

    var minutes: Int {
        calendar.component(.minute, from: date)
    }

    // MARK: - add methods

    func addYears(_ years: Int) -> Date {
        calendar.date(byAdding: .year, value: years, to: date)
             ?? date
    }

    func addMonths(_ numberOfMonths: Int) -> Date {
        calendar.date(byAdding: .month, value: numberOfMonths, to: date)
            ?? Date()
    }

    func addDays(_ days: Int) -> Date {
        calendar.date(byAdding: .day, value: days, to: date)
            ?? Date()
    }

    func addHours(_ hours: Int) -> Date {
        calendar.date(byAdding: .hour, value: hours, to: date)
            ?? Date()
    }

    func addMinutes(_ minutes: Int) -> Date {
        calendar.date(byAdding: .minute, value: minutes, to: date)
            ?? Date()
    }

    func addSeconds(_ seconds: Int) -> Date {
        calendar.date(byAdding: .second, value: seconds, to: date)
            ?? Date()
    }

    func addingYears(_ years: Int) -> CalendarCalculation {
        addYears(years).inCalendar(calendar)
    }

    func addingMonths(_ numberOfMonths: Int) -> CalendarCalculation {
        addMonths(numberOfMonths).inCalendar(calendar)
    }

    func addingDays(_ days: Int) -> CalendarCalculation {
        addDays(days).inCalendar(calendar)
    }

    func addingHours(_ hours: Int) -> CalendarCalculation {
        addHours(hours).inCalendar(calendar)
    }

    func addingMinutes(_ minutes: Int) -> CalendarCalculation {
        addMinutes(minutes).inCalendar(calendar)
    }

    func addingSeconds(_ seconds: Int) -> CalendarCalculation {
        addSeconds(seconds).inCalendar(calendar)
    }

    // MARK: - start/end methods

    func startOfMonth() -> CalendarCalculation {
        calendar
            .date(from: calendar.dateComponents([.year, .month], from: startOfDay().date))?
            .inCalendar(calendar) ?? .now(in: calendar)
    }

    func endOfMonth() -> CalendarCalculation {
        calendar
            .date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth().date)?
            .inCalendar(calendar) ?? .now(in: calendar)
    }

    func startOfWeek() -> CalendarCalculation {
        calendar
            .date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))?
            .inCalendar(calendar) ?? .now(in: calendar)
    }

    func endOfWeek() -> CalendarCalculation {
        calendar
            .date(byAdding: .weekOfYear, value: 1, to: startOfWeek().date)?
            .inCalendar(calendar) ?? .now(in: calendar)
    }

    func startOfDay() -> CalendarCalculation {
        calendar.startOfDay(for: date).inCalendar(calendar)
    }

    func endOfDay() -> CalendarCalculation {
        calendar
            .date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay().date)?
            .inCalendar(calendar) ?? .now(in: calendar)
    }

    func startOfHour() -> CalendarCalculation {
        startOfDay().addingHours(hours)
    }

    func startOfMonth() -> Date { startOfMonth().date }
    func endOfMonth() -> Date { endOfMonth().date }

    func startOfWeek() -> Date { startOfWeek().date }
    func endOfWeek() -> Date { endOfWeek().date }

    func startOfDay() -> Date { startOfDay().date }
    func endOfDay() -> Date { endOfDay().date }

    func startOfHour() -> Date { startOfHour().date }
}

#if DEBUG
public extension Date {
    static func make(calendar: Calendar = .current, year: Int, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute, second: second).date!
    }
}
#endif
