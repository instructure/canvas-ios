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

public class CalendarFilterViewModel: ObservableObject {
    // MARK: - Outputs
    @Published public private(set) var state: InstUI.ScreenState = .loading
    @Published public private(set) var userFilter: CDCalendarFilterEntry?
    @Published public private(set) var courseFilters: [CDCalendarFilterEntry] = []
    @Published public private(set) var groupFilters: [CDCalendarFilterEntry] = []
    @Published public private(set) var selectedContexts = Set<Context>()
    @Published public private(set) var rightNavButtonTitle = ""
    public let pageTitle = String(localized: "Calendars")
    public let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/filter")

    // MARK: - Inputs
    public let didToggleSelection = PassthroughSubject<(context: Context, isSelected: Bool), Never>()
    public let didTapRightNavButton = PassthroughSubject<Void, Never>()
    public let didTapDoneButton = PassthroughSubject<UIViewController, Never>()

    private let interactor: CalendarFilterInteractor
    private let router: Router
    private let didDismissPicker: () -> Void
    private var subscriptions = Set<AnyCancellable>()

    public init(
        interactor: CalendarFilterInteractor,
        router: Router = AppEnvironment.shared.router,
        didDismissPicker: @escaping () -> Void
    ) {
        self.interactor = interactor
        self.router = router
        self.didDismissPicker = didDismissPicker
        observeDataChanges()
        load(ignoreCache: false)
        forwardSelectionChangesToInteractor()
        handleSelectAllActions()
        handleDoneButtonTap()
    }

    public func refresh(completion: @escaping () -> Void) {
        load(ignoreCache: true, completionCallback: completion)
    }

    // MARK: - Private Methods

    private func load(
        ignoreCache: Bool,
        completionCallback: (() -> Void)? = nil
    ) {
        interactor
            .loadFilters(ignoreCache: ignoreCache)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    // In this case the stream completed without publishing
                    if self.state == .loading {
                        self.state = .empty
                    }
                case .failure:
                    self.state = .error
                }
                completionCallback?()
            } receiveValue: { [weak self] filters in
                guard let self else { return }
                let containsUserFilter = filters.contains { $0.context.contextType == .user }

                if filters.isEmpty || (filters.count == 1 && containsUserFilter) {
                    state = .empty
                } else {
                    state = .data
                    userFilter = filters.first { $0.context.contextType == .user }
                    courseFilters = filters
                        .filter { $0.context.contextType == .course }
                        .sorted()
                    groupFilters = filters
                        .filter { $0.context.contextType == .group }
                        .sorted()
                }
            }
            .store(in: &subscriptions)
    }

    private func forwardSelectionChangesToInteractor() {
        didToggleSelection
            .sink { [weak interactor] (context, isSelected) in
                interactor?.updateFilteredContexts([context], isSelected: isSelected)
            }
            .store(in: &subscriptions)
    }

    private func handleSelectAllActions() {
        didTapRightNavButton
            .compactMap { [weak self] _ -> ([Context], Bool)? in
                guard let self else { return nil }

                var allContexts = courseFilters.map { $0.context }
                allContexts.append(contentsOf: groupFilters.map { $0.context })
                allContexts.appendUnwrapped(userFilter?.context)
                return (allContexts, selectedContexts.isEmpty)
            }
            .sink { [interactor] (contexts, isSelect) in
                interactor.updateFilteredContexts(contexts, isSelected: isSelect)
            }
            .store(in: &subscriptions)
    }

    private func handleDoneButtonTap() {
        didTapDoneButton
            .sink { [router, didDismissPicker] host in
                router.dismiss(host, completion: didDismissPicker)
            }
            .store(in: &subscriptions)
    }

    private func observeDataChanges() {
        interactor
            .observeSelectedContexts()
            .assign(to: \.selectedContexts, on: self, ownership: .weak)
            .store(in: &subscriptions)

        interactor
            .observeSelectedContexts()
            .map {
                $0.isEmpty ? String(localized: "Select all")
                           : String(localized: "Deselect all")
            }
            .assign(to: \.rightNavButtonTitle, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }
}
