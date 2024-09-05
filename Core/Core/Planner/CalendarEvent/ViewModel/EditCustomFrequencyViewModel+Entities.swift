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

extension EditCustomFrequencyViewModel {
    typealias DayOfWeek = RecurrenceRule.DayOfWeek

    enum DayOfMonth: Equatable, Identifiable {
        case weekday(DayOfWeek)
        case day(Int)

        var id: String {
            let info: String
            switch self {
            case .weekday(let dayOfWeek):
                info = [
                    "weekday: \(dayOfWeek.weekday.dateComponent)",
                    dayOfWeek.weekNumber.flatMap({ "weekNumber: \($0)" })
                ]
                    .compactMap({ $0 })
                    .joined(separator: ", ")
            case .day(let dayNo):
                info = "day: \(dayNo)"
            }
            return "[\(info)]"
        }

        var title: String {
            switch self {
            case .weekday(let dayOfWeek):
                return dayOfWeek.standaloneText
            case .day(let dayNo):
                return String(localized: "Day %@", bundle: .core)
                    .asFormat(for: dayNo.formatted(.number))
            }
        }
    }

    struct DayOfYear: Equatable {
        var day: Int
        var month: Int

        init(given date: Date, in calendar: Calendar = .current) {
            let comps = calendar.dateComponents(
                [.day, .month, .year],
                from: date
            )

            self.init(day: comps.day!, month: comps.month!)
        }

        init(day: Int, month: Int) {
            self.day = day
            self.month = month
        }
    }

    enum EndMode: Equatable, CaseIterable {
        case onDate
        case afterOccurrences

        var title: String {
            switch self {
            case .onDate:
                return String(localized: "On date", bundle: .core)
            case .afterOccurrences:
                return String(localized: "After Occurrences", bundle: .core)
            }
        }

        static func mode(of end: RecurrenceEnd) -> EndMode {
            switch end {
            case .endDate:
                return .onDate
            case .occurrenceCount:
                return .afterOccurrences
            }
        }
    }

    func dayOfMonthOptions(for date: Date, in calendar: Calendar = Cal.currentCalendar) -> [DayOfMonth] {
        let comps = calendar.dateComponents(
            [.calendar, .day, .weekday, .weekdayOrdinal, .month, .year],
            from: date
        )

        let weekday = comps.weekday.flatMap({ Weekday(component: $0) }) ?? .sunday
        let weekNumber = comps.weekdayOrdinal
        let day = comps.day ?? 0

        return [
            DayOfMonth.day(day),
            DayOfMonth.weekday(DayOfWeek(weekday, weekNumber: weekNumber))
        ]
    }
}
