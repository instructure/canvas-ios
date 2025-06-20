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

struct GradesListItem: Identifiable, Equatable {
    let courseId: String
    let courseName: String
    let grade: String
    let color: Color

    init?(_ course: Course) {
        self.courseId = course.id
        self.courseName = course.name ?? ""
        self.grade = course.displayGrade
        self.color = course.color.asColor
    }

    init(
        courseId: String,
        courseName: String,
        grade: String,
        color: Color
    ) {
        self.courseId = courseId
        self.courseName = courseName
        self.grade = grade
        self.color = color
    }

    var id: String { courseId }

    // MARK: Preview & Testing

    static func make(
        courseId: String = "123",
        courseName: String = "Course Name",
        grade: String = "A",
        color: Color = .red
    ) -> GradesListItem {

        GradesListItem(
            courseId: courseId,
            courseName: courseName,
            grade: grade,
            color: color
        )
    }
}
