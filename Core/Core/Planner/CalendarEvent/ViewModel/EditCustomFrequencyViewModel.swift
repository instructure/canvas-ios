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

    // MARK: - Page Setup

    let pageTitle = String(localized: "Custom Frequency", bundle: .core)
    let doneButtonTitle: String = String(localized: "Done", bundle: .core)
    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new/frequency/custom")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    // MARK: - Data
    let proposedDate: Date

    // MARK: - Actions
    let didTapDone = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Inputs / Outputs

    @Published private(set) var state: InstUI.ScreenState = .data

    @Published var frequency: RecurrenceFrequency = .daily
    @Published var interval = FrequencyInterval(value: 1)

    @Published var endMode: RecurrenceEndMode?
    @Published var endDate: Date? = Clock.now
    @Published var occurrenceCount: Int

    /// Specific to Weekly
    @Published var daysOfTheWeek: [Weekday] = []

    /// Specific to Monthly
    @Published var dayOfMonth: DayOfMonth?

    // MARK: - Outputs

    /// Specific to Yearly
    @Published var dayOfYear: DayOfYear?

    var titleForProposedDayOfYear: String {
        return proposedDate.formatted(format: "MMMM d")
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

    // MARK: - Private

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    init(rule: RecurrenceRule?,
         proposedDate date: Date,
         router: Router,
         completion: @escaping (RecurrenceRule) -> Void) {

        let frequency = rule?.frequency ?? .daily
        self.frequency = frequency
        self.interval = FrequencyInterval(value: rule?.interval ?? 1)
        self.router = router

        if let end = rule?.recurrenceEnd {
            self.endMode = .mode(of: end)
        }

        self.endDate = rule?.recurrenceEnd?.asEndDate ?? Clock.now
        self.occurrenceCount = rule?.recurrenceEnd?.asOccurrenceCount ?? 0

        if case .weekly = frequency {
            self.daysOfTheWeek = rule?.daysOfTheWeek?.map({ $0.weekday }) ?? []
        }

        if case .monthly = frequency {
            if let weekDay = rule?.daysOfTheWeek?.first {
                self.dayOfMonth = DayOfMonth.weekday(weekDay)
            } else if let monthDay = rule?.daysOfTheMonth?.first {
                self.dayOfMonth = DayOfMonth.day(monthDay)
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
            .dropFirst()
            .removeDuplicates()
            .filter({ $0 == .yearly })
            .sink { [weak self] freq in
                guard case .yearly = freq else {
                    self?.dayOfYear = nil
                    return
                }
                self?.dayOfYear = DayOfYear(given: date, in: .current)
            }
            .store(in: &subscriptions)

        didTapDone
            .sink { [weak self] weakVC in
                guard let rule = self?.translatedRule else { return }
                completion(rule)
                router.popToRoot(from: weakVC.value)
            }
            .store(in: &subscriptions)
    }

    var end: RecurrenceEnd? {
        switch (endMode, endDate, occurrenceCount) {
        case (.onDate, .some(let date), _):
            return .endDate(date)
        case (.afterOccurrences, _, let count) where count > 0:
            return .occurrenceCount(count)
        default:
            return nil
        }
    }

    var translatedRule: RecurrenceRule? {
        guard let end else { return nil }

        var daysOfWeek: [DayOfWeek]?
        var daysOfTheMonth: [Int]?
        var monthsOfTheYear: [Int]?

        if case .weekly = frequency {
            daysOfWeek = daysOfTheWeek.map({ DayOfWeek($0) }).nilIfEmpty
        }

        if case .monthly = frequency, let monthDay = dayOfMonth {
            switch monthDay {
            case .weekday(let weekday):
                daysOfWeek = [weekday]
            case .day(let dayNo):
                daysOfTheMonth = [dayNo]
            }
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

// MARK: - Selected Weekdays Text

extension EditCustomFrequencyViewModel {

    /// ### Possible cases:
    ///
    /// 1. Less than 3 selected ~> returns **Plural** forms.
    ///
    /// Example: `[.sunday, .monday] ~> [Sundays, Mondays]`
    ///
    /// 2. 3 or more selected -> returns **Short** forms.
    ///
    /// Example: `[.sunday, .monday, .friday] ~> [Sun, Mon, Fri]`
    ///
    /// 3. Weekdays (Monday to Friday) selected ~> returns **"Weekdays"**
    ///
    /// 4. Weekdays & 1 more selected ~> returns **["Weekdays", "{DAY Short Form}"]**
    ///
    /// Example: `[.monday, .., .friday, .saturday] ~>  ["Weekdays", "Sat"]`
    ///
    /// 5. All days selected ~> returns **["Every Day of the Week"]**
    ///
    var selectedWeekdaysTexts: [String] {

        let weekdays = daysOfTheWeek
        var tags = [String]()

        if weekdays.allDaysIncluded {
            return [String(localized: "Every Day of the Week", bundle: .core)]
        }

        if weekdays.hasWeekdays {
            tags.append(String(localized: "Weekdays", bundle: .core))

            if let nonWeekDays = weekdays.nonWeekdays.nilIfEmpty {
                tags.append(contentsOf: nonWeekDays.map({ $0.shortText }))
            }

        } else {
            let fewDays = weekdays.count < 3
            tags.append(contentsOf: weekdays.map { wday in
                return fewDays ? wday.pluralText : wday.shortText
            })
        }

        return tags.nilIfEmpty ?? [String(localized: "Not selected", bundle: .core)]
    }
}

private extension Array where Element == Weekday {

    var nonWeekdays: Self {
        filter({ Weekday.weekDays.contains($0) == false })
    }

    var allDaysIncluded: Bool {
        Weekday.allCases.allSatisfy({ contains($0) })
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

    static func mode(of end: RecurrenceEnd) -> RecurrenceEndMode {
        switch end {
        case .endDate:
            return .onDate
        case .occurrenceCount:
            return .afterOccurrences
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
