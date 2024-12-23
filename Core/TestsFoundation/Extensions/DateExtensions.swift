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

extension Date {

    // MARK: Variables
    public var day: Int { inCalendar.daysOfMonth }
    public var month: Int { inCalendar.months }
    public var year: Int { inCalendar.years }
    public var isFutureDate: Bool { inCalendar.startOfDay() > Date.now.inCalendar.startOfDay() }

    // MARK: Functions
    public func add(_ calendarComponent: Calendar.Component, number: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: calendarComponent, value: number, to: self)
        return endDate ?? Date()
    }

    // MARK: Static functions
    public static func dateFromString(_ dateString: String, format: String = "yyyy-MM-dd HH:mm") -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }

    public static func isoDateFromString(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
