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
    @Published public private(set) var assignmentGroups: [AssignmentGroupViewModel] = []
    public private(set) var courseColor: UIColor?
    public private(set) var courseName: String?
    public var selectedGradingPeriod: GradingPeriod? //TODO: persist 

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
        course.refresh()
        apiAssignments.refresh()
        gradingPeriods.refresh()
    }

    public func gradingPeriodSelected(_ gradingPeriod: GradingPeriod?) {
        selectedGradingPeriod = gradingPeriod

        apiAssignments = env.subscribe(GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: gradingPeriod?.id)) { [weak self] in
            self?.assignmentGroupsDidUpdate()
        }
        apiAssignments.refresh(force: true)
    }

    private func assignmentGroupsDidUpdate() {
        assignmentGroups = []
        for section in 0..<(apiAssignments.sections?.count ?? 0) {
            if let group = apiAssignments[IndexPath(row: 0, section: section)]?.assignmentGroup {
                let assignments: [Assignment] = apiAssignments.filter {$0.assignmentGroup == group}
                assignmentGroups.append(AssignmentGroupViewModel(assignmentGroup: group, assignments: assignments))
            }
        }
    }

    private func courseDidUpdate() {
        courseColor = course.first?.color
        courseName = course.first?.name
    }

    private func gradingPeriodsDidUpdate() {
        if gradingPeriods.pending == false && gradingPeriods.requested {
            selectedGradingPeriod = gradingPeriods.all.current
        }
    }
}
