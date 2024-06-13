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

import Combine
import SwiftUI

final class CreateToDoViewModel: ObservableObject {

    // MARK: - Output

    let pageTitle = String(localized: "New To Do", bundle: .core)
    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var title: String = ""
    @Published var date: Date?
    @Published var details: String = ""
    @Published var shouldShowAlert: Bool = false
    @Published var calendarName: String?

    var isAddButtonEnabled: Bool {
        state == .data && title.isNotEmpty
    }

    lazy var selectCalendarViewModel: SelectCalendarViewModel = {
        return .init(
            calendarListProviderInteractor: calendarListProviderInteractor,
            calendarTypes: [.user, .course],
            selectedCalendar: selectedCalendar
        )
    }()

    // MARK: - Input

    let didTapCancel = PassthroughSubject<Void, Never>()
    let didTapAdd = PassthroughSubject<Void, Never>()

    // MARK: - Private

    private let createToDoInteractor: CreateToDoInteractor
    private let calendarListProviderInteractor: CalendarFilterInteractor
    private var subscriptions = Set<AnyCancellable>()
    private var selectedCalendar = CurrentValueSubject<CDCalendarFilterEntry?, Never>(nil)

    // MARK: - Init

    init(
        createToDoInteractor: CreateToDoInteractor,
        calendarListProviderInteractor: CalendarFilterInteractor,
        completion: @escaping (PlannerAssembly.Completion) -> Void
    ) {
        self.createToDoInteractor = createToDoInteractor
        self.calendarListProviderInteractor = calendarListProviderInteractor

        // end of today, to match default web behaviour
        date = .now.endOfDay()

        calendarListProviderInteractor.filters
            .first { $0.isEmpty == false }
            .compactMap { $0.first { $0.context.contextType == .user } }
            .sink { [weak selectedCalendar] in
                selectedCalendar?.send($0)
            }
            .store(in: &subscriptions)

        selectedCalendar
            .map { $0?.name }
            .assign(to: \.calendarName, on: self, ownership: .weak)
            .store(in: &subscriptions)

        didTapCancel
            .sink { completion(.didCancel) }
            .store(in: &subscriptions)

        didTapAdd
            .map { [weak self] in
                self?.state = .data(loadingOverlay: true)
            }
            .flatMap { [weak self] in
                guard let self else {
                    return Just(Result<Void, Error>.failure(NSError.internalError()))
                        .eraseToAnyPublisher()
                }

                return createToDoInteractor.createToDo(
                    title: title,
                    date: date ?? .now,
                    calendar: selectedCalendar.value,
                    details: details
                )
                .mapToResult()
                .eraseToAnyPublisher()
            }
            .sink { [weak self] result in
                switch result {
                case .success:
                    completion(.didUpdate)
                case .failure:
                    self?.state = .data
                    self?.shouldShowAlert = true
                }
            }
            .store(in: &subscriptions)

        calendarListProviderInteractor
            .load(ignoreCache: false)
            .sink()
            .store(in: &subscriptions)
    }
}
