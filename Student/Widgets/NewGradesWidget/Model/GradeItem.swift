//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import WidgetKit

struct GradeItem: Hashable {
    let assignmentName: String
    let grade: String

    init(assignment: Assignment) {
        assignmentName = assignment.name
        // Formatter returns nil in case of ungraded assignments, at this point we should only have graded assignments here.
        grade = GradeFormatter.string(from: assignment, style: .medium) ?? ""
    }

    init(assignmentName: String = "Test Assignment", grade: String = "87 / 100") {
        self.assignmentName = assignmentName
        self.grade = grade
    }
}
