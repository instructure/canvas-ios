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
import Core

struct DayPeriodProvider {

    var currentPeriod: DayPeriod {
        Self.period(for: Clock.now)
    }

    static func period(for date: Date) -> DayPeriod {
        switch Cal.currentCalendar.component(.hour, from: date) {
        case 4..<12: .morning
        case 12..<17: .afternoon
        case 17..<21: .evening
        default: .night
        }
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
