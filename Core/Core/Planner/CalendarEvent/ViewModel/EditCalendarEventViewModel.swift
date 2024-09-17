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

final class EditCalendarEventViewModel: ObservableObject {
    typealias SeriesModificationType = APICalendarEventSeriesModificationType

    private enum Mode {
        case add
        case edit(id: String)
    }

    // MARK: - Output

    let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/new")
    let screenConfig = InstUI.BaseScreenConfig(refreshable: false)
    let uploadParameters: RichContentEditorUploadParameters

    @Published private(set) var state: InstUI.ScreenState = .data
    @Published var title: String = ""
    @Published var date: Date?
    @Published var isAllDay: Bool = false
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published private(set) var frequency: FrequencySelection?
    @Published private(set) var calendarName: String?
    @Published var location: String = ""
    @Published var address: String = ""
    @Published var details: String = ""
    @Published var isUploading: Bool = false

    @Published var shouldShowEditConfirmation: Bool = false
    @Published private(set) var endTimeErrorMessage: String?
    @Published var shouldShowSaveError: Bool = false

    var isSaveButtonEnabled: Bool {
        state == .data
        && !isUploading
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

    var frequencySelectionText: String {
        return frequency?.title ?? String(localized: "Does Not Repeat", bundle: .core)
    }

    var saveErrorAlert: ErrorAlertViewModel {
        .init(
            title: {
                switch mode {
                case .add: String(localized: "Creation not completed", bundle: .core)
                case .edit: String(localized: "Saving not completed", bundle: .core)
                }
            }(),
            message: {
                if let saveErrorMessageFromApi {
                    return saveErrorMessageFromApi
                }
                return switch mode {
                case .add: String(localized: "We couldn't add your Event at this time. You can try it again.", bundle: .core)
                case .edit: String(localized: "We couldn't save your Event at this time. You can try it again.", bundle: .core)
                }
            }(),
            buttonTitle: String(localized: "OK", bundle: .core)
        )
    }

    var editConfirmation = ConfirmationViewModel<SeriesModificationType>()

    // MARK: - Input

    let didTapCancel = PassthroughSubject<Void, Never>()
    let didTapSave = PassthroughSubject<Void, Never>()
    let showFrequencySelector = PassthroughSubject<WeakViewController, Never>()
    let showCalendarSelector = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    private let mode: Mode
    private let eventFrequencyPreset: FrequencyPreset?
    private let eventInteractor: CalendarEventInteractor
    private let calendarListProviderInteractor: CalendarFilterInteractor
    private let router: Router
    private var selectedCalendar = CurrentValueSubject<CDCalendarFilterEntry?, Never>(nil)
    /// Returns true if any of the fields had been modified once by the user. It doesn't compare values.
    private var isFieldsTouched: Bool = false
    private let isInitialEventPartOfSeries: Bool
    private var saveErrorMessageFromApi: String?

    private var subscriptions = Set<AnyCancellable>()

    internal lazy var selectCalendarViewModel: SelectCalendarViewModel = {
        return .init(
            calendarListProviderInteractor: calendarListProviderInteractor,
            calendarTypes: [.user, .group],
            selectedCalendar: selectedCalendar
        )
    }()

    // MARK: - Init

    init(
        event: CalendarEvent? = nil,
        selectedDate: Date? = nil,
        eventInteractor: CalendarEventInteractor,
        calendarListProviderInteractor: CalendarFilterInteractor,
        uploadParameters: RichContentEditorUploadParameters,
        router: Router,
        completion: @escaping (PlannerAssembly.Completion) -> Void
    ) {
        self.eventInteractor = eventInteractor
        self.eventFrequencyPreset = event?.frequencyPreset
        self.calendarListProviderInteractor = calendarListProviderInteractor
        self.uploadParameters = uploadParameters
        self.router = router

        if let event {
            mode = .edit(id: event.id)
            isInitialEventPartOfSeries = event.isPartOfSeries
            editConfirmation = makeEditConfirmation(event: event)
        } else {
            mode = .add
            isInitialEventPartOfSeries = false
        }

        setupFields(event: event, selectedDate: selectedDate ?? Clock.now)

        subscribeIsFieldsTouched(to: $title)
        subscribeIsFieldsTouched(to: $date)
        subscribeIsFieldsTouched(to: $isAllDay)
        subscribeIsFieldsTouched(to: $startTime)
        subscribeIsFieldsTouched(to: $endTime)
        subscribeIsFieldsTouched(to: $location)
        subscribeIsFieldsTouched(to: $address)
        subscribeIsFieldsTouched(to: $details)
        subscribeIsFieldsTouched(to: $frequency)

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

        $date
            .compactMap { $0 }
            .sink { [weak self] newDate in
                self?.resetFrequencySelection(given: newDate)
            }
            .store(in: &subscriptions)

        $startTime
            .sink { [weak self] newStartTime in self?.updateEndTimeError(newStartTime, self?.endTime) }
            .store(in: &subscriptions)

        $endTime
            .sink { [weak self] newEndTime in self?.updateEndTimeError(self?.startTime, newEndTime) }
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

        saveEventAfterConfirmation(on: didTapSave, completion: completion)

        showFrequencySelector
            .sink { [weak self] in self?.showSelectFrequencyScreen(from: $0) }
            .store(in: &subscriptions)

        showCalendarSelector
            .sink { [weak self] in self?.showSelectCalendarScreen(from: $0) }
            .store(in: &subscriptions)
    }

    // MARK: - Private methods

    private func setupFields(event: CalendarEvent?, selectedDate: Date) {
        title = event?.title ?? ""

        date = event?.startAt ?? selectedDate.startOfDay()
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
        frequency = event?.frequencySelection
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

    private func resetFrequencySelection(given newDate: Date) {
        guard let selection = frequency else { return }

        if case .custom(var rule) = selection.preset {

            switch rule.frequency {
            case .monthly:

                if rule.daysOfTheWeek == nil {
                    rule.daysOfTheMonth = [newDate.monthDay]
                } else {
                    rule.daysOfTheWeek = [newDate.monthWeekday]
                }

            case .yearly:

                rule.monthsOfTheYear = [newDate.month]
                rule.daysOfTheMonth = [newDate.monthDay]

            default: return
            }

            self.frequency = FrequencySelection(rule, preset: .custom(rule))

        } else if let newRule = selection.preset.rule(given: newDate) {

            self.frequency = FrequencySelection(newRule, preset: selection.preset)
        }
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
            EditEventFrequencyScreen(
                viewModel: EditEventFrequencyViewModel(
                    eventDate: date ?? Clock.now,
                    selectedFrequency: frequency,
                    originalPreset: eventFrequencyPreset,
                    router: router,
                    completion: { [weak self] newSelection in
                        self?.frequency = newSelection
                    }
                )
            )
        )
        vc.navigationItem.hidesBackButton = true
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
            contextCode: calendar.rawContextID,
            location: location.nilIfEmpty,
            address: address.nilIfEmpty,
            details: details.nilIfEmpty,
            rrule: frequency?.value
        )
    }

