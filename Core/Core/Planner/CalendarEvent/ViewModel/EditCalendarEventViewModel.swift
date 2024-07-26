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

/*TODO: */ final class EventFrequency {
    var name: String
    init(name: String) {
        self.name = name
    }
}

final class EditCalendarEventViewModel: ObservableObject {

    private enum Mode {
        case add
        case edit(id: String)
    }

    // MARK: - Output

    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)

    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var title: String = ""
    @Published var date: Date?
    @Published var isAllDay: Bool = false
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var frequencyName: String?
    @Published var calendarName: String?
    @Published var location: String = ""
    @Published var address: String = ""
    @Published var details: String = ""

    @Published var endTimeErrorMessage: String?
    @Published var shouldShowSaveError: Bool = false

    var isSaveButtonEnabled: Bool {
        state == .data
        && eventInteractor.isRequestModelValid(model)
        && isFieldsTouched
    }

    lazy var pageTitle: String = {
        switch mode {
        case .add: String(localized: "New Event", bundle: .core)
        case .edit: String(localized: "Edit Event", bundle: .core)
        }
    }()

    lazy var saveButtonTitle: String = {
        switch mode {
        case .add: String(localized: "Add", bundle: .core)
        case .edit: String(localized: "Save", bundle: .core)
        }
    }()

    lazy var saveErrorAlert: ErrorAlertViewModel = {
        .init(
            title: {
                switch mode {
                case .add: String(localized: "Creation not completed", bundle: .core)
                case .edit: String(localized: "Saving not completed", bundle: .core)
                }
            }(),
            message: {
                switch mode {
                case .add: String(localized: "We couldn't add your Event at this time. You can try it again.", bundle: .core)
                case .edit: String(localized: "We couldn't save your Event at this time. You can try it again.", bundle: .core)
                }
            }(),
            buttonTitle: String(localized: "OK", bundle: .core)
        )
    }()

    // MARK: - Input

    let didTapCancel = PassthroughSubject<Void, Never>()
    let didTapSave = PassthroughSubject<Void, Never>()
    let showFrequencySelector = PassthroughSubject<WeakViewController, Never>()
    let showCalendarSelector = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    private let mode: Mode
    private let eventInteractor: CalendarEventInteractor
    private let calendarListProviderInteractor: CalendarFilterInteractor
    private let router: Router
    /*TODO: */ private var selectedFrequency = CurrentValueSubject<EventFrequency?, Never>(nil)
    private var selectedCalendar = CurrentValueSubject<CDCalendarFilterEntry?, Never>(nil)
    /// Returns true if any of the fields had been modified once by the user. It doesn't compare values.
    private var isFieldsTouched: Bool = false

    private var subscriptions = Set<AnyCancellable>()

    internal lazy var selectCalendarViewModel: SelectCalendarViewModel = {
        return .init(
            calendarListProviderInteractor: calendarListProviderInteractor,
            /*TODO: */ calendarTypes: [.user, .group], // TODO: check `manage_calendar` field
            selectedCalendar: selectedCalendar
        )
    }()

    // MARK: - Init

    init(
        event: CalendarEvent? = nil,
        eventInteractor: CalendarEventInteractor,
        calendarListProviderInteractor: CalendarFilterInteractor,
        router: Router,
        completion: @escaping (PlannerAssembly.Completion) -> Void
    ) {
        self.eventInteractor = eventInteractor
        self.calendarListProviderInteractor = calendarListProviderInteractor
        self.router = router

        if let event {
            mode = .edit(id: event.id)
        } else {
            mode = .add
        }

        setupFields(event: event)

        subscribeIsFieldsTouched(to: $title)
        subscribeIsFieldsTouched(to: $date)
        subscribeIsFieldsTouched(to: $isAllDay)
        subscribeIsFieldsTouched(to: $startTime)
        subscribeIsFieldsTouched(to: $endTime)
        subscribeIsFieldsTouched(to: $date)
        subscribeIsFieldsTouched(to: $location)
        subscribeIsFieldsTouched(to: $address)
        subscribeIsFieldsTouched(to: $details)

        calendarListProviderInteractor
            .load(ignoreCache: false)
            .sink()
            .store(in: &subscriptions)

        calendarListProviderInteractor.filters
            .first { $0.isEmpty == false }
            .compactMap {
                $0.first {
                    if let eventContext = event?.context {
                        $0.context == eventContext
                    } else {
                        $0.context.contextType == .user
                    }
                }
            }
            .sink { [selectedCalendar] in
                selectedCalendar.send($0)
            }
            .store(in: &subscriptions)

        $startTime
            .sink { [weak self] newStartTime in self?.updateEndTimeError(newStartTime, self?.endTime) }
            .store(in: &subscriptions)

        $endTime
            .sink { [weak self] newEndTime in self?.updateEndTimeError(self?.startTime, newEndTime) }
            .store(in: &subscriptions)

        selectedFrequency
            .map { [weak self] in
                if let oldfrequencyName = self?.frequencyName, oldfrequencyName != $0?.name {
                    self?.isFieldsTouched = true
                }
                return $0?.name
            }
            .assign(to: \.frequencyName, on: self, ownership: .weak)
            .store(in: &subscriptions)

        selectedCalendar
            .map { [weak self] in
                if let oldCalendarName = self?.calendarName, oldCalendarName != $0?.name {
                    self?.isFieldsTouched = true
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
                (self?.saveAction() ?? Empty().eraseToAnyPublisher())
                    .catch { _ in
                        self?.state = .data
                        self?.shouldShowSaveError = true
                        return Empty<Void, Never>().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink {
                completion(.didUpdate)
            }
            .store(in: &subscriptions)

        showFrequencySelector
            .sink { [weak self] in self?.showSelectFrequencyScreen(from: $0) }
            .store(in: &subscriptions)

        showCalendarSelector
            .sink { [weak self] in self?.showSelectCalendarScreen(from: $0) }
            .store(in: &subscriptions)
    }

    // MARK: - Private methods

    private func setupFields(event: CalendarEvent?) {
        title = event?.title ?? ""

        date = event?.startAt ?? Clock.now.startOfDay()
        isAllDay = event?.isAllDay ?? false

        if isAllDay {
            startTime = defaultStartTime
            endTime = defaultEndTime
        } else {
            startTime = event?.startAt ?? defaultStartTime
            endTime = event?.endAt ?? defaultEndTime
        }

        location = event?.locationName ?? ""
        address = event?.locationAddress ?? ""
        details = event?.details ?? ""
    }

    private var defaultStartTime: Date {
        // 11:46 -> 12:00
        Clock.now.startOfHour().addHours(1)
    }

    private var defaultEndTime: Date {
        // 11:46 -> start 12:00, end 13:00
        let startTime = startTime ?? defaultStartTime
        let hours = startTime.hours + 1
        return startTime.startOfDay().addHours(hours)
    }

    private func updateEndTimeError(_ startTime: Date?, _ endTime: Date?) {
        if let startTime, let endTime, endTime < startTime {
            endTimeErrorMessage = String(localized: "End time cannot be before Start time", bundle: .core)
        } else {
            endTimeErrorMessage = nil
        }
    }

    private func subscribeIsFieldsTouched<T: Equatable>(to publisher: Published<T>.Publisher) {
        publisher
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in self?.isFieldsTouched = true }
            .store(in: &subscriptions)
    }

    private func showSelectFrequencyScreen(from source: WeakViewController) {
        let vc = CoreHostingController(
            /*TODO: */ BaseScreenTesterScreen()
        )
        router.show(vc, from: source, options: .push)
    }

    private func showSelectCalendarScreen(from source: WeakViewController) {
        let vc = CoreHostingController(
            SelectCalendarScreen(viewModel: selectCalendarViewModel)
        )
        router.show(vc, from: source, options: .push)
    }

    private var model: CalendarEventRequestModel? {
        guard let date,
              let startTime,
              let endTime,
              let calendar = selectedCalendar.value
        else { return nil }

        return .init(
            title: title,
            date: date,
            isAllDay: isAllDay,
            startTime: startTime,
            endTime: endTime,
            calendar: calendar,
            location: location.nilIfEmpty,
            address: address.nilIfEmpty,
            details: details.nilIfEmpty
        )
    }

    private func saveAction() -> AnyPublisher<Void, Error>? {
        guard let model else { return nil }

        switch mode {
        case .add:
            return eventInteractor.createEvent(model: model)
        case .edit(let id):
            return eventInteractor.updateEvent(id: id, model: model)
        }
    }
}
