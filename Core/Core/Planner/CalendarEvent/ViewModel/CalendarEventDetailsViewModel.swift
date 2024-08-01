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

public final class CalendarEventDetailsViewModel: ObservableObject {
    public typealias SeriesModificationType = APICalendarEventSeriesModificationType

    // MARK: Output

    public let pageTitle = String(localized: "Event Details", bundle: .core)
    public let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar")

    @Published public private(set) var pageSubtitle: String?
    @Published public private(set) var contextColor: UIColor?
    @Published public private(set) var state: InstUI.ScreenState = .loading
    @Published public private(set) var title: String = ""
    @Published public private(set) var date: String?
    @Published public private(set) var locationInfo: [InstUI.TextSectionView.Model] = []
    @Published public private(set) var details: InstUI.TextSectionView.Model?
    @Published public var shouldShowMenuButton: Bool = false
    @Published public var shouldShowDeleteConfirmation: Bool = false
    @Published public var shouldShowDeleteError: Bool = false

    public var isMoreButtonEnabled: Bool {
        state == .data
    }

    public var deleteConfirmation: ConfirmationViewModel<SeriesModificationType>

    // MARK: - Input

    let didTapEdit = PassthroughSubject<WeakViewController, Never>()
    let didTapDelete = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    private let eventId: String
    private let interactor: CalendarEventInteractor
    private let router: Router
    private let completion: ((PlannerAssembly.Completion) -> Void)?
    private var subscriptions = Set<AnyCancellable>()

    private var event = CurrentValueSubject<CalendarEvent?, Never>(nil)

    // MARK: - Init

    public init(
        eventId: String,
        interactor: CalendarEventInteractor,
        router: Router,
        completion: ((PlannerAssembly.Completion) -> Void)?
    ) {
        self.eventId = eventId
        self.interactor = interactor
        self.router = router
        self.completion = completion
        self.deleteConfirmation = deleteSingleItemConfirmation

        event
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self else { return }
                deleteConfirmation = makeDeleteConfirmation(event: $0)
            }
            .store(in: &subscriptions)

        event
            .compactMap { $0 }
            .flatMap { [weak self] in
                return self?.canManageEvent(context: $0.context) ?? Empty().eraseToAnyPublisher()
            }
            .sink { [weak self] in
                self?.shouldShowMenuButton = $0
            }
            .store(in: &subscriptions)

        loadData()

        didTapEdit
            .sink { [weak self] in self?.showEditScreen(from: $0) }
            .store(in: &subscriptions)

