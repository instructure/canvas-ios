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

final class SelectCalendarViewModel: ObservableObject {

    struct Section: Identifiable {
        var id: Int
        var title: String?
        var items: [CalendarSelectorItem]
    }

    // MARK: - Output

    let pageTitle = String(localized: "Select Calendar", bundle: .core)
    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new/select") // TODO: verify value + present via `CoreHostingController`
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    let state: InstUI.ScreenState = .data
    @Published private(set) var sections: [Section] = []
    @Published private(set) var selectedId: String?

    func isSelected(id: String) -> Binding<Bool> {
        Binding { [weak self] in
            self?.selectedId == id
        } set: { [weak self] _ in
            self?.interactor.selectCalendar(with: id)
        }
    }

    // MARK: - Input

    // MARK: - Private

    private let interactor: CreateToDoInteractor
    private var subscriptions = Set<AnyCancellable>()

    private var calendars: [CalendarSelectorItem] = []

    private var userCalendar: CalendarSelectorItem? {
        // TODO
        calendars.first
    }

    private var courseCalendars: [CalendarSelectorItem] {
        // TODO
        guard calendars.count >= 3 else { return [] }

        return Array(calendars[1...2])
    }

    private var groupCalendars: [CalendarSelectorItem] {
        // TODO
        guard calendars.count >= 5 else { return [] }

        return Array(calendars[3...4])
    }

    // MARK: - Init

    init(interactor: CreateToDoInteractor) {
        self.interactor = interactor

        interactor.calendars
            .assign(to: \.calendars, on: self, ownership: .weak)
            .store(in: &subscriptions)

        interactor.selectedCalendar
            .map { $0?.id }
            .assign(to: \.selectedId, on: self, ownership: .weak)
            .store(in: &subscriptions)

        sections = [
            Section(id: 0, title: nil, items: [userCalendar].compactMap { $0 }),
            Section(id: 1, title: String(localized: "Courses", bundle: .core), items: courseCalendars),
            Section(id: 2, title: String(localized: "Groups", bundle: .core), items: groupCalendars),
        ]
    }
}
