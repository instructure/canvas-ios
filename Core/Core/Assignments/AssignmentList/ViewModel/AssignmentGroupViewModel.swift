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

public class AssignmentGroupViewModel: ObservableObject {
    public let assignments: [Assignment]
    public let name: String
    public let id: String
    public let courseColor: UIColor?

    public init(name: String, id: String, assignments: [Assignment], courseColor: UIColor?) {
        self.name = name
        self.id = id
        self.assignments = assignments
        self.courseColor = courseColor
    }

    public convenience init(assignmentGroup: AssignmentGroup, assignments: [Assignment], courseColor: UIColor?) {
        self.init(name: assignmentGroup.name, id: assignmentGroup.id, assignments: assignments, courseColor: courseColor)
    }

    public convenience init(assignmentDateGroup: AssignmentListViewModel.AssignmentDateGroup, courseColor: UIColor?) {
        self.init(name: assignmentDateGroup.name, id: assignmentDateGroup.id, assignments: assignmentDateGroup.assignments, courseColor: courseColor)
    }
}

extension AssignmentGroupViewModel: Equatable {

    public static func == (lhs: AssignmentGroupViewModel, rhs: AssignmentGroupViewModel) -> Bool {
        lhs.id == rhs.id && lhs.assignments == rhs.assignments
    }
}
