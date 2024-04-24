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

    private let interactor: CalendarFilterInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: CalendarFilterInteractor) {
        self.interactor = interactor
        observeDataChanges()
        load(ignoreCache: false)
        forwardSelectionChangesToInteractor()
        forwardSelectAllActionsToInteractor()
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
            .load(ignoreCache: false)
            .sink { [weak self] completion in
                switch completion {
                case .finished: self?.state = .data
                case .failure: self?.state = .error
                }
                completionCallback?()
            } receiveValue: { _ in
            }
            .store(in: &subscriptions)
    }

    private func forwardSelectionChangesToInteractor() {
        didToggleSelection
            .sink { [weak interactor] (context, isSelected) in
                interactor?.updateFilteredContext(context, isSelected: isSelected)
            }
            .store(in: &subscriptions)
    }

    private func forwardSelectAllActionsToInteractor() {
        didTapRightNavButton
            .flatMap { [interactor] in
                interactor
                    .observeFilter()
                    .map(\.selectedContexts.isEmpty)
                    .first()
            }
            .sink { [interactor] isNothingSelected in
                if isNothingSelected {
                    interactor.selectAll()
                } else {
                    interactor.deselectAll()
                }
            }
            .store(in: &subscriptions)
    }

    private func observeDataChanges() {
        interactor
            .observeFilter()
            .map(\.selectedContexts)
            .assign(to: \.selectedContexts, on: self, ownership: .weak)
            .store(in: &subscriptions)

        interactor
            .observeFilter()
            .map(\.entries)
            .map { $0.first { $0.context.contextType == .user } }
            .assign(to: \.userFilter, on: self, ownership: .weak)
            .store(in: &subscriptions)

        interactor
            .observeFilter()
            .map { Array($0.entries) }
            .sink { [weak self] filterEntries in
                guard let self else { return }

                courseFilters = filterEntries
                    .filter { $0.context.contextType == .course }
                    .sorted()
                groupFilters = filterEntries
                    .filter { $0.context.contextType == .group }
                    .sorted()
            }
            .store(in: &subscriptions)

        interactor
            .observeFilter()
            .map {
                $0.selectedContexts.isEmpty ? String(localized: "Select all")
                                            : String(localized: "Deselect all")
            }
            .assign(to: \.rightNavButtonTitle, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }
}
