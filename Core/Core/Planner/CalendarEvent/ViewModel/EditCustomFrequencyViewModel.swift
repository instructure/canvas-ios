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
import CombineSchedulers

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
    @Published var isOccurrencesDialogPresented: Bool = false

    @Published var frequency: RecurrenceFrequency = .daily
    @Published var interval = FrequencyInterval(value: 1)

    @Published var endMode: EndMode?
    @Published var endDate: Date? = Clock.now
    @Published var occurrenceCount: Int

    /// Specific to Weekly
    @Published var daysOfTheWeek: [Weekday] = []

    /// Specific to Monthly
    let proposedDayOfMonth: DayOfMonth
    @Published var dayOfMonth: DayOfMonth

    // MARK: - Outputs

    /// Specific to Yearly
    @Published var dayOfYear: DayOfYear

    var isSaveButtonEnabled: Bool {
        guard state == .data && end != nil else { return false }

        if case .weekly = frequency {
            return daysOfTheWeek.isEmpty == false
        }

        return true
    }

    // MARK: - Private

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    init(rule: RecurrenceRule?,
         proposedDate date: Date,
         router: Router,
         scheduler: AnySchedulerOf<DispatchQueue> = .main,
         completion: @escaping (RecurrenceRule) -> Void) {

        let frequency = rule?.frequency ?? .daily
        self.frequency = frequency
        self.interval = FrequencyInterval(value: rule?.interval ?? 1)
        self.router = router

        self.endMode = rule?.recurrenceEnd.flatMap({ .mode(of: $0) })
        self.endDate = rule?.recurrenceEnd?.asEndDate ?? Clock.now
        self.occurrenceCount = rule?.recurrenceEnd?.asOccurrenceCount ?? 0

        self.daysOfTheWeek = [date.weekday]
        if case .weekly = frequency {
            self.daysOfTheWeek = rule?.daysOfTheWeek?.map { $0.weekday } ?? []
        }

        self.proposedDayOfMonth = DayOfMonth.day(date.monthDay)
        self.dayOfMonth = proposedDayOfMonth
        if case .monthly = frequency {
            if let weekDay = rule?.daysOfTheWeek?.first {
                self.dayOfMonth = DayOfMonth.weekday(weekDay)
            } else if let monthDay = rule?.daysOfTheMonth?.first {
                self.dayOfMonth = DayOfMonth.day(monthDay)
            }
        }

        self.dayOfYear = DayOfYear(given: date, in: .current)
        if case .yearly = frequency {
            if let day = rule?.daysOfTheMonth?.first,
               let month = rule?.monthsOfTheYear?.first {
                self.dayOfYear = DayOfYear(day: day, month: month)
            }
        }

        self.proposedDate = date

        self.$endMode
            .dropFirst()
            .compactMap({ $0 })
            .filter({ [weak self] mode in
                guard let self, self.occurrenceCount == 0 else { return false }
                return mode == .afterOccurrences
            })
            .mapToVoid()
            .receive(on: scheduler)
            .sink { [weak self] in
                self?.isOccurrencesDialogPresented = true
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

        if case .monthly = frequency {
            switch dayOfMonth {
            case .weekday(let weekday):
                daysOfWeek = [weekday]
            case .day(let dayNo):
                daysOfTheMonth = [dayNo]
            }
        }

        if case .yearly = frequency {
            daysOfTheMonth = [dayOfYear.day]
            monthsOfTheYear = [dayOfYear.month]
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
    var selectedWeekdayTags: [SelectedWeekdayTag] {
        typealias Tag = SelectedWeekdayTag

        let weekdays = daysOfTheWeek.sorted(by: { $0.sortOrder < $1.sortOrder })
        var tags = [Tag]()

        if weekdays.allDaysIncluded {
            return [Tag(text: String(localized: "Every Day of the Week", bundle: .core))]
        }

        if weekdays.hasWeekdays {
            tags.append(Tag(text: String(localized: "Weekdays", bundle: .core)))

            if let nonWeekDays = weekdays.nonWeekdays.nilIfEmpty {
                tags.append(
                    contentsOf: nonWeekDays.map {
                        Tag(text: $0.shortText, accessibilityLabel: $0.text)
                    }
                )
            }

        } else {
            let fewDays = weekdays.count < 3
            tags.append(contentsOf: weekdays.map { wday in
                return Tag(
                    text: fewDays ? wday.pluralText : wday.shortText,
                    accessibilityLabel: fewDays ? wday.pluralText : wday.text
                )
            })
        }

        return tags.nilIfEmpty ?? []
    }

    struct SelectedWeekdayTag {
        let text: String
        let accessibilityLabel: String

        init(text: String, accessibilityLabel: String? = nil) {
            self.text = text
            self.accessibilityLabel = accessibilityLabel ?? text
        }
    }
}

private extension Array where Element == Weekday {

    var nonWeekdays: Self {
        filter { Weekday.weekDays.contains($0) == false }
    }

    var allDaysIncluded: Bool {
        Weekday.allCases.allSatisfy { contains($0) }
    }
}

// MARK: - Helper Types

struct FrequencyInterval: Equatable {
    static var options: [FrequencyInterval] { (1 ... 400).map { FrequencyInterval(value: $0) } }

    let value: Int
    var title: String { value.formatted(.number) }

    init(value: Int) {
        self.value = value
    }
}

// MARK: - Utils

extension Array where Element: Equatable {

    mutating func insert(_ element: Element) {
        guard contains(element) == false else { return }
        append(element)
    }
}
