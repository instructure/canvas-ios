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

@Observable
final class WeeklySummaryWidgetViewModel: DashboardWidgetViewModel {
    typealias ViewType = WeeklySummaryWidgetView

    private(set) var state: InstUI.ScreenState = .loading
    let config: DashboardWidgetConfig
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

    var showMissingDueDivider: Bool { expandedFilter == nil || expandedFilter == newGradesFilter }
    var showDueNewGradesDivider: Bool { expandedFilter == nil || expandedFilter == missingFilter }

    // MARK: - Week Selection

    private(set) var weekStartDate: Date
    private(set) var weekRangeText: String
    let previousWeekA11yLabel = String(localized: "Previous week", bundle: .student)
    let nextWeekA11yLabel = String(localized: "Next week", bundle: .student)

    // MARK: - Init

    private let interactor: WeeklySummaryWidgetInteractor
    private let router: Router
    private var retrySubscription: AnyCancellable?

    init(
        config: DashboardWidgetConfig,
        interactor: WeeklySummaryWidgetInteractor = WeeklySummaryWidgetInteractorMock(),
        router: Router = AppEnvironment.shared.router
    ) {
        self.config = config
        self.interactor = interactor
        self.router = router
        let weekStartDate = Clock.now.startOfWeek()
        self.weekStartDate = weekStartDate
        self.weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
        self.missingFilter = .missing(assignments: [])
        self.dueFilter = .due(assignments: [])
        self.newGradesFilter = .newGrades(assignments: [])
    }

    func makeView() -> WeeklySummaryWidgetView {
        WeeklySummaryWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getSummary(ignoreCache: ignoreCache)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] filters in
                self?.missingFilter = .missing(assignments: filters.missing)
                self?.dueFilter = .due(assignments: filters.due)
                self?.newGradesFilter = .newGrades(assignments: filters.newGrades)
                self?.state = .data
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
    }

    func navigateToNextWeek() {
        weekStartDate = weekStartDate.addDays(7)
        weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
    }

    func toggleFilter(_ filter: WeeklySummaryWidgetFilterViewModel) {
        expandedFilter = (expandedFilter == filter) ? nil : filter
        missingFilter = missingFilter.withExpandedState(missingFilter == expandedFilter)
        dueFilter = dueFilter.withExpandedState(dueFilter == expandedFilter)
        newGradesFilter = newGradesFilter.withExpandedState(newGradesFilter == expandedFilter)
    }

    func didTapAssignment(_ assignment: WeeklySummaryWidgetAssignment, from controller: WeakViewController) {
        router.route(
            to: "/courses/\(assignment.courseId)/assignments/\(assignment.id)",
            from: controller,
            options: .modal(.fullScreen, isDismissable: false, embedInNav: true, addDoneButton: true, animated: true)
        )
    }

    // MARK: - Private

    private static func makeWeekRangeText(from weekStartDate: Date) -> String {
        let endDate = weekStartDate.addDays(6)
        let year = Calendar.current.component(.year, from: endDate)
        return "\(weekStartDate.shortDayMonth) - \(endDate.shortDayMonth) \(year)"
    }
}
