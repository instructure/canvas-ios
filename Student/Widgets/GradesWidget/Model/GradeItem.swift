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

/** Widgets need the Encodable protocol but since Color is not Encodable we store its hex value as a string. */
struct GradeItem: Hashable, Encodable {
    let name: String
    let grade: String
    let colorHex: String
    let route: URL

    var color: Color {
        Color(hexString: colorHex) ?? .textDarkest
    }

    init(assignment: Assignment, color: UIColor) {
        self.name = assignment.name
        // Formatter returns nil in case of ungraded assignments, at this point we should only have graded assignments here.
        self.grade = GradeFormatter.string(from: assignment, style: .medium) ?? ""
        self.colorHex = color.hexString
        self.route = assignment.route
    }

    init(assignment: Assignment, color: Color) {
        self.init(assignment: assignment, color: UIColor(color))
    }

    init(course: Course) {
        self.name = course.name ?? ""
        self.grade = course.displayGrade
        self.colorHex = course.color.hexString
        self.route = course.route
    }

    init(
        name: String = "Test Assignment",
        grade: String = "87 / 100",
        color: Color = .textDarkest,
        route: URL = URL(string: "canvas-courses://")!
    ) {
        self.name = name
        self.grade = grade
        self.colorHex = UIColor(color).hexString
        self.route = route
    }
}
