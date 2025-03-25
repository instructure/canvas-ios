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

import Combine
import SwiftUI

enum CalendarType {
    case user, course, group
}

final class SelectCalendarViewModel: ObservableObject {

    struct Section: Identifiable {
        var id: Int
        var title: String?
        var items: [OptionItem]
    }

    // MARK: - Output

    let pageTitle = String(localized: "Select Calendar", bundle: .core)
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    let state: InstUI.ScreenState = .data
    @Published private(set) var sections: [Section] = []
    let selectedCalendarOption = CurrentValueSubject<OptionItem?, Never>(nil)

    // MARK: - Private

    private let calendarListProviderInteractor: CalendarFilterInteractor
    private var calendars: [CDCalendarFilterEntry] = []
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        calendarListProviderInteractor: CalendarFilterInteractor,
        calendarTypes: Set<CalendarType>,
        selectedCalendar: CurrentValueSubject<CDCalendarFilterEntry?, Never>
    ) {
        self.calendarListProviderInteractor = calendarListProviderInteractor
        self.selectedCalendarOption.value = selectedCalendar.value?.optionItem

        selectedCalendarOption
            .compactMap { [weak self] optionItem in
                return self?.calendars.first { $0.isMatch(for: optionItem) }
            }
            .sink(receiveValue: { [weak selectedCalendar] filter in
                selectedCalendar?.send(filter)
            })
            .store(in: &subscriptions)

        calendarListProviderInteractor.filters
            .sink { [weak self] calendars in
                let userCalendar = calendarTypes.contains(.user)
                    ? calendars.first { $0.context.contextType == .user }
                    : nil
                let courseCalendars = calendarTypes.contains(.course)
                    ? calendars.filter { $0.context.contextType == .course }.sorted()
                    : []
                let groupCalendars = calendarTypes.contains(.group)
                    ? calendars.filter { $0.context.contextType == .group }.sorted()
                    : []

                self?.sections = [
                    Section(id: 0, title: nil, items: [userCalendar].compactMap { $0?.optionItem }),
                    Section(id: 1, title: String(localized: "Courses", bundle: .core), items: courseCalendars.map(\.optionItem)),
                    Section(id: 2, title: String(localized: "Groups", bundle: .core), items: groupCalendars.map(\.optionItem))
                ]
                self?.calendars = calendars
            }
            .store(in: &subscriptions)

        calendarListProviderInteractor
            .load(ignoreCache: false)
            .sink()
            .store(in: &subscriptions)
    }
}

private extension CDCalendarFilterEntry {
    var optionItem: OptionItem {
        .init(id: id, title: name, color: color)
    }

    func isMatch(for optionItem: OptionItem?) -> Bool {
        id == optionItem?.id
    }
}
