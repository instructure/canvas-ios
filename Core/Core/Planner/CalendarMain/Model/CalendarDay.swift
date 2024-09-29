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

import SwiftUI

protocol CalendarPeriod {
    var dateInterval: DateInterval { get }
}

struct CalendarDay: CalendarPeriod {
    static func today(in calendar: Calendar) -> CalendarDay {
        return CalendarDay(calendar: calendar, date: .now)
    }

    let calendar: Calendar
    let date: Date

    init(calendar: Calendar, date: Date) {
        self.calendar = calendar
        self.date = calendar.startOfDay(for: date)
    }

    var isToday: Bool {
        return calendar.isDateInToday(date)
    }

    var weekday: Int {
        return calendar.component(.weekday, from: date)
    }

    var week: CalendarWeek {
        return CalendarWeek(calendar: calendar, date: date)
    }

    var month: CalendarMonth {
        return CalendarMonth(calendar: calendar, date: date)
    }

    func nextWeek() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .weekOfMonth, value: 1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    func nextMonth() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    func prevWeek() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .weekOfMonth, value: -1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    func prevMonth() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    var dateInterval: DateInterval {
        let nextDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        return DateInterval(start: date, end: nextDate)
    }
}

struct CalendarWeek: Equatable, CalendarPeriod {
    let calendar: Calendar

    var weekOfMonth: Int
    var month: Int
    var year: Int

    init(calendar: Calendar, date: Date) {
        self.calendar = calendar
        self.weekOfMonth = calendar.component(.weekOfMonth, from: date)
        self.month = calendar.component(.month, from: date)
        self.year = calendar.component(.year, from: date)
    }

    init(calendar: Calendar, weekOfMonth: Int, month: Int, year: Int) {
        self.calendar = calendar
        self.weekOfMonth = weekOfMonth
        self.month = month
        self.year = year
    }

    func validate(weekday: Int) -> Bool {
        var comps = components
        comps.weekOfMonth = weekOfMonth
        comps.weekday = weekday
        comps.day = nil
        return comps.isValidDate
    }

    func date(ofWeekday weekday: Int) -> Date {
        var comps = components
        comps.weekOfMonth = weekOfMonth
        comps.weekday = weekday
        comps.day = nil
        return comps.date ?? .now
    }

    func day(ofWeekday weekday: Int) -> CalendarDay {
        return CalendarDay(calendar: calendar, date: date(ofWeekday: weekday))
    }

    func title(forWeekday weekday: Int) -> String {
        let date = date(ofWeekday: weekday)
        return date.formatted(Date.FormatStyle.dateTime(calendar: calendar).day())
    }

    private var components: DateComponents {
        return DateComponents(
            calendar: calendar,
            year: year,
            month: month,
            weekday: 1,
            weekOfMonth: weekOfMonth
        )
    }

    var dateInterval: DateInterval {
        let date = date(ofWeekday: 1)
        return calendar.dateInterval(of: .weekOfMonth, for: date)
            ?? DateInterval(start: date, end: date)
    }
}

struct CalendarMonth: Equatable, CalendarPeriod {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.components == rhs.components
    }

    let calendar: Calendar
    let date: Date

    init(calendar: Calendar, date: Date) {
        self.calendar = calendar
        self.date = calendar.startOfDay(for: date)
    }

    private var components: (month: Int, year: Int) {
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return (month, year)
    }

    var weeks: [CalendarWeek] {
        let (month, year) = components
        return (calendar.range(of: .weekOfMonth, in: .month, for: date) ?? .zero)
            .map {
                CalendarWeek(
                    calendar: calendar,
                    weekOfMonth: $0,
                    month: month,
                    year: year
                )
            }
    }

    var dateInterval: DateInterval {
        return calendar.dateInterval(of: .month, for: date)
            ?? DateInterval(start: date, end: date)
    }
}
