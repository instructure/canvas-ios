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
import SwiftUI
import WidgetKit

struct GradeItem: Hashable {
    let assignmentName: String
    let grade: String
    let color: Color
    let route: URL

    init(assignment: Assignment, color: Color) {
        self.assignmentName = assignment.name
        // Formatter returns nil in case of ungraded assignments, at this point we should only have graded assignments here.
        self.grade = GradeFormatter.string(from: assignment, style: .medium) ?? ""
        self.color = color
        self.route = assignment.route
    }

    init(assignment: Assignment, color: UIColor) {
        self.init(assignment: assignment, color: Color(color))
    }

    init(course: Course) {
        self.assignmentName = course.name ?? ""
        self.grade = course.displayGrade
        self.color = Color(course.color)
        self.route = course.route
    }

    init(assignmentName: String = "Test Assignment", grade: String = "87 / 100", color: Color = .textDarkest, route: URL = URL(string: "canvas-courses://")!) {
        self.assignmentName = assignmentName
        self.grade = grade
        self.color = color
        self.route = route
    }
}
