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

public struct DayPeriodProvider {
    private let calendar: Calendar
    private let date: Date

    var current: DayPeriod {
        switch calendar.component(.hour, from: date) {
        case 4..<12: .morning
        case 12..<17: .afternoon
        case 17..<21: .evening
        default: .night
        }
    }

    init(calendar: Calendar = .current, date: Date = .now) {
        self.calendar = calendar
        self.date = date
    }
}

extension DayPeriodProvider {
    enum DayPeriod {
        case morning
        case afternoon
        case evening
        case night
    }
}
