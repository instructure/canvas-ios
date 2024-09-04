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

extension Array where Element == Weekday {

    private var nonWeekdays: Self {
        filter({ Weekday.weekDays.contains($0) == false })
    }

    private var allDaysIncluded: Bool {
        Weekday.allCases.allSatisfy({ contains($0) })
    }

    var selectionTexts: [String] {
        var tags = [String]()

        if allDaysIncluded {
            return [String(localized: "Every Day of the Week", bundle: .core)]
        }

        if hasWeekdays {
            tags.append(String(localized: "Weekdays", bundle: .core))

            if let nonWeekDays = nonWeekdays.nilIfEmpty {
                tags.append(contentsOf: nonWeekDays.map({ $0.shortText }))
            }

        } else {
            let long = count < 3
            tags.append(contentsOf: map { wday in
                return long ? wday.pluralText : wday.shortText
            })
        }

        return tags.nilIfEmpty ?? [String(localized: "Not selected", bundle: .core)]
    }
}
