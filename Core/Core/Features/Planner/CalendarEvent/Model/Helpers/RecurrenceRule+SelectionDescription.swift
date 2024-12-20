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

extension RecurrenceFrequency {

    var selectionText: String {
        switch self {
        case .daily:
            String(localized: "Daily", bundle: .core)
        case .weekly:
            String(localized: "Weekly", bundle: .core)
        case .monthly:
            String(localized: "Monthly", bundle: .core)
        case .yearly:
            String(localized: "Yearly", bundle: .core)
        }
    }
}

extension Weekday {

    var pluralText: String {
        switch self {
        case .sunday:
            String(localized: "Sundays", bundle: .core)
        case .monday:
            String(localized: "Mondays", bundle: .core)
        case .tuesday:
            String(localized: "Tuesdays", bundle: .core)
        case .wednesday:
            String(localized: "Wednesdays", bundle: .core)
        case .thursday:
            String(localized: "Thursdays", bundle: .core)
        case .friday:
            String(localized: "Fridays", bundle: .core)
        case .saturday:
            String(localized: "Saturdays", bundle: .core)
        }
    }
}
