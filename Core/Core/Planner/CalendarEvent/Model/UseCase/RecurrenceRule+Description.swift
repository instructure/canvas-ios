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
        return dateComponent.asWeekDay
    }

    var shortText: String {
        return dateComponent.asWeekDayShort
    }
}

typealias WeekNumber = Int

extension WeekNumber {

    var standaloneFormat: String {
        switch self {
        case 1:
            "First %@".localized()
        case 2:
            "Second %@".localized()
        case 3:
            "Third %@".localized()
        case 4:
            "Fourth %@".localized()
        case 5:
            "Fifth %@".localized()
        case -1:
            "Last %@".localized()
        default:
            "\(formatted(.ordinal)) %@"
        }
    }

    var middleFormat: String {
        switch self {
        case 1:
            "The First %@".localized()
        case 2:
            "The Second %@".localized()
        case 3:
            "The Third %@".localized()
        case 4:
            "The Fourth %@".localized()
        case 5:
            "The Fifth %@".localized()
        case -1:
            "The Last %@".localized()
        default:
            "\(formatted(.ordinal)) %@"
        }
    }
}

extension DayOfWeek {

    var shortText: String {
        if weekNumber != 0 {
            return String(format: weekNumber.standaloneFormat, weekday.shortText)
        }
        return weekday.shortText
    }

    var middleText: String {
        if weekNumber != 0 {
            return String(format: weekNumber.middleFormat, weekday.text)
        }
        return weekday.text
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
                    d.weekday == wd && d.weekNumber == 0
                })
            })
    }
}

extension Int {

    func asInterval(for frequency: RecurrenceFrequency) -> String {
        if self == 0 { return "" }
        if self == 1 { return frequency.everyTimeText }
        if self == 2 { return frequency.everyOtherText }
        return String(format: frequency.everyMultipleFormat, formatted(.ordinal))
    }

    var asDay: String {
        String(format: "Day %i".localized(), self)
    }

    var asWeek: String {
        String(format: "Week %i".localized(), self)
    }

    var asWeekDay: String {
        let calendar = Calendar.current
        return calendar
            .date(bySetting: .weekday, value: self, of: .now)?
            .formatted(format: "EEEE", calendar: calendar)
        ?? calendar.standaloneWeekdaySymbols[self - 1]
    }

    var asWeekDayShort: String {
        let calendar = Calendar.current
        return calendar
            .date(bySetting: .weekday, value: self, of: .now)?
            .formatted(format: "EEE", calendar: calendar)
        ?? calendar.shortStandaloneWeekdaySymbols[self - 1]
    }

    var asMonth: String {
        let calendar = Calendar.current
        return calendar
            .date(bySetting: .month, value: self, of: .now)?
            .formatted(format: "MMMM", calendar: calendar)
        ?? calendar.standaloneMonthSymbols[self - 1]
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

extension NumberFormatter {
    static let ordinal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
}


struct OrdinalFormatStyle<Value>: FormatStyle where Value : BinaryInteger {
    typealias FormatInput = Value
    typealias FormatOutput = String

    func format(_ value: Value) -> String {
        return NumberFormatter.ordinal.string(from: NSNumber(value: Int(value))) ?? "\(value)"
    }
}

extension FormatStyle where Self == OrdinalFormatStyle<Int> {
    static var ordinal: OrdinalFormatStyle<Int> {
        OrdinalFormatStyle<Int>()
    }
}
