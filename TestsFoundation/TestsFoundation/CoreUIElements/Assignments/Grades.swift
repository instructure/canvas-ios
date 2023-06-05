//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation

public enum GradeList {
    public static var title: Element {
        return app.find(label: "Grades")
    }

    public static func cell(assignmentID: String) -> Element {
        return app.find(id: "GradeListCell.\(assignmentID)")
    }

    public static func gradeOutOf(assignmentID: String, actualPoints: String, maxPoints: String) -> Element {
        let assignment = app.find(id: "GradeListCell.\(assignmentID)")
        return assignment.rawElement.find(label: "Grade, \(actualPoints) out of \(maxPoints)")
    }

    public static func totalGrade(totalGrade: String) -> Element {
        app.find(id: "CourseTotalGrade", label: totalGrade)
    }
}
