//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import CombineSchedulers
import Core
import Foundation
import SwiftUI

@Observable
final class WeeklySummaryWidgetViewModel: DashboardWidgetViewModel {
    let id: String = EditableWidgetIdentifier.weeklySummary.rawValue

    private(set) var state: InstUI.ScreenState = .loading
    private(set) var isWeekLoading: Bool = false
    private(set) var config: DashboardWidgetConfig
    let isEditable = false
    let isHiddenInEmptyState = false

    var layoutIdentifier: [AnyHashable] {
        [state, expandedFilter?.id ?? "", weekStartDate]
    }

    // MARK: - Filters

    private(set) var expandedFilter: WeeklySummaryWidgetFilterViewModel?
    private(set) var missingFilter: WeeklySummaryWidgetFilterViewModel
    private(set) var dueFilter: WeeklySummaryWidgetFilterViewModel
    private(set) var newGradesFilter: WeeklySummaryWidgetFilterViewModel

    private var isMissingFilterSelected: Bool { expandedFilter?.id == missingFilter.id }
    private var isDueFilterSelected: Bool { expandedFilter?.id == dueFilter.id }
    private var isNewGradesFilterSelected: Bool { expandedFilter?.id == newGradesFilter.id }

    var showMissingDueDivider: Bool { expandedFilter == nil || isNewGradesFilterSelected }
    var showDueNewGradesDivider: Bool { expandedFilter == nil || isMissingFilterSelected }

    private var isInitialLoad: Bool = true
    private var lastExpandedFilterIdBeforeLoad: String?

    // MARK: - Week Selection

    private(set) var weekStartDate: Date
    private(set) var weekRangeText: String
    let previousWeekA11yLabel = String(localized: "Previous week", bundle: .student)
    let nextWeekA11yLabel = String(localized: "Next week", bundle: .student)
    var isCurrentWeek: Bool { weekStartDate == Clock.now.startOfWeek() }
    var isFutureWeek: Bool { weekStartDate > Clock.now.startOfWeek() }

    // MARK: - Init

    private let interactor: WeeklySummaryWidgetInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let router: Router
    private var defaults: SessionDefaults
    private var retrySubscription: AnyCancellable?
    private var weekNavigationSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: WeeklySummaryWidgetInteractor = WeeklySummaryWidgetInteractorLive(),
        router: Router = AppEnvironment.shared.router,
        defaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.config = config
        self.interactor = interactor
        self.scheduler = scheduler
        self.router = router
        self.defaults = defaults
        let weekStartDate = Clock.now.startOfWeek()
        self.weekStartDate = weekStartDate
        self.weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
        self.missingFilter = .missing(assignments: [])
        self.dueFilter = .due(assignments: [])
        self.newGradesFilter = .newGrades(assignments: [])
        subscribeToSubmissionNotifications()
    }

    func makeView() -> AnyView {
        AnyView(WeeklySummaryWidgetView(viewModel: self))
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        let clearPublisher: AnyPublisher<Void, Never>
        if ignoreCache {
            clearPublisher = interactor.clearCache()
        } else {
            clearPublisher = Just(()).eraseToAnyPublisher()
        }

        return clearPublisher
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _ -> AnyPublisher<WeeklySummaryWidgetFilters, Error> in
                guard let self else { return Fail(error: NSError.internalError()).eraseToAnyPublisher() }
                return interactor.getSummary(weekStart: weekStartDate, ignoreCache: ignoreCache)
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] filters in
                guard let self else { return }
                updateFilters(filters)
                state = .data
            })
            .map { _ in }
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    func retryRefresh() {
        weekNavigationSubscription?.cancel()
        state = .loading
        missingFilter = .missing(assignments: [])
        dueFilter = .due(assignments: [])
        newGradesFilter = .newGrades(assignments: [])
        collapseFiltersBeforeLoad()
        weekStartDate = Clock.now.startOfWeek()
        weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
        retrySubscription = refresh(ignoreCache: true).sink { _ in }
    }

    // MARK: - User Actions

    func navigateToCurrentWeek() {
        weekStartDate = Clock.now.startOfWeek()
        weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
        beginWeekTransition()
    }

    func navigateToPreviousWeek() {
        weekStartDate = weekStartDate.addDays(-7)
        weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
        beginWeekTransition()
    }

    func navigateToNextWeek() {
        weekStartDate = weekStartDate.addDays(7)
        weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
        beginWeekTransition()
    }

    func toggleFilter(_ filter: WeeklySummaryWidgetFilterViewModel) {
        expandedFilter = (expandedFilter?.id == filter.id) ? nil : filter
        config.weeklySummarySettings = WeeklySummaryWidgetSettings(expandedFilterId: expandedFilter?.id)
        persistConfig()
        missingFilter = missingFilter.withExpandedState(isMissingFilterSelected)
        dueFilter = dueFilter.withExpandedState(isDueFilterSelected)
        newGradesFilter = newGradesFilter.withExpandedState(isNewGradesFilterSelected)
    }

    func didTapAssignment(_ assignment: WeeklySummaryWidgetAssignment, from controller: WeakViewController) {
        router.route(
            to: "/courses/\(assignment.courseId)/assignments/\(assignment.routeAssignmentId)",
            from: controller,
            options: .modal(.fullScreen, isDismissable: false, embedInNav: true, addDoneButton: true, animated: true)
        )
    }

    // MARK: Private

    private func beginWeekTransition() {
        weekNavigationSubscription?.cancel()
        weekNavigationSubscription = Just(())
            // Debounce rapid week-navigation taps so we only fetch once the user settles on a week.
            .delay(for: .milliseconds(300), scheduler: scheduler)
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else { return Just(false).eraseToAnyPublisher() }
                return interactor.hasCachedSummary(weekStart: weekStartDate)
            }
            .receive(on: scheduler)
            .setFailureType(to: Error.self)
            .flatMap { [weak self] hasCachedData -> AnyPublisher<WeeklySummaryWidgetFilters, Error> in
                guard let self else { return Fail(error: NSError.internalError()).eraseToAnyPublisher() }
                if !hasCachedData {
                    collapseFiltersBeforeLoad()
                    isWeekLoading = true
                }
                return interactor.getSummary(weekStart: weekStartDate, ignoreCache: false)
                    .receive(on: scheduler)
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] _ in self?.isWeekLoading = false },
                receiveValue: { [weak self] filters in
                    guard let self else { return }
                    updateFilters(filters)
                }
            )
    }

    // MARK: - Refresh On Submission

    private func subscribeToSubmissionNotifications() {
        NotificationCenter.default
            .publisher(for: .CompletedModuleItemRequirement)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard
                    let self,
                    let payload = notification.moduleItemCompletionPayload,
                    payload.requirement == .submit
                else { return }

                let submittedId: String
                switch payload.moduleItem {
                case .assignment(let id), .quiz(let id), .discussion(let id):
                    submittedId = id
                default:
                    return
                }

                let knownIds = Set(
                    (missingFilter.assignments + dueFilter.assignments + newGradesFilter.assignments)
                        .map(\.id)
                )
                guard knownIds.contains(submittedId) else { return }
                reloadCurrentWeek()
            }
            .store(in: &subscriptions)
    }

    private func reloadCurrentWeek() {
        weekNavigationSubscription?.cancel()
        weekNavigationSubscription = interactor.clearCache()
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _ -> AnyPublisher<WeeklySummaryWidgetFilters, Error> in
                guard let self else { return Fail(error: NSError.internalError()).eraseToAnyPublisher() }
                return interactor.getSummary(weekStart: weekStartDate, ignoreCache: false)
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] filters in
                    self?.updateFilters(filters)
                }
            )
    }

    // MARK: - Private Helpers

    private func collapseFiltersBeforeLoad() {
        lastExpandedFilterIdBeforeLoad = expandedFilter?.id
        expandedFilter = nil
        missingFilter = missingFilter.withExpandedState(false)
        dueFilter = dueFilter.withExpandedState(false)
        newGradesFilter = newGradesFilter.withExpandedState(false)
    }

    private func persistConfig() {
        var configs = defaults.learnerDashboardWidgetConfigs ?? EditableWidgetIdentifier.makeDefaultConfigs()
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
            defaults.learnerDashboardWidgetConfigs = configs
        }
    }

    private func updateFilters(_ filters: WeeklySummaryWidgetFilters, isInitialUpdate: Bool = false) {
        let isMissingSelected: Bool
        let isDueSelected: Bool
        let isNewGradesSelected: Bool

        if isInitialLoad {
            isInitialLoad = false

            isMissingSelected = filters.missing.isNotEmpty
            isDueSelected = false
            isNewGradesSelected = false
        } else if let lastSelectedId = lastExpandedFilterIdBeforeLoad {
            lastExpandedFilterIdBeforeLoad = nil
            isMissingSelected = lastSelectedId == WeeklySummaryWidgetFilterViewModel.missingId
            isDueSelected = lastSelectedId == WeeklySummaryWidgetFilterViewModel.dueId
            isNewGradesSelected = lastSelectedId == WeeklySummaryWidgetFilterViewModel.newGradesId
        } else {
            isMissingSelected = isMissingFilterSelected
            isDueSelected = isDueFilterSelected
            isNewGradesSelected = isNewGradesFilterSelected
        }

        // Each reload creates new filter value types, so we must carry over the expanded
        // state explicitly. expandedFilter also holds a copy of the old instance, so it
        // must be reassigned to the freshly created one — otherwise it stays out of sync
        // with the named filter properties and the UI stops reflecting the correct state.
        missingFilter = .missing(assignments: filters.missing).withExpandedState(isMissingSelected)
        dueFilter = .due(assignments: filters.due).withExpandedState(isDueSelected)
        newGradesFilter = .newGrades(assignments: filters.newGrades).withExpandedState(isNewGradesSelected)

        // If one of the filters is already expanded -> reassign the new filter
        if isMissingSelected {
            expandedFilter = missingFilter
        } else if isDueSelected {
            expandedFilter = dueFilter
        } else if isNewGradesSelected {
            expandedFilter = newGradesFilter
        } else {
            expandedFilter = nil
        }
    }

    private static func makeWeekRangeText(from weekStartDate: Date) -> String {
        let endDate = weekStartDate.addDays(6)
        let currentYear = Calendar.current.component(.year, from: Clock.now)
        let endYear = Calendar.current.component(.year, from: endDate)
        if endYear == currentYear {
            return "\(weekStartDate.shortDayMonth) - \(endDate.shortDayMonth)"
        } else {
            let startYear = Calendar.current.component(.year, from: weekStartDate)
            return "\(weekStartDate.shortDayMonth), \(startYear) - \(endDate.shortDayMonth), \(endYear)"
        }
    }
}

private extension Notification {
    typealias ModuleItemCompletionPayload = (requirement: ModuleItemCompletionRequirement, moduleItem: ModuleItemType)

    var moduleItemCompletionPayload: ModuleItemCompletionPayload? {
        guard
            let requirement = userInfo?["requirement"] as? ModuleItemCompletionRequirement,
            let moduleItem = userInfo?["moduleItem"] as? ModuleItemType
        else { return nil }
        return (requirement, moduleItem)
    }
}
