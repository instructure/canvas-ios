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

struct FrequencySelection: Equatable {
    let value: RecurrenceRule
    let title: String
    let preset: FrequencyPreset

    init(_ value: RecurrenceRule, title: String? = nil, preset: FrequencyPreset) {
        let customTitle: String? = preset.isCustom ? "Custom".localized() : nil
        self.title = title ?? customTitle ?? value.text
        self.value = value
        self.preset = preset
    }
}

final class EditEventFrequencyViewModel: ObservableObject {

    let pageTitle = String(localized: "Frequency", bundle: .core)

    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new/frequency")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    let eventDate: Date
    let savedRule: RecurrenceRule?

    let didTapBack = PassthroughSubject<Void, Never>()
    let didSelectCustomFrequency = PassthroughSubject<WeakViewController, Never>()

    var frequencyChoices: [FrequencyChoice] {
        return FrequencyChoice.allCases(given: eventDate)
    }

    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var selection: FrequencyPreset

    init(eventDate: Date,
         savedRule: RecurrenceRule?,
         router: Router,
         completion: @escaping (FrequencySelection?) -> Void) {

        self.router = router
        self.eventDate = eventDate
        self.savedRule = savedRule
        self.selection = FrequencyPreset(given: savedRule, date: eventDate)

        didSelectCustomFrequency
            .sink { [weak self] weakVC in
                self?.showCustomFrequencyScreen(from: weakVC)
            }
            .store(in: &subscriptions)

        didTapBack
            .sink { [weak self] in
                guard let self,
                      let rule = self.selection.rule(given: eventDate)
                else { return completion(nil) }
                let frequency = FrequencySelection(rule, preset: selection)
                completion(frequency)
            }
            .store(in: &subscriptions)
    }

    func showCustomFrequencyScreen(from source: WeakViewController) {
        let vc = CoreHostingController(
            EditCustomFrequencyScreen(
                viewModel: EditCustomFrequencyViewModel(
                    rule: savedRule,
                    proposedDate: eventDate,
                    completion: { [weak self] newRule in
                        self?.selection = .custom(newRule)
                    }
                )
            )
        )
        vc.navigationItem.hidesBackButton = true
        router.show(vc, from: source, options: .push)
    }
}

struct FrequencyChoice: Identifiable {

    static func allCases(given date: Date) -> [FrequencyChoice] {
        return FrequencyPreset
            .presetCases
            .map({ FrequencyChoice(date: date, selectionCase: $0) })
    }

    let id = Foundation.UUID()
    let date: Date
    let selectionCase: FrequencyPreset

    private init(date: Date, selectionCase: FrequencyPreset) {
        self.date = date
        self.selectionCase = selectionCase
    }
}

enum FrequencyPreset: Equatable {

    static var presetCases: [FrequencyPreset] {
        return [
            .noRepeat, .daily, .weeklyOnThatDay, .monthlyOnThatWeekday, .yearlyOnThatMonth, .everyWeekday
        ]
    }

    case noRepeat
    case daily
    case weeklyOnThatDay
    case monthlyOnThatWeekday
    case yearlyOnThatMonth
    case everyWeekday
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
        case .custom(let rule):
            return rule
        }
    }

    init(given rule: RecurrenceRule?, date: Date) {
        guard let rule else {
            self = .noRepeat
            return
        }

        self = Self.presetCases.first(where: { $0.rule(given: date) == rule }) ?? .custom(rule)
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
