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

public struct TodoGroup: Identifiable, Equatable {
    public let id: String
    public let date: Date
    public let items: [TodoItem]
    public let weekdayAbbreviation: String
    public let dayNumber: String
    public let isToday: Bool
    public let displayDate: String

    public init(date: Date, items: [TodoItem]) {
        self.id = date.isoString()
        self.date = date
        self.items = items
        self.weekdayAbbreviation = date.weekdayNameAbbreviated
        self.dayNumber = date.dayString
        self.isToday = Cal.currentCalendar.isDateInToday(date)
        self.displayDate = date.dayInMonth
    }
}
