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
    @Published public private(set) var selectAllButtonTitle: String?
    @Published public private(set) var filterLimitMessage: String?
    public let pageTitle = String(localized: "Calendars", bundle: .core)
    public let pageViewEvent = ScreenViewTrackingParameters(eventName: "/calendar/filter")
    public let snackbarViewModel = SnackBarViewModel()

    // MARK: - Inputs
    public let didToggleSelection = PassthroughSubject<(context: Context, isSelected: Bool), Never>()
    public let didTapSelectAllButton = PassthroughSubject<Void, Never>()
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
            .load(ignoreCache: ignoreCache)
            .sink { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    state = interactor.filters.value.isEmpty ? .empty : .data
                case .failure:
                    state = .error
                }
                completionCallback?()
            } receiveValue: {}
            .store(in: &subscriptions)
    }

    private func forwardSelectionChangesToInteractor() {
        didToggleSelection
            .flatMap { [interactor, snackbarViewModel] (context, isSelected) in
                interactor
                    .updateFilteredContexts([context], isSelected: isSelected)
                    .catch { _ in
                        let limit = interactor.filterCountLimit.value.rawValue
                        return snackbarViewModel.showFilterLimitReachedMessage(limit: limit)
                    }
            }
            .sink()
            .store(in: &subscriptions)
    }

    private func handleSelectAllActions() {
        didTapSelectAllButton
            .compactMap { [weak self] _ -> ([Context], Bool)? in
                guard let self else { return nil }

                var allContexts = courseFilters.map { $0.context }
                allContexts.append(contentsOf: groupFilters.map { $0.context })
                allContexts.appendUnwrapped(userFilter?.context)
                return (allContexts, selectedContexts.isEmpty)
            }
            .flatMap { [interactor] (contexts, isSelect) in
                interactor
                    .updateFilteredContexts(contexts, isSelected: isSelect)
                    .mapToValue(isSelect)
            }
            .sink(receiveCompletion: { _ in
                // There's no select all button when filter limit is available
                // so the stream shouldn't fail bacause we reached the limit
            }, receiveValue: { isSelected in
                let announcement = isSelected ? String(localized: "All calendars selected", bundle: .core)
                                              : String(localized: "All calendars deselected", bundle: .core)
                UIAccessibility.announce(announcement)
            })
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
            .selectedContexts
            .assign(to: \.selectedContexts, on: self, ownership: .weak)
            .store(in: &subscriptions)

        Publishers.CombineLatest(
            interactor.selectedContexts,
            interactor.filterCountLimit
        )
            .map { (selectedContexts, filterCountLimit) in
                if filterCountLimit != .unlimited, selectedContexts.isEmpty {
                    return nil
                }

                return selectedContexts.isEmpty ? String(localized: "Select all", bundle: .core)
                                                : String(localized: "Deselect all", bundle: .core)
            }
            .assign(to: \.selectAllButtonTitle, on: self, ownership: .weak)
            .store(in: &subscriptions)

        interactor
            .filterCountLimit
            .map { limit -> String? in
                switch limit {
                case .base, .extended:
                    return String(localized: "Select the calendars you want to see, up to \(limit.rawValue).", bundle: .core)
                case .unlimited:
                    return nil
                }
            }
            .assign(to: \.filterLimitMessage, on: self, ownership: .weak)
            .store(in: &subscriptions)

        interactor
            .filters
            .sink { [weak self] filters in
                guard let self else { return }

                userFilter = filters.first { $0.context.contextType == .user }
                courseFilters = filters
                    .filter { $0.context.contextType == .course }
                    .sorted()
                groupFilters = filters
                    .filter { $0.context.contextType == .group }
                    .sorted()
            }
            .store(in: &subscriptions)
    }
}

private extension SnackBarViewModel {

    func showFilterLimitReachedMessage(limit: Int) -> Future<Void, Never> {
        Future { [weak self] promise in
            let message = String(localized: "You can only select up to \(limit) calendars.", bundle: .core)
            self?.showSnack(message, swallowDuplicatedSnacks: true)
            promise(.success(()))
        }
    }
}
