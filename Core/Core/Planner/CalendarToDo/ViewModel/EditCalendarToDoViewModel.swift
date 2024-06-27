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

final class EditCalendarToDoViewModel: ObservableObject {

    private enum Mode {
        case add
        case edit(id: String)
    }

    // MARK: - Output

    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var title: String
    @Published var date: Date?
    @Published var calendarName: String?
    @Published var details: String
    @Published var shouldShowAlert: Bool = false

    var isSaveButtonEnabled: Bool {
        state == .data && title.isNotEmpty && isTouched
    }

    lazy var pageTitle: String = {
        switch mode {
        case .add: String(localized: "New To Do", bundle: .core)
        case .edit: String(localized: "Edit To Do", bundle: .core)
        }
    }()

    lazy var saveButtonTitle: String = {
        switch mode {
        case .add: String(localized: "Add", bundle: .core)
        case .edit: String(localized: "Save", bundle: .core)
        }
    }()

    lazy var alert: ErrorAlertViewModel = {
        .init(
            title: {
                switch mode {
                case .add: String(localized: "Unsuccessful Creation!", bundle: .core)
                case .edit: String(localized: "Save Unsuccessful!", bundle: .core)
                }
            }(),
            message: {
                switch mode {
                case .add: String(localized: "Your To Do was not added, you can try it again.", bundle: .core)
                case .edit: String(localized: "Your changes were not saved, you can try it again.", bundle: .core)
                }
            }(),
            buttonTitle: String(localized: "OK", bundle: .core)
        )
    }()

    lazy var selectCalendarViewModel: SelectCalendarViewModel = {
        return .init(
            calendarListProviderInteractor: calendarListProviderInteractor,
            calendarTypes: [.user, .course],
            selectedCalendar: selectedCalendar
        )
    }()

    // MARK: - Input

    let didTapCancel = PassthroughSubject<Void, Never>()
    let didTapSave = PassthroughSubject<Void, Never>()

    // MARK: - Private

    private let mode: Mode
    private let toDoInteractor: CalendarToDoInteractor
    private let calendarListProviderInteractor: CalendarFilterInteractor
    private var selectedCalendar = CurrentValueSubject<CDCalendarFilterEntry?, Never>(nil)
    private var isTouched: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(
        plannable: Plannable? = nil,
        toDoInteractor: CalendarToDoInteractor,
        calendarListProviderInteractor: CalendarFilterInteractor,
        completion: @escaping (PlannerAssembly.Completion) -> Void
    ) {
        self.toDoInteractor = toDoInteractor
        self.calendarListProviderInteractor = calendarListProviderInteractor

        if let plannable {
            mode = .edit(id: plannable.id)
        } else {
            mode = .add
        }

        title = plannable?.title ?? ""
        date = plannable?.date ?? Clock.now.endOfDay() // end of today, to match default web behaviour
        details = plannable?.details ?? ""

        subscribeIsTouched(to: $title)
        subscribeIsTouched(to: $date)
        subscribeIsTouched(to: $details)

        calendarListProviderInteractor
            .load(ignoreCache: false)
            .sink()
            .store(in: &subscriptions)

        calendarListProviderInteractor.filters
            .first { $0.isEmpty == false }
            .compactMap {
                $0.first {
                    if let context = plannable?.context, context.contextType == .course {
                        $0.context == context
                    } else {
                        $0.context.contextType == .user
                    }
                }
            }
            .sink { [weak selectedCalendar] in
                selectedCalendar?.send($0)
            }
            .store(in: &subscriptions)

        selectedCalendar
            .map { [weak self] in
                if let oldCalendarName = self?.calendarName, oldCalendarName != $0?.name {
                    self?.isTouched = true
                }
                return $0?.name
            }
            .assign(to: \.calendarName, on: self, ownership: .weak)
            .store(in: &subscriptions)

        didTapCancel
            .sink { completion(.didCancel) }
            .store(in: &subscriptions)

        didTapSave
            .map { [weak self] in
                self?.state = .data(loadingOverlay: true)
            }
            .flatMap { [weak self] in
                guard let self else {
                    return Just(Result<Void, Error>.failure(NSError.internalError()))
                        .eraseToAnyPublisher()
                }

                return saveAction()
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
    }

    private func subscribeIsTouched<T: Equatable>(to publisher: Published<T>.Publisher) {
        publisher
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.isTouched = true }
            .store(in: &subscriptions)
    }

    private func saveAction() -> AnyPublisher<Result<Void, Error>, Never> {
        switch mode {
        case .add:
            toDoInteractor.createToDo(
                title: title,
                date: date ?? .now,
                calendar: selectedCalendar.value,
                details: details
            )
            .mapToResult()
            .eraseToAnyPublisher()
        case .edit(let id):
            toDoInteractor.updateToDo(
                id: id,
                title: title,
                date: date ?? .now,
                calendar: selectedCalendar.value,
                details: details
            )
            .mapToResult()
            .eraseToAnyPublisher()
        }
    }
}
