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

struct CalendarDay: Equatable {
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

    func sameDayNextWeek() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .weekOfMonth, value: 1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    func sameDayNextMonth() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    func sameDayPrevWeek() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .weekOfMonth, value: -1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    func sameDayPrevMonth() -> CalendarDay {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: date) {
            return CalendarDay(calendar: calendar, date: newDate)
        }
        return self
    }

    var endDate: Date {
        return calendar.date(byAdding: .day, value: 1, to: date) ?? date
    }
}
