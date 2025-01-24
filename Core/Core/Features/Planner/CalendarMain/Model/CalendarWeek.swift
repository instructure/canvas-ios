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
    let month: Int
    let year: Int
    let dateInterval: DateInterval

    init(calendar: Calendar, year: Int? = nil, month: Int? = nil, weekOfMonth: Int? = nil, date: Date) {
        self.calendar = calendar

        let interval = calendar.dateInterval(of: .weekOfMonth, for: date)

        self.dateInterval = interval ?? DateInterval(start: date, duration: .day * Double(calendar.weekdaysCount))
        self.weekOfMonth = weekOfMonth ?? calendar.component(.weekOfMonth, from: date)
        self.month = month ?? calendar.component(.month, from: date)
        self.year = year ?? calendar.component(.year, from: date)
    }

    var id: String {
        return "week-\(year)-\(month)-\(weekOfMonth)"
    }

    var weekdays: [CalendarWeekday] {
        return (0 ..< calendar.weekdaysCount).map { offset in
            CalendarWeekday(offset: offset, week: self)
        }
    }

    func containsDate(_ edate: Date) -> Bool {
        return dateInterval.contains(edate)
    }
}

struct CalendarWeekday: Equatable, Identifiable {
    let offset: Int
    let week: CalendarWeek

    var id: String {
        let path = [week.year, week.month, week.weekOfMonth, offset]
            .map({ "\($0)" })
            .joined(separator: "-")
        return "weekday-\(path)"
    }

    var date: Date {
        let weekStart = week.dateInterval.start
        return calendar.date(byAdding: .day, value: offset, to: weekStart)
            ?? weekStart.addingTimeInterval(.day * Double(offset))
    }

    var isValid: Bool {
        return week.month == calendar.component(.month, from: date)
    }

    var title: String {
        return date.formatted(.dateTime.day().calendar(calendar))
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
