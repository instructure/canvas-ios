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

struct GradeListItem: Identifiable, Equatable {
    let courseId: String
    let courseName: String
    let rawGrade: String
    let grade: AttributedString
    let hideGrade: Bool
    let color: Color

    var id: String { courseId }

    var courseGradesURL: URL? {
        return .gradesRoute(
            forCourse: courseId,
            color: color.hexString
        )
    }

    var gradeAccessibilityLabel: String {
        if hideGrade {
            return String(localized: "Hidden Grades")
        }
        if rawGrade == String(localized: "No Grades", bundle: .core) {
            return rawGrade
        }
        let format = String(localized: "Grade: %@", bundle: .core)
        return String.localizedStringWithFormat(format, rawGrade)
    }

    init?(_ course: Course) {
        self.courseId = course.id
        self.courseName = course.name ?? ""
        self.rawGrade = course.gradeForWidget
        self.grade = course.gradeForWidget.gradeListStyled()
        self.hideGrade = course.hideFinalGrades
        self.color = course.color.asColor
    }

    init(
        courseId: String,
        courseName: String,
        grade: String,
        hideGrade: Bool = false,
        color: Color
    ) {
        self.courseId = courseId
        self.courseName = courseName
        self.rawGrade = grade
        self.grade = grade.gradeListStyled()
        self.hideGrade = hideGrade
        self.color = color
    }

}

extension GradeListItem {

    static let previewItems: [GradeListItem] = [
        GradeListItem(
            courseId: "1",
            courseName: String(localized: "Biology 201", comment: "Example course name for widget preview"),
            grade: "82/100",
            color: .blue
        ),
        GradeListItem(
            courseId: "2",
            courseName: String(localized: "Mathematics 904 2024/25", comment: "Example course name for widget preview"),
            grade: "Good",
            color: .purple
        ),
        GradeListItem(
            courseId: "3",
            courseName: String(localized: "English Literature 101", comment: "Example course name for widget preview"),
            grade: "A+",
            color: .gray
        ),
        GradeListItem(
            courseId: "4",
            courseName: String(localized: "Greek Literature", comment: "Example course name for widget preview"),
            grade: "Good",
            hideGrade: true,
            color: .cyan
        ),
        GradeListItem(
            courseId: "5",
            courseName: String(localized: "Space and Stars", comment: "Example course name for widget preview"),
            grade: "97%",
            color: .indigo
        ),
        GradeListItem(
            courseId: "6",
            courseName: String(localized: "General Astronomy", comment: "Example course name for widget preview"),
            grade: "No Grades",
            color: .teal
        ),
        GradeListItem(
            courseId: "7",
            courseName: String(localized: "Mobile Development 101", comment: "Example course name for widget preview"),
            grade: "F",
            color: .red
        ),
        GradeListItem(
            courseId: "8",
            courseName: String(localized: "Planet Earth", comment: "Example course name for widget preview"),
            grade: "39%",
            color: .brown
        ),
        GradeListItem(
            courseId: "9",
            courseName: String(localized: "Drum And Bass 101", comment: "Example course name for widget preview"),
            grade: "A+",
            color: .orange
        ),
        GradeListItem(
            courseId: "10",
            courseName: String(localized: "In the Jungle", comment: "Example course name for widget preview"),
            grade: "8/10",
            color: .pink
        )
    ]

    #if DEBUG

    // MARK: Preview & Testing

    static func make(
        courseId: String = "123",
        courseName: String = "Course Name",
        grade: String = "A",
        hideGrade: Bool = false,
        color: Color = .red
    ) -> GradeListItem {

        GradeListItem(
            courseId: courseId,
            courseName: courseName,
            grade: grade,
            hideGrade: hideGrade,
            color: color
        )
    }

    #endif
}
