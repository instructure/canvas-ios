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

enum FrequencyPreset: Equatable {
    case noRepeat

    case daily
    case weeklyOnThatDay
    case monthlyOnThatWeekday
    case yearlyOnThatMonth
    case everyWeekday

    case selected(title: String, rule: RecurrenceRule)
    case custom(RecurrenceRule)

    static let calculativePresets: [FrequencyPreset] = [
        .daily,
        .weeklyOnThatDay,
        .monthlyOnThatWeekday,
        .yearlyOnThatMonth,
        .everyWeekday
    ]

    static let predefinedPresets: [FrequencyPreset] = [.noRepeat] + calculativePresets

    static func preset(given rule: RecurrenceRule?, date: Date) -> Self {
        guard let rule else { return .noRepeat }

        return calculativePreset(matching: rule, with: date) ?? .custom(rule)
    }

    static func calculativePreset(matching rule: RecurrenceRule, with date: Date) -> Self? {
        calculativePresets.first { $0.rule(given: date) == rule }
    }

    var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }

    func rule(given date: Date) -> RecurrenceRule? {
        switch self {
        case .noRepeat:
            return nil
        case .daily:
            return RecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: .occurrenceCount(365)
            )
        case .weeklyOnThatDay:
            let weekday = RecurrenceRule.DayOfWeek(date.inCalendar.weekday)
            return RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: [weekday],
                end: .occurrenceCount(52)
            )
        case .monthlyOnThatWeekday:
            return RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 1,
                daysOfTheWeek: [date.inCalendar.monthWeekday],
                end: .occurrenceCount(12)
            )
        case .yearlyOnThatMonth:
            return RecurrenceRule(
                recurrenceWith: .yearly,
                interval: 1,
                daysOfTheMonth: [date.inCalendar.daysOfMonth],
                monthsOfTheYear: [date.inCalendar.months],
                end: .occurrenceCount(5)
            )
        case .everyWeekday:
            return RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: Weekday.weekDays.map { RecurrenceRule.DayOfWeek($0) },
                end: .occurrenceCount(260)
            )
        case .custom(let rule), .selected(_, let rule):
            return rule
        }
    }
}

// MARK: - Calendar Event helpers

extension CalendarEvent {

    var frequencyPreset: FrequencyPreset {
        guard let recurrenceRule else { return .noRepeat }

        if let date = startAt,
           let calculativePreset = FrequencyPreset.calculativePreset(matching: recurrenceRule, with: date) {
            return calculativePreset
        } else {
            // A `CalendarEvent` with a `recurrenceRule` should always contain a related title. The default value should never be needed.
            let title = seriesInNaturalLanguage ?? recurrenceRule.text
            return .selected(title: title, rule: recurrenceRule)
        }
    }
}
