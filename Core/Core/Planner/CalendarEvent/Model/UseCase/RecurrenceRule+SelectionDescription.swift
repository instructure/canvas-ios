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

    var text: String {
        switch self {
        case .daily: String(localized: "Daily", bundle: .core)
        case .weekly: String(localized: "Weekly", bundle: .core)
        case .monthly: String(localized: "Monthly", bundle: .core)
        case .yearly: String(localized: "Yearly", bundle: .core)
        }
    }
}

extension Weekday {

    var text: String {
        return Calendar.autoupdatingCurrent.standaloneWeekdaySymbols[dateComponent - 1]
    }

    var shortText: String {
        return Calendar.autoupdatingCurrent.shortStandaloneWeekdaySymbols[dateComponent - 1]
    }

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

extension WeekNumber {
    var text: String {
        switch self {
        case .first:
            String(localized: "First", bundle: .core)
        case .second:
            String(localized: "Second", bundle: .core)
        case .third:
            String(localized: "Third", bundle: .core)
        case .fourth:
            String(localized: "Fourth", bundle: .core)
        case .fifth:
            String(localized: "Fifth", bundle: .core)
        case .last:
            String(localized: "Last", bundle: .core)
        }
    }
}

extension DayOfWeek {
    var shortText: String {
        var txt: [String] = []
        if let weekNumber { txt.append(weekNumber.text) }
        txt.append(dayOfTheWeek.shortText)
        return txt.joined(separator: " ")
    }

    var text: String {
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

    var hasWeekdays: Bool {
        Weekday
            .weekDays
            .allSatisfy({ wd in
                contains(where: { d in
                    d.dayOfTheWeek == wd && d.weekNumber == nil
                })
            })
    }

    var nonWeekdays: Self {
        filter({ Weekday.weekDays.contains($0.dayOfTheWeek) == false })
    }

    var texts: [String] {
        var tags = [String]()

        if hasWeekdays {
            tags.append(String(localized: "Weekdays", bundle: .core))
        }

        if let nonWeekDays = nonWeekdays.nonEmpty() {

            let long = tags.isEmpty ? nonWeekDays.count <= 2 : false
            for wday in nonWeekDays {
                tags.append(long ? wday.text : wday.shortText)
            }
        }

        return tags
    }

}

enum IntervalUnit {
    case day
    case week
    case month
    case year

    var one: String {
        switch self {
        case .day: String(localized: "Every day", bundle: .core)
        case .week: String(localized: "Every week", bundle: .core)
        case .month: String(localized: "Every month", bundle: .core)
        case .year: String(localized: "Every year", bundle: .core)
        }
    }

    var two: String {
        switch self {
        case .day: String(localized: "Every other day", bundle: .core)
        case .week: String(localized: "Every other week", bundle: .core)
        case .month: String(localized: "Every other month", bundle: .core)
        case .year: String(localized: "Every other year", bundle: .core)
        }
    }

    var moreFormat: String {
        switch self {
        case .day: String(localized: "Every %@ day", bundle: .core)
        case .week: String(localized: "Every %@ week", bundle: .core)
        case .month: String(localized: "Every %@ month", bundle: .core)
        case .year: String(localized: "Every %@ year", bundle: .core)
        }
    }

    init(given frequency: RecurrenceFrequency) {
        switch frequency {
        case .daily:
            self = .day
        case .weekly:
            self = .week
        case .monthly:
            self = .month
        case .yearly:
            self = .year
        }
    }
}

extension Int {

    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    func asInterval(_ unit: IntervalUnit) -> String {
        if self == 0 { return "" }
        if self == 1 { return unit.one }
        if self == 2 { return unit.two }
        return String(format: unit.moreFormat, ordinal)
    }

    var asDay: String {
        String(format: String(localized: "Day %i"), self)
    }

    var asWeek: String {
        String(format: String(localized: "Week %i"), self)
    }

    var asMonth: String {
        Calendar.autoupdatingCurrent.standaloneMonthSymbols[self - 1]
    }
}

extension Array where Element == Int {

    var asDays: [String] {
        map { $0.asDay }
    }

    var asWeeks: [String] {
        map { $0.asDay }
    }

    var asMonths: [String] {
        map { $0.asMonth }
    }
}

extension RecurrenceRule {

    var text: String {
        var words: [String] = []



        if interval > 1 {
            words.append(interval.asInterval(.init(given: frequency)))
        } else {
            words.append(frequency.text)
        }


    }
}
