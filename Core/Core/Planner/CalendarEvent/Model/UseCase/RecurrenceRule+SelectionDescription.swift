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

extension Weekday {

    var pluralText: String {
        switch self {
        case .sunday:
            "Sundays".localized()
        case .monday:
            "Mondays".localized()
        case .tuesday:
            "Tuesdays".localized()
        case .wednesday:
            "Wednesdays".localized()
        case .thursday:
            "Thursdays".localized()
        case .friday:
            "Fridays".localized()
        case .saturday:
            "Saturdays".localized()
        }
    }
}

extension DayOfWeek {

    var selectionText: String {
        var txt: [String] = []
        if let weekNumber {
            txt.append(weekNumber.text)
            txt.append(dayOfTheWeek.text)
        } else {
            txt.append(dayOfTheWeek.pluralText)
        }
        return txt.joined(separator: " ")
    }
}

extension Array where Element == DayOfWeek {

    var nonWeekdays: Self {
        filter({ Weekday.weekDays.contains($0.dayOfTheWeek) == false })
    }

    var selectionTexts: [String] {
        var tags = [String]()

        if hasWeekdays {
            tags.append("Weekdays".localized())
        }

        if let nonWeekDays = nonWeekdays.nonEmpty() {

            let long = tags.isEmpty ? nonWeekDays.count <= 2 : false
            for wday in nonWeekDays {
                tags.append(long ? wday.selectionText : wday.shortText)
            }
        }

        return tags
    }
}
