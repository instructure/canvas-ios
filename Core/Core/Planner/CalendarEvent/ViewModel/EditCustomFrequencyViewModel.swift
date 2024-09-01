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

import SwiftUI
import Combine

final class EditCustomFrequencyViewModel: ObservableObject {

    let pageTitle = String(localized: "Custom Frequency", bundle: .core)
    let doneButtonTitle: String = String(localized: "Done", bundle: .core)

    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new/frequency/custom")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    private var subscriptions = Set<AnyCancellable>()

    let didTapDone = PassthroughSubject<RecurrenceRule, Never>()
    let proposedDate: Date

    var titleForProposedDayOfYear: String {
        return proposedDate.formatted(format: "MMMM d")
    }

    @Published private(set) var state: InstUI.ScreenState = .data

    @Published var frequency: RecurrenceFrequency = .daily
    @Published var interval = FrequencyInterval(value: 1)

    @Published var endMode: RecurrenceEndMode?
    @Published var endDate: Date? = .now
    @Published var occurrenceCount: Int

    // Specific to Weekly
    @Published var daysOfTheWeek: [Weekday] = []

    // Specific to Monthly
    @Published var dayOfMonth: DayOfMonth?

    // Specific to Yearly
    @Published var dayOfYear: DayOfYear?

    init(rule: RecurrenceRule?, proposedDate date: Date, completion: @escaping (RecurrenceRule) -> Void) {
        let frequency = rule?.frequency ?? .daily

        self.frequency = frequency
        self.interval = FrequencyInterval(value: rule?.interval ?? 1)

        if let end = rule?.recurrenceEnd {
            self.endMode = end.endDate != nil ? .onDate : .afterOccurrences
        }

        self.endDate = rule?.recurrenceEnd?.endDate ?? .now
        self.occurrenceCount = rule?.recurrenceEnd?.occurrenceCount ?? 0

        if case .weekly = frequency {
            self.daysOfTheWeek = rule?.daysOfTheWeek?.map({ $0.weekday }) ?? []
        }

        if case .monthly = frequency {
            if let dayOfWeek = rule?.daysOfTheWeek?.first {
                self.dayOfMonth = DayOfMonth(weekday: dayOfWeek)
            } else {
                self.dayOfMonth = DayOfMonth(day: rule?.daysOfTheMonth?.first ?? 0)
            }
        }

        if case .yearly = frequency {
            if let day = rule?.daysOfTheMonth?.first,
               let month = rule?.monthsOfTheYear?.first {
                self.dayOfYear = DayOfYear(day: day, month: month)
            }
        }

        self.proposedDate = date

        self.$frequency
            .filter({ $0 == .yearly })
            .sink { [weak self] _ in
                self?.dayOfYear = DayOfYear(given: date, in: .current)
            }
            .store(in: &subscriptions)

        didTapDone
            .sink { ruleToSave in
                completion(ruleToSave)
            }
            .store(in: &subscriptions)
    }

    var isSaveButtonEnabled: Bool {
        guard state == .data && end != nil else { return false }

        if case .weekly = frequency {
            return daysOfTheWeek.isEmpty == false
        }

        if case .monthly = frequency {
            return dayOfMonth != nil
        }

        if case .yearly = frequency {
            return dayOfYear != nil
        }
        
        return true
    }

    var end: RecurrenceEnd? {
        switch (endMode, endDate, occurrenceCount) {
        case (.onDate, .some(let date), _):
            return RecurrenceEnd(endDate: date)
        case (.afterOccurrences, _, let count) where count > 0:
            return RecurrenceEnd(occurrenceCount: count)
        default:
            return nil
        }
    }

    var translatedRule: RecurrenceRule? {

        var daysOfWeek: [DayOfWeek]?
        var daysOfTheMonth: [Int]?
        var monthsOfTheYear: [Int]?

        if case .weekly = frequency {
            daysOfWeek = daysOfTheWeek.map({ DayOfWeek($0) }).nilIfEmpty
        }

        if case .monthly = frequency {
            daysOfWeek = dayOfMonth?.weekday.flatMap({ [$0] })
            daysOfTheMonth = dayOfMonth?.day.flatMap({ [$0] })
        }

        if case .yearly = frequency {
            daysOfTheMonth = dayOfYear.flatMap({ [$0.day] })
            monthsOfTheYear = dayOfYear.flatMap({ [$0.month] })
        }

        return RecurrenceRule(
            recurrenceWith: frequency,
            interval: interval.value,
            daysOfTheWeek: daysOfWeek,
            daysOfTheMonth: daysOfTheMonth,
            daysOfTheYear: nil,
            weeksOfTheYear: nil,
            monthsOfTheYear: monthsOfTheYear,
            setPositions: nil,
            end: end
        )
    }
}

// MARK: - Helper Types

struct FrequencyInterval: Equatable {
    static var options: [FrequencyInterval] { (1 ... 400).map({ FrequencyInterval(value: $0) }) }

    let value: Int
    var title: String { value.formatted(.number) }

    init(value: Int) {
        self.value = value
    }
}

struct DayOfYear {
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

enum RecurrenceEndMode: Equatable, CaseIterable {
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
}

// MARK: - Utils

extension Array where Element: Equatable {

    mutating func insert(_ element: Element) {
        guard contains(element) == false else { return }
        append(element)
    }
}
