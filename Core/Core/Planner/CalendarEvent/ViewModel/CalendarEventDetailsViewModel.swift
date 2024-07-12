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

public class CalendarEventDetailsViewModel: ObservableObject {

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
    @Published public var shouldShowDeleteConfirmation: Bool = false
    @Published public var shouldShowDeleteError: Bool = false

    var isMoreButtonEnabled: Bool {
        state == .data
    }

    public let deleteConfirmationAlert = ConfirmationAlertViewModel(
        title: String(localized: "Delete Event?", bundle: .core),
        message: String(localized: "This will permanently delete your Event.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Delete", bundle: .core),
        isDestructive: true
    )

    // MARK: - Input

    let didTapEdit = PassthroughSubject<WeakViewController, Never>()
    let didTapDelete = PassthroughSubject<WeakViewController, Never>()

    // MARK: - Private

    private let interactor: CalendarEventDetailsInteractor
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(interactor: CalendarEventDetailsInteractor, router: Router) {
        self.interactor = interactor
        self.router = router

        loadData()

        didTapEdit
            .sink { [weak self] in self?.showEditScreen(from: $0) }
            .store(in: &subscriptions)

        didTapDelete
            .map { [weak self] in
                self?.shouldShowDeleteConfirmation = true
                return $0
            }
            .flatMap { [deleteConfirmationAlert] in
                deleteConfirmationAlert.userConfirmation(value: $0)
            }
            .sink { [weak self] in self?.deleteToDo(from: $0) }
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
            .getCalendarEvent(ignoreCache: ignoreCache)
            .sink { [weak self] completion in
                guard let self else { return }
                refreshCompletion?()
                switch completion {
                case .finished: state = .data
                case .failure: state = .error
                }
            } receiveValue: { [weak self] (event, contextColor) in
                guard let self else { return }
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

    // MARK: - Private methods

    private func showEditScreen(from source: WeakViewController) {
    }

    private func deleteToDo(from source: WeakViewController) {
    }
}
