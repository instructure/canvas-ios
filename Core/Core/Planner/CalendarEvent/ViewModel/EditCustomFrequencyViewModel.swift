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

    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new/frequency")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    let didTapCancel = PassthroughSubject<Void, Never>()
    let didTapDone = PassthroughSubject<Void, Never>()

    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var frequency: RecurrenceFrequency = .daily
    @Published var interval: Int = 1
    @Published var recurrenceEnd: RecurrenceEnd?

    @Published var daysOfTheWeek: [DayOfWeek] = []
    @Published var daysOfTheMonth: [Int] = []
    @Published var monthsOfTheYear: [Int] = []
    @Published var weeksOfTheYear: [Int] = []
    @Published var daysOfTheYear: [Int] = []
    @Published var setPositions: [Int] = []

    init(rule: RecurrenceRule?, completion: @escaping (RecurrenceRule?) -> Void) {
        self.frequency = rule?.frequency ?? .daily
        self.interval = rule?.interval ?? 1
        self.recurrenceEnd = rule?.recurrenceEnd

        self.daysOfTheWeek = rule?.daysOfTheWeek ?? []
        self.daysOfTheMonth = rule?.daysOfTheMonth ?? []
        self.monthsOfTheYear = rule?.monthsOfTheYear ?? []
        self.weeksOfTheYear = rule?.weeksOfTheYear ?? []
        self.daysOfTheYear = rule?.daysOfTheYear ?? []
        self.setPositions = rule?.setPositions ?? []
    }

    var isSaveButtonEnabled: Bool {
        state == .data && recurrenceEnd != nil
    }

    var rule: RecurrenceRule {
        return RecurrenceRule(
            recurrenceWith: frequency,
            interval: interval,
            daysOfTheWeek: daysOfTheWeek.nonEmpty(),
            daysOfTheMonth: daysOfTheMonth.nonEmpty(),
            daysOfTheYear: daysOfTheYear.nonEmpty(),
            weeksOfTheYear: weeksOfTheYear.nonEmpty(),
            monthsOfTheYear: monthsOfTheYear.nonEmpty(),
            setPositions: setPositions.nonEmpty(),
            end: recurrenceEnd
        )
    }
}

extension Array where Element: Equatable {

    mutating func insert(_ element: Element) {
        guard contains(element) == false else { return }
        append(element)
    }
}
