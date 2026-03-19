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

    // MARK: - Week Selection

    private(set) var weekStartDate: Date
    private(set) var weekRangeText: String
    let previousWeekA11yLabel = String(localized: "Previous week", bundle: .student)
    let nextWeekA11yLabel = String(localized: "Next week", bundle: .student)

    // MARK: - Init

    private let interactor: WeeklySummaryWidgetInteractor
    private let router: Router
    private var defaults: SessionDefaults
    private var retrySubscription: AnyCancellable?
    private var weekNavigationSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    init(
        config: DashboardWidgetConfig,
        interactor: WeeklySummaryWidgetInteractor = WeeklySummaryWidgetInteractorLive(),
        router: Router = AppEnvironment.shared.router,
        defaults: SessionDefaults = AppEnvironment.shared.userDefaults ?? .fallback
    ) {
        self.config = config
        self.interactor = interactor
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
            weekNavigationSubscription?.cancel()
            state = .loading
            missingFilter = .missing(assignments: [])
            dueFilter = .due(assignments: [])
            newGradesFilter = .newGrades(assignments: [])
            expandedFilter = nil
            weekStartDate = Clock.now.startOfWeek()
            weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
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
                missingFilter = .missing(assignments: filters.missing)
                dueFilter = .due(assignments: filters.due)
                newGradesFilter = .newGrades(assignments: filters.newGrades)
                state = .data
                selectDefaultFilter()
            })
            .map { _ in }
            .catch { [weak self] _ in
                self?.state = .error
                return Just(())
            }
            .eraseToAnyPublisher()
    }

    func retryRefresh() {
        state = .loading
        retrySubscription = refresh(ignoreCache: true).sink { _ in }
    }

    // MARK: - User Actions

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
            to: "/courses/\(assignment.courseId)/assignments/\(assignment.id)",
            from: controller,
            options: .modal(.fullScreen, isDismissable: false, embedInNav: true, addDoneButton: true, animated: true)
        )
    }

    // MARK: Private

    private func beginWeekTransition() {
        weekNavigationSubscription?.cancel()
        weekNavigationSubscription = Just(())
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else { return Just(false).eraseToAnyPublisher() }
                return interactor.hasCachedSummary(weekStart: weekStartDate)
            }
            .receive(on: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .flatMap { [weak self] hasCachedData -> AnyPublisher<WeeklySummaryWidgetFilters, Error> in
                guard let self else { return Fail(error: NSError.internalError()).eraseToAnyPublisher() }
                if !hasCachedData {
                    expandedFilter = nil
                    missingFilter = missingFilter.withExpandedState(false)
                    dueFilter = dueFilter.withExpandedState(false)
                    newGradesFilter = newGradesFilter.withExpandedState(false)
                    isWeekLoading = true
                }
                return interactor.getSummary(weekStart: weekStartDate, ignoreCache: false)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] _ in self?.isWeekLoading = false },
                receiveValue: { [weak self] filters in
                    self?.updateFilters(filters)
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

    private func expandFilter(_ filter: WeeklySummaryWidgetFilterViewModel) {
        expandedFilter = filter
        missingFilter = missingFilter.withExpandedState(isMissingFilterSelected)
        dueFilter = dueFilter.withExpandedState(isDueFilterSelected)
        newGradesFilter = newGradesFilter.withExpandedState(isNewGradesFilterSelected)
    }

    private func selectDefaultFilter() {
        guard expandedFilter == nil else { return }

        let filterToRestore = [missingFilter, dueFilter, newGradesFilter]
            .first { $0.id == self.config.weeklySummarySettings.expandedFilterId }

        if let filterToRestore {
            expandFilter(filterToRestore)
        } else if missingFilter.count != 0 {
            expandFilter(missingFilter)
        }
    }

    private func persistConfig() {
        var configs = defaults.learnerDashboardWidgetConfigs ?? EditableWidgetIdentifier.makeDefaultConfigs()
        if let index = configs.firstIndex(where: { $0.id == config.id }) {
            configs[index] = config
            defaults.learnerDashboardWidgetConfigs = configs
        }
    }

    private func updateFilters(_ filters: WeeklySummaryWidgetFilters) {
        // Each reload creates new filter value types, so we must carry over the expanded
        // state explicitly. expandedFilter also holds a copy of the old instance, so it
        // must be reassigned to the freshly created one — otherwise it stays out of sync
        // with the named filter properties and the UI stops reflecting the correct state.
        missingFilter = .missing(assignments: filters.missing).withExpandedState(isMissingFilterSelected)
        dueFilter = .due(assignments: filters.due).withExpandedState(isDueFilterSelected)
        newGradesFilter = .newGrades(assignments: filters.newGrades).withExpandedState(isNewGradesFilterSelected)
        if isMissingFilterSelected {
            expandedFilter = missingFilter
        } else if isDueFilterSelected {
            expandedFilter = dueFilter
        } else if isNewGradesFilterSelected {
            expandedFilter = newGradesFilter
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
