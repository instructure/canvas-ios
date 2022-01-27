//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI

public class AssignmentListViewModel: ObservableObject {
    public enum ViewModelState<T> {
        case loading
        case empty
        case data(T)
    }

    @Published public private(set) var state: ViewModelState<[AssignmentGroupViewModel]> = .loading
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    public var selectedGradingPeriod: GradingPeriod?
    public var shouldShowFilterButton: Bool { gradingPeriods.all.count > 1 }

    @Environment(\.appEnvironment) private var env
    private let courseID: String

    lazy private var apiAssignments = env.subscribe(GetAssignmentsByGroup(courseID: courseID)) { [weak self] in
        self?.assignmentGroupsDidUpdate()
    }

    lazy private var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    lazy public private (set) var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        self?.gradingPeriodsDidUpdate()
    }

    public init(context: Context) {
        self.courseID = context.id
    }

    // MARK: - Preview Support

    init(state: ViewModelState<[AssignmentGroupViewModel]>) {
        self.courseID = ""
        self.state = state
    }

    // MARK: Preview Support -

    public func gradingPeriodFilterCleared() {
        gradingPeriodSelected(nil)
    }

    public func gradingPeriodSelected(_ gradingPeriod: GradingPeriod?) {
        state = .loading
        selectedGradingPeriod = gradingPeriod

        apiAssignments = env.subscribe(GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: gradingPeriod?.id)) { [weak self] in
            self?.assignmentGroupsDidUpdate()
        }
        apiAssignments.exhaust(force: true)
    }

    public func viewDidAppear() {
        course.refresh()
        apiAssignments.exhaust()
        gradingPeriods.exhaust()
    }

    private func assignmentGroupsDidUpdate() {
        if apiAssignments.requested, apiAssignments.pending { return }

        var assignmentGroups: [AssignmentGroupViewModel] = []

        for section in 0..<(apiAssignments.sections?.count ?? 0) {
            if let group = apiAssignments[IndexPath(row: 0, section: section)]?.assignmentGroup {
                let assignments: [Assignment] = apiAssignments.filter {$0.assignmentGroup == group}
                assignmentGroups.append(AssignmentGroupViewModel(assignmentGroup: group, assignments: assignments, courseColor: courseColor))
            }
        }

        state = (assignmentGroups.isEmpty ? .empty : .data(assignmentGroups))
    }

    private func courseDidUpdate() {
        courseColor = course.first?.color
        courseName = course.first?.name
    }

    private func gradingPeriodsDidUpdate() {
        if gradingPeriods.pending == false && gradingPeriods.requested {
            // TODO: send "ready"
        }
    }
}

extension AssignmentListViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        apiAssignments.exhaust(force: true) { [weak self] _ in
            if self?.apiAssignments.hasNextPage == false {
                completion()
            }
            return true
        }
    }
}