        didTapDelete
            .map { [weak self] in
                self?.shouldShowDeleteConfirmation = true
                return $0
            }
            .flatMap { [weak self] in
                self?.deleteConfirmation.userConfirmsOption(passdownValue: $0)
                    ?? Empty().eraseToAnyPublisher()
            }
            .sink { [weak self] in self?.deleteToDo(option: $0.0, from: $0.1) }
            .store(in: &subscriptions)
    }

    // MARK: - Load

    public func reload(completion: @escaping () -> Void) {
        loadData(
            refreshCompletion: completion,
            ignoreCache: true
        )
    }

    private func loadData(
        refreshCompletion: (() -> Void)? = nil,
        ignoreCache: Bool = false
    ) {
        interactor
            .getCalendarEvent(id: eventId, ignoreCache: ignoreCache)
            .sink { [weak self] completion in
                guard let self else { return }
                refreshCompletion?()
                switch completion {
                case .finished: state = .data
                case .failure: state = .error
                }
            } receiveValue: { [weak self] (event, contextColor) in
                guard let self else { return }

                self.event.value = event
                self.contextColor = contextColor
                title = event.title
                pageSubtitle = event.contextName

                if event.isAllDay {
                    date = event.startAt?.dateOnlyString
                } else if let start = event.startAt, let end = event.endAt {
                    date = start.intervalStringTo(end)
                } else {
                    date = event.startAt?.dateTimeString
                }

                if let seriesInfo = event.seriesInNaturalLanguage {
                    date?.append("\n\(String(localized: "Repeats", bundle: .core)) \(seriesInfo)")
                } else {
                    date?.append("\n\(String(localized: "Does Not Repeat", bundle: .core))")
                }

                locationInfo = {
                    var result: [InstUI.TextSectionView.Model] = []
                    if let locationName = event.locationName, locationName.isNotEmpty {
                        result.append(.init(
                            title: String(localized: "Location", bundle: .core),
                            description: locationName)
                        )
                    }
                    if let address = event.locationAddress, address.isNotEmpty {
                        result.append(.init(
                            title: String(localized: "Address", bundle: .core),
                            description: address)
                        )
                    }
                    return result
                }()

                if let details = event.details {
                    self.details = .init(
                        title: String(localized: "Details", bundle: .core),
                        description: details,
                        isRichContent: true
                    )
                }
            }
            .store(in: &subscriptions)
    }

    private func canManageEvent(context: Context) -> AnyPublisher<Bool, Never> {
        // TODO: inject
        let currentUserid = AppEnvironment.shared.currentSession?.actAsUserID ?? AppEnvironment.shared.currentSession?.userID ?? ""

        return switch context.contextType {
        case .user:
            Just(context.id == currentUserid).eraseToAnyPublisher()
        case .course, .group:
            interactor.getManageCalendarPermission(context: context, ignoreCache: true)
                .catch { _ in
                    return Just(false).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        default:
            Just(false).eraseToAnyPublisher()
        }
    }

    // MARK: - Private methods

    private func showEditScreen(from source: WeakViewController) {
        guard let event = event.value else { return }

        let weakVC = WeakViewController()
        let vc = PlannerAssembly.makeEditEventViewController(event: event) { [weak self] output in
            if output == .didUpdate {
                self?.loadData(ignoreCache: false)
                self?.completion?(.didUpdate)
            }
            self?.router.dismiss(weakVC)
        }
        weakVC.setValue(vc)

        router.show(vc, from: source, options: .modal(isDismissable: false, embedInNav: true))
    }

    private let deleteSingleItemConfirmation = ConfirmationViewModel(
        title: String(localized: "Delete Event?", bundle: .core),
        message: String(localized: "This will permanently delete your Event.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Delete", bundle: .core),
        isDestructive: true,
        confirmValue: SeriesModificationType.one
    )

    private func makeDeleteConfirmation(event: CalendarEvent) -> ConfirmationViewModel<SeriesModificationType> {
        if event.isPartOfSeries {
            ConfirmationViewModel(
                title: String(localized: "Confirm Deletion", bundle: .core),
                cancelButtonTitle: String(localized: "Cancel", bundle: .core),
                confirmButtons: [
                    .init(
                        title: String(localized: "Delete this event", bundle: .core),
                        isDestructive: true,
                        option: .one
                    ),
                    .init(
                        title: String(localized: "Delete all events", bundle: .core),
                        isDestructive: true,
                        option: .all
                    ),
                    event.isSeriesHead ? nil : .init(
                        title: String(localized: "Delete this and all following events", bundle: .core),
                        isDestructive: true,
                        option: .following
                    )
                ].compactMap { $0 }
            )
        } else {
            deleteSingleItemConfirmation
        }
    }

    private func deleteToDo(option: SeriesModificationType, from source: WeakViewController) {
        state = .data(loadingOverlay: true)

        interactor.deleteEvent(id: eventId, seriesModificationType: option)
            .sink(
                receiveCompletion: { [weak self] in
                    switch $0 {
                    case .finished:
                        break
                    case .failure:
                        self?.state = .data
                        self?.shouldShowDeleteError = true
                    }
                },
                receiveValue: { [weak self] in
                    self?.completion?(.didDelete)
                    self?.router.pop(from: source)
                }
            )
            .store(in: &subscriptions)
    }
}