    private func makeEditConfirmation(event: CalendarEvent) -> ConfirmationViewModel<SeriesModificationType> {
        guard event.isPartOfSeries else { return .init() }

        return ConfirmationViewModel(
            title: String(localized: "Confirm Changes", bundle: .core),
            cancelButtonTitle: String(localized: "Cancel", bundle: .core),
            confirmButtons: [
                .init(
                    title: String(localized: "Change this event", bundle: .core),
                    option: .one
                ),
                .init(
                    title: String(localized: "Change all events", bundle: .core),
                    option: .all
                ),
                event.isSeriesHead ? nil : .init(
                    title: String(localized: "Change this and all following events", bundle: .core),
                    option: .following
                )
            ].compactMap { $0 }
        )
    }

    private func saveEventAfterConfirmation(
        on subject: PassthroughSubject<Void, Never>,
        completion: @escaping (PlannerAssembly.Completion) -> Void
    ) {
        subject
            .map { [weak self] in
                guard self?.isInitialEventPartOfSeries == true else { return }
                self?.shouldShowEditConfirmation = true
            }
            .flatMap { [weak self] () -> AnyPublisher<SeriesModificationType?, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                guard isInitialEventPartOfSeries else {
                    return Just(nil).eraseToAnyPublisher()
                }
                return editConfirmation.userConfirmsOption()
                    .map { $0 }
                    .eraseToAnyPublisher()
            }
            .map { [weak self] in
                self?.state = .data(loadingOverlay: true)
                return $0
            }
            .flatMap { [weak self] in
                (self?.saveAction(seriesModificationType: $0) ?? Empty().eraseToAnyPublisher())
                    .catch { error in
                        self?.saveErrorMessageFromApi = error.isBadRequest ? error.localizedDescription : nil
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
    }

    private func saveAction(seriesModificationType: SeriesModificationType?) -> AnyPublisher<Void, Error>? {
        guard let model else { return nil }

        switch mode {
        case .add:
            return eventInteractor.createEvent(model: model)
        case .edit(let id):
            return eventInteractor.updateEvent(id: id, model: model, seriesModificationType: seriesModificationType)
        }
    }
}
