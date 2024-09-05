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
            String(localized: "Daily", bundle: .core)
        case .weekly:
            String(localized: "Weekly", bundle: .core)
        case .monthly:
            String(localized: "Monthly", bundle: .core)
        case .yearly:
            String(localized: "Annually", bundle: .core)
        }
    }

    var everyOtherText: String {
        switch self {
        case .daily:
            String(localized: "Every other day", bundle: .core)
        case .weekly:
            String(localized: "Every other week", bundle: .core)
        case .monthly:
            String(localized: "Every other month", bundle: .core)
        case .yearly:
            String(localized: "Every other year", bundle: .core)
        }
    }

    var everyMultipleFormat: String {
        switch self {
        case .daily:
            String(localized: "Every %@ day", bundle: .core, comment: "Every 4th day")
        case .weekly:
            String(localized: "Every %@ week", bundle: .core, comment: "Every 4th week")
        case .monthly:
            String(localized: "Every %@ month", bundle: .core, comment: "Every 4th month")
        case .yearly:
            String(localized: "Every %@ year", bundle: .core, comment: "Every 4th year")
        }
    }

    func unitText(given value: Int) -> String {
        let formatted: String

        switch self {
        case .daily:
            formatted = String(localized: "\(value) Days", bundle: .core)
        case .weekly:
            formatted = String(localized: "\(value) Weeks", bundle: .core)
        case .monthly:
            formatted = String(localized: "\(value) Months", bundle: .core)
        case .yearly:
            formatted = String(localized: "\(value) Years", bundle: .core)
        }

        let digitLocalized = String.localizedStringWithFormat("%lld", value)
        return formatted.replacingOccurrences(of: digitLocalized, with: "").trimmed()
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
            String(localized: "First %@", bundle: .core, comment: "First Sunday")
        case 2:
            String(localized: "Second %@", bundle: .core, comment: "Second Sunday")
        case 3:
            String(localized: "Third %@", bundle: .core, comment: "Third Sunday")
        case 4:
            String(localized: "Fourth %@", bundle: .core, comment: "Fourth Sunday")
        case 5:
            String(localized: "Fifth %@", bundle: .core, comment: "Fifth Sunday")
        case -1:
            String(localized: "Last %@", bundle: .core, comment: "Last Sunday")
        default:
            "\(formatted(.ordinal)) %@"
        }
    }

    var middleFormat: String {
        switch self {
        case 1:
            return String(localized: "The First %@", bundle: .core, comment: "The First Sunday")
        case 2:
            return String(localized: "The Second %@", bundle: .core, comment: "The Second Sunday")
        case 3:
            return String(localized: "The Third %@", bundle: .core, comment: "The Third Sunday")
        case 4:
            return String(localized: "The Fourth %@", bundle: .core, comment: "The Fourth Sunday")
        case 5:
            return String(localized: "The Fifth %@", bundle: .core, comment: "The Fifth Sunday")
        case -1:
            return String(localized: "The Last %@", bundle: .core, comment: "The Last Sunday")
        default:
            let ordinal = String(localized: "The %@", bundle: .core, comment: "The 7th")
                .asFormat(for: formatted(.ordinal))
            return "\(ordinal) %@"
        }
    }
}

extension DayOfWeek {

    var standaloneText: String {
        if weekNumber != 0 {
            return String(format: weekNumber.standaloneFormat, weekday.text)
        }
        return weekday.text
    }

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

    var hasAllWeek: Bool {
        Weekday
            .allCases
            .allSatisfy({ wd in
                contains(where: { d in
                    d.weekday == wd && d.weekNumber == 0
                })
            })
    }
}

private extension Int {

    func asInterval(for frequency: RecurrenceFrequency) -> String {
        if self == 0 { return "" }
        if self == 1 { return frequency.everyTimeText }
        if self == 2 { return frequency.everyOtherText }
        return String(format: frequency.everyMultipleFormat, formatted(.ordinal))
    }

    var asDay: String {
        String(format: String(localized: "Day %i", bundle: .core), self)
    }

    var asWeek: String {
        String(format: String(localized: "Week %i", bundle: .core), self)
    }

    var asWeekDay: String {
        let calendar = Cal.currentCalendar
        return Cal
            .currentCalendar
            .date(bySetting: .weekday, value: self, of: Clock.now)?
            .formatted(format: "EEEE", calendar: calendar)
        ?? calendar.standaloneWeekdaySymbols[self - 1]
    }

    var asWeekDayShort: String {
        let calendar = Cal.currentCalendar
        return calendar
            .date(bySetting: .weekday, value: self, of: Clock.now)?
            .formatted(format: "EEE", calendar: calendar)
        ?? calendar.shortStandaloneWeekdaySymbols[self - 1]
    }

    var asMonth: String {
        let calendar = Cal.currentCalendar
        return calendar
            .date(bySetting: .month, value: self, of: Clock.now)?
            .formatted(format: "MMMM", calendar: calendar)
        ?? calendar.standaloneMonthSymbols[self - 1]
    }
}

private extension Array where Element == Int {

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

private extension RecurrenceEnd {

    var text: String {
        switch self {
        case .endDate(let date):
            let format = String(localized: "until %@", bundle: .core)
            return String(format: format, date.formatted(date: .abbreviated, time: .omitted))
        case .occurrenceCount(let count):
            let format = String(localized: "%d times", bundle: .core)
            return String(format: format, count)
        }
    }
}

extension RecurrenceRule {

    var text: String {
        var words: [String] = []

        if frequency == .daily {
            words.append(interval.asInterval(for: frequency))
            if let end = recurrenceEnd?.text { words.append(contentsOf: [.commaSpaced, end]) }
            return words.joined()
        }

        var isDaysOfTheWeekAdded: Bool = false
        if case .weekly = frequency, let days = daysOfTheWeek, days.hasWeekdays {
            if interval > 1 {
                words.append(interval.asInterval(for: frequency))
                words.append(.onSpaced)
            }
            words.append(String(localized: "Every Weekday", bundle: .core))
            isDaysOfTheWeekAdded = true
        } else {
            words.append(interval.asInterval(for: frequency))
        }

        if weeksOfTheYear == nil,
           let months = monthsOfTheYear, months.count == 1,
           let days = daysOfTheMonth, days.count == 1,
            let month = months.first,
            let day = days.first {

            words.append(.onSpaced)
            words.append(month.asMonth)
            words.append(.space)
            words.append(day.formatted(.number))
        } else {

            func seperator() {
                words.append(words.count == 1 ? .onSpaced : .commaSpaced)
            }

            if let months = monthsOfTheYear {
                seperator()
                words.append(months.map({ $0.asMonth }).joined(separator: .commaSpaced))
            }

            if let weeks = weeksOfTheYear {
                seperator()
                words.append(weeks.map({ $0.asWeek }).joined(separator: .commaSpaced))
            }

            if let days = daysOfTheMonth {
                seperator()
                words.append(days.map({ $0.asDay }).joined(separator: .commaSpaced))
            }

            if let days = daysOfTheWeek, isDaysOfTheWeekAdded == false {
                seperator()
                words.append(days.map({ $0.middleText }).joined(separator: .commaSpaced))
            }
        }

        if let end = recurrenceEnd?.text {
            words.append(contentsOf: [.commaSpaced, end])
        }

        return words.joined()
    }
}

// MARK: - Helpers

private extension String {

    static var on: String { String(localized: "on", bundle: .core) }

    static var onSpaced: String {
        " " + on + " "
    }

    static var commaSpaced: String {
        ", "
    }

    static var space: String { " " }
}
