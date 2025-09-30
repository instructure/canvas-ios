//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct TodoGroupViewModel: Identifiable, Equatable, Comparable {
    public let id: String
    public let date: Date
    public let items: [TodoItemViewModel]
    public let weekdayAbbreviation: String
    public let dayNumber: String
    public let isToday: Bool
    public let displayDate: String
    public let accessibilityLabel: String

    public init(date: Date, items: [TodoItemViewModel]) {
        self.id = date.isoString()
        self.date = date
        self.items = items
        self.weekdayAbbreviation = date.weekdayNameAbbreviated
        self.dayNumber = date.dayString
        self.isToday = Cal.currentCalendar.isDateInToday(date)
        self.displayDate = date.dayInMonth
        self.accessibilityLabel = [
            date.weekdayName,
            date.dayString,
            String.format(numberOfItems: items.count)
        ].joined(separator: ", ")
    }

    // MARK: - Comparable

    public static func < (lhs: TodoGroupViewModel, rhs: TodoGroupViewModel) -> Bool {
        lhs.date < rhs.date
    }
}
