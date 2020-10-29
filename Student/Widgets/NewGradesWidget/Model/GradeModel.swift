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

import WidgetKit

struct GradeModel: TimelineEntry {
    let date = Date(timeIntervalSince1970: 0)
    let assignmentGrades: [GradeItem]
    let courseGrades: [GradeItem]

    init(assignmentGrades: [GradeItem], courseGrades: [GradeItem]) {
        self.assignmentGrades = assignmentGrades
        self.courseGrades = courseGrades
    }

    /**
     This method returns a new `GradeModel`. Grade items are calculated by picking assignment grades first then course grades if there's still space left.
     */
    func trimmed(to count: Int) -> GradeModel {
        let trimmedAssignmentGrades = Array(assignmentGrades.prefix(count))
        let courseSlots = count - trimmedAssignmentGrades.count
        let trimmedCourseGrades = Array(courseGrades.prefix(courseSlots))
        return GradeModel(assignmentGrades: trimmedAssignmentGrades, courseGrades: trimmedCourseGrades)
    }
}

#if DEBUG
extension GradeModel {
    public static func make() -> GradeModel {
        GradeModel(assignmentGrades: [
            GradeItem(assignmentName: "Essay #1: The Rocky Planets", grade: "95.75 / 100", color: .barney),
            GradeItem(assignmentName: "Earth: The Pale Blue Dot on two lines", grade: "20 / 25", color: .crimson),
            GradeItem(assignmentName: "American Literature IV", grade: "9.2 / 10", color: .fire),
            GradeItem(assignmentName: "Quiz #3: Earth", grade: "3 / 5"),
        ], courseGrades: [
            GradeItem(assignmentName: "Introduction to the Solar System", grade: "A-", color: .shamrock),
            GradeItem(assignmentName: "Biology 101", grade: "C+", color: .electric),
            GradeItem(assignmentName: "Introduction to Neighboring Stars", grade: "A+", color: .licorice),
            GradeItem(assignmentName: "American Literature IV: All the Books", grade: "B"),
        ])
    }
}
#endif
