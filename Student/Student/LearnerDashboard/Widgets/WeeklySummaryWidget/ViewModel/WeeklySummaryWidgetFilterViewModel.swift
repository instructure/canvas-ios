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

import Core
import Foundation

// MARK: - Filter Entity

struct WeeklySummaryWidgetFilterViewModel: Identifiable, Equatable {
    let id: String
    let label: String
    let assignments: [WeeklySummaryWidgetAssignment]
    let emptyStateText: String
    let emptyStateIconName: String
    let accessibilityLabel: String
    var accessibilityValue: String
    var accessibilityHint: String

    var count: Int { assignments.count }

    func withExpandedState(_ isExpanded: Bool) -> WeeklySummaryWidgetFilterViewModel {
        var copy = self
        let state = InstUI.CollapseButtonExpandedState(isExpanded: isExpanded)
        copy.accessibilityValue = state.a11yValue
        copy.accessibilityHint = state.a11yHint
        return copy
    }

    static func == (lhs: WeeklySummaryWidgetFilterViewModel, rhs: WeeklySummaryWidgetFilterViewModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Filter Factories

extension WeeklySummaryWidgetFilterViewModel {
    static func missing(assignments: [WeeklySummaryWidgetAssignment]) -> WeeklySummaryWidgetFilterViewModel {
        let count = assignments.count
        let expandedState = InstUI.CollapseButtonExpandedState(isExpanded: false)
        return WeeklySummaryWidgetFilterViewModel(
            id: "missing",
            label: String(localized: "Missing", bundle: .student),
            assignments: assignments,
            emptyStateText: String(localized: "Nothing overdue — you're on top of it!", bundle: .student),
            emptyStateIconName: "PandaSuper",
            accessibilityLabel: count == 0
                ? String(localized: "No missing submissions", bundle: .student)
                : String(localized: "\(count) missing submissions", bundle: .student),
            accessibilityValue: expandedState.a11yValue,
            accessibilityHint: expandedState.a11yHint
        )
    }

    static func due(assignments: [WeeklySummaryWidgetAssignment]) -> WeeklySummaryWidgetFilterViewModel {
        let count = assignments.count
        let expandedState = InstUI.CollapseButtonExpandedState(isExpanded: false)
        return WeeklySummaryWidgetFilterViewModel(
            id: "due",
            label: String(localized: "Due", bundle: .student),
            assignments: assignments,
            emptyStateText: String(localized: "No deadlines this week — enjoy the calm!", bundle: .student),
            emptyStateIconName: "PandaNoEvents",
            accessibilityLabel: count == 0
                ? String(localized: "No due submissions", bundle: .student)
                : String(localized: "\(count) due submissions", bundle: .student),
            accessibilityValue: expandedState.a11yValue,
            accessibilityHint: expandedState.a11yHint
        )
    }

    static func newGrades(assignments: [WeeklySummaryWidgetAssignment]) -> WeeklySummaryWidgetFilterViewModel {
        let count = assignments.count
        let expandedState = InstUI.CollapseButtonExpandedState(isExpanded: false)
        return WeeklySummaryWidgetFilterViewModel(
            id: "newGrades",
            label: String(localized: "New Grades", bundle: .student),
            assignments: assignments,
            emptyStateText: String(localized: "No new grades — you're all caught up!", bundle: .student),
            emptyStateIconName: "PandaBook",
            accessibilityLabel: count == 0
                ? String(localized: "No new grades", bundle: .student)
                : String(localized: "\(count) new grades", bundle: .student),
            accessibilityValue: expandedState.a11yValue,
            accessibilityHint: expandedState.a11yHint
        )
    }
}
