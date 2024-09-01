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

    case selected(title: String?, rule: RecurrenceRule)
    case custom(RecurrenceRule)

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
                end: RecurrenceEnd(occurrenceCount: 365)
            )
        case .weeklyOnThatDay:
            let weekday = DayOfWeek(date.weekday, weekNumber: 0)
            return RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: [weekday],
                end: RecurrenceEnd(occurrenceCount: 52)
            )
        case .monthlyOnThatWeekday:
            return RecurrenceRule(
                recurrenceWith: .monthly,
                interval: 1,
                daysOfTheWeek: [date.monthWeekday],
                end: RecurrenceEnd(occurrenceCount: 12)
            )
        case .yearlyOnThatMonth:
            return RecurrenceRule(
                recurrenceWith: .yearly,
                interval: 1,
                daysOfTheMonth: [date.monthDay],
                monthsOfTheYear: [date.month],
                end: RecurrenceEnd(occurrenceCount: 5)
            )
        case .everyWeekday:
            return RecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                daysOfTheWeek: Weekday.weekDays.map({ DayOfWeek($0) }),
                end: RecurrenceEnd(occurrenceCount: 260)
            )
        case .custom(let rule), .selected(_, let rule):
            return rule
        }
    }

    static func preset(given rule: RecurrenceRule?, date: Date) -> Self {
        guard let rule else { return .noRepeat }

        guard let preset = calculativePresets
            .first(where: { $0.rule(given: date) == rule })
        else {
            return .custom(rule)
        }

        return preset
    }

    // MARK: Choices Presets

    static var calculativePresets: [FrequencyPreset] {
        return [
            .daily, .weeklyOnThatDay, .monthlyOnThatWeekday, .yearlyOnThatMonth, .everyWeekday
        ]
    }
}

// MARK: - Calendar Event helpers

extension CalendarEvent {

    var frequencyPreset: FrequencyPreset {
        guard let rrule = repetitionRule
            .flatMap({ RecurrenceRule(rruleDescription: $0) })
        else { return .noRepeat }

        guard let date = startAt,
              let preset = FrequencyPreset
            .calculativePresets
            .first(where: { $0.rule(given: date) == rrule })
        else {
            return .selected(title: seriesInNaturalLanguage, rule: rrule)
        }

        return preset
    }
}

// MARK: - Utils

extension Date {

    var weekday: Weekday {
        let comp = Cal.currentCalendar.component(.weekday, from: self)
        return Weekday(component: comp) ?? .sunday
    }

    var monthDay: Int {
        return Cal.currentCalendar.component(.day, from: self)
    }

    var month: Int {
        return Cal.currentCalendar.component(.month, from: self)
    }

    var dayOfYear: Int {
        let calendar = Cal.currentCalendar
        let lapsedDays = calendar.dateComponents([.day],
                                                 from: startOfYear(),
                                                 to: calendar.startOfDay(for: self)).day ?? 0
        return lapsedDays + 1
    }

    var monthWeekday: DayOfWeek {
        let weekdayOrdinal = Cal.currentCalendar.component(.weekdayOrdinal, from: self)
        return DayOfWeek(weekday, weekNumber: weekdayOrdinal)
    }

    func startOfYear() -> Date {
        var comps = Cal.currentCalendar.dateComponents([.calendar, .year, .month, .day], from: self)
        comps.month = 1
        comps.day = 1
        return comps.date ?? self
    }
}
