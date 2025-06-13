//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core

struct GradeItem: Identifiable, Equatable {
    let courseId: String
    let courseName: String
    let totalGrade: String
    let color: Color

    init?(_ course: Course) {
        self.courseId = course.id
        self.courseName = course.name ?? ""
        self.totalGrade = course.displayGrade
        self.color = course.color.asColor
    }

    init(courseId: String, courseName: String, totalGrade: String, color: Color) {
        self.courseId = courseId
        self.courseName = courseName
        self.totalGrade = totalGrade
        self.color = color
    }

    var id: String { courseId }

    // MARK: Preview & Testing

    static func make(
        courseId: String = "1",
        courseName: String = "Example Course",
        totalGrade: String = "A",
        color: Color = .red,
    ) -> GradeItem {

        GradeItem(
            courseId: courseId,
            courseName: courseName,
            totalGrade: totalGrade,
            color: color
        )
    }
}
