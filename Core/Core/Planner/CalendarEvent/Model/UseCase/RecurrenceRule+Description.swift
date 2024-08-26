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

    var everyTimeText: String {
        switch self {
        case .daily:
            "Daily".localized()
        case .weekly:
            "Weekly".localized()
        case .monthly:
            "Monthly".localized()
        case .yearly:
            "Annually".localized()
        }
    }

    var everyOtherText: String {
        switch self {
        case .daily:
            "Every other day".localized()
        case .weekly:
            "Every other week".localized()
        case .monthly:
            "Every other month".localized()
        case .yearly:
            "Every other year".localized()
        }
    }

    var everyMultipleFormat: String {
        switch self {
        case .daily:
            "Every %@ day".localized()
        case .weekly:
            "Every %@ week".localized()
        case .monthly:
            "Every %@ month".localized()
        case .yearly:
            "Every %@ year".localized()
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
}

extension WeekNumber {

    var text: String {
        switch self {
        case .first:
            "First".localized()
        case .second:
            "Second".localized()
        case .third:
            "Third".localized()
        case .fourth:
            "Fourth".localized()
        case .fifth:
            "Fifth".localized()
        case .last:
            "Last".localized()
        }
    }

    var middleText: String {
        switch self {
        case .first:
            "The First".localized()
        case .second:
            "The Second".localized()
        case .third:
            "The Third".localized()
        case .fourth:
            "The Fourth".localized()
        case .fifth:
            "The Fifth".localized()
        case .last:
            "The Last".localized()
        }
    }
}

extension DayOfWeek {

    var shortText: String {
        var txt: [String] = []
        if let weekNumber { txt.append(weekNumber.text) }
        txt.append(dayOfTheWeek.shortText)
        return txt.joined(separator: .space)
    }

    var middleText: String {
        var txt: [String] = []
        if let weekNumber { txt.append(weekNumber.middleText) }
        txt.append(dayOfTheWeek.text)
        return txt.joined(separator: .space)
    }
}

extension Array where Element == Weekday {

    var hasWeekdays: Bool {
        Weekday
            .weekDays
            .allSatisfy({ wd in
                contains(wd)
            })
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
}

extension Int {

    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    func asInterval(for frequency: RecurrenceFrequency) -> String {
        if self == 0 { return "" }
        if self == 1 { return frequency.everyTimeText }
        if self == 2 { return frequency.everyOtherText }
        return String(format: frequency.everyMultipleFormat, ordinal)
    }

    var asDay: String {
        String(format: "Day %i".localized(), self)
    }

    var asWeek: String {
        String(format: "Week %i".localized(), self)
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

        if frequency != .daily {

            if let days = daysOfTheWeek {

                if days.hasWeekdays, case .weekly = frequency, interval == 1 {
                    words.append("Every Weekday".localized())
                } else {
                    words.append(interval.asInterval(for: frequency))
                    words.append(.onSpaced)
                    words.append(days.map({ $0.middleText }).joined(separator: .commaSpaced))
                }

            } else {
                words.append(interval.asInterval(for: frequency))
            }
        } else {
            words.append(interval.asInterval(for: frequency))
            return words.joined()
        }

        func seperator() {
            words.append(words.count == 1 ? .onSpaced : .commaSpaced)
        }

        if let weeks = weeksOfTheYear {
            seperator()

            words.append(weeks.map({ $0.asWeek }).joined(separator: .commaSpaced))
        }

        if let months = monthsOfTheYear, months.count == 1,
           let days = daysOfTheMonth, days.count == 1,
            let month = months.first,
            let day = days.first {

            seperator()
            words.append(month.asMonth)
            words.append(.space)
            words.append(day.formatted(.number))
        } else {

            if let months = monthsOfTheYear {
                seperator()
                words.append(months.map({ $0.asMonth }).joined(separator: .commaSpaced))
            }

            if let days = daysOfTheMonth {
                seperator()
                words.append(days.map({ $0.asDay }).joined(separator: .commaSpaced))
            }
        }

        return words.joined()
    }
}

// MARK: - Helpers

private extension String {

    static var on: String { "on".localized() }

    static var onSpaced: String {
        " " + on + " "
    }

    static var commaSpaced: String {
        ", "
    }

    static var space: String { " " }
}

extension String {
    func localized(in bundle: Bundle = .core) -> Self {
        return String(localized: LocalizationValue(self), bundle: .core)
    }
}
