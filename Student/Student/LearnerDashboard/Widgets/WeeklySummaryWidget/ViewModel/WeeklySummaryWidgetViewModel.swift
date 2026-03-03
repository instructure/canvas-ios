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

    private(set) var state: InstUI.ScreenState = .data
    let config: DashboardWidgetConfig
    let isEditable = false
    let isHiddenInEmptyState = false

    var layoutIdentifier: [AnyHashable] {
        [state, expandedFilter?.id ?? "", weekStartDate]
    }

    // MARK: - Filters

    private(set) var expandedFilter: WeeklySummaryFilterViewModel?
    private(set) var missingFilter: WeeklySummaryFilterViewModel
    private(set) var dueFilter: WeeklySummaryFilterViewModel
    private(set) var newGradesFilter: WeeklySummaryFilterViewModel

    // MARK: - Week Selection

    private(set) var weekStartDate: Date
    private(set) var weekRangeText: String
    let previousWeekA11yLabel = String(localized: "Previous week", bundle: .student)
    let nextWeekA11yLabel = String(localized: "Next week", bundle: .student)

    // MARK: - Init

    private let router: Router

    init(config: DashboardWidgetConfig, router: Router = AppEnvironment.shared.router) {
        self.config = config
        self.router = router
        let weekStartDate = Self.mondayOfCurrentWeek()
        self.weekStartDate = weekStartDate
        self.weekRangeText = Self.makeWeekRangeText(from: weekStartDate)
        let mockData = WeeklySummaryWidgetInteractorMock.makeFilters()
        self.missingFilter = mockData.missing
        self.dueFilter = mockData.due
        self.newGradesFilter = mockData.newGrades
    }

    func makeView() -> WeeklySummaryWidgetView {
        WeeklySummaryWidgetView(viewModel: self)
    }

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
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

    func toggleFilter(_ filter: WeeklySummaryFilterViewModel) {
        expandedFilter = (expandedFilter == filter) ? nil : filter
        missingFilter = missingFilter.withExpandedState(missingFilter == expandedFilter)
        dueFilter = dueFilter.withExpandedState(dueFilter == expandedFilter)
        newGradesFilter = newGradesFilter.withExpandedState(newGradesFilter == expandedFilter)
    }

    func didTapAssignment(_ assignment: WeeklySummaryAssignment, from controller: WeakViewController) {
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

    private static func mondayOfCurrentWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date.now)
        return calendar.date(from: components) ?? Date.now
    }
}
