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

struct CalendarWeek: Equatable, Identifiable {
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

    fileprivate var components: DateComponents {
        return DateComponents(
            calendar: calendar,
            year: year,
            month: month,
            weekday: 1,
            weekOfMonth: weekOfMonth
        )
    }

    var dateInterval: DateInterval {
        let date = weekday(of: 1).date
        return calendar.dateInterval(of: .weekOfMonth, for: date)
            ?? DateInterval(start: date, end: date)
    }

    var endDate: Date {
        return dateInterval.end
    }

    var id: String {
        return "week-\(year)-\(month)-\(weekOfMonth)"
    }

    func weekday(of component: Int) -> CalendarWeekday {
        return CalendarWeekday(weekday: component, week: self)
    }

    var weekdays: [CalendarWeekday] {
        return calendar.orderedWeekdays.map({ wday in
            return CalendarWeekday(weekday: wday, week: self)
        })
    }

    func containsDate(_ edate: Date) -> Bool {
        return dateInterval.contains(edate)
    }
}

struct CalendarWeekday: Equatable, Identifiable {
    let weekday: Int
    let week: CalendarWeek

    var id: String {
        let path = [week.year, week.month, week.weekOfMonth, weekday]
            .map({ "\($0)" })
            .joined(separator: "-")
        return "day-\(path)"
    }

    var date: Date {
        var comps = week.components
        comps.weekday = weekday
        return comps.date ?? .now
    }

    var isValid: Bool {
        var comps = week.components
        comps.weekday = weekday
        return comps.isValidDate
    }

    var title: String {
        return date.formatted(Date.FormatStyle.dateTime(calendar: calendar).day())
    }

    var calendarDay: CalendarDay {
        return CalendarDay(calendar: calendar, date: date)
    }

    var calendar: Calendar {
        week.calendar
    }

    func containsDate(_ edate: Date) -> Bool {
        return calendar.isDate(edate, inSameDayAs: date)
    }
}
