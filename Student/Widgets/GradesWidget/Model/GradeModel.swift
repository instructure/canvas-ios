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

class GradeModel: WidgetModel {
    override class var publicPreview: GradeModel {
        GradeModel(assignmentGrades: [
            GradeItem(name: String(localized: "Essay #1: The Rocky Planets", comment: "Example exam name"), grade: "95 / 100", color: .electric),
            GradeItem(name: String(localized: "American Literature IV", comment: "Example exam name"), grade: "9.2 / 10", color: .textSuccess),
            GradeItem(name: String(localized: "Biology Exam 2", comment: "Example exam name"), grade: "20 / 25", color: .course3)
        ], courseGrades: [
            GradeItem(name: String(localized: "Introduction to the Solar System", comment: "Example course name"), grade: "A-", color: .electric),
            GradeItem(name: String(localized: "American Literature IV: All the Books", comment: "Example course name"), grade: "B", color: .textSuccess)
        ])
    }

    let assignmentGrades: [GradeItem]
    let courseGrades: [GradeItem]

    init(isLoggedIn: Bool = true, assignmentGrades: [GradeItem] = [], courseGrades: [GradeItem] = []) {
        self.assignmentGrades = assignmentGrades
        self.courseGrades = courseGrades
        super.init(isLoggedIn: isLoggedIn)
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
    public static func makeWithOneAssigmnent() -> GradeModel {
        GradeModel(assignmentGrades: [
            GradeItem(name: "Essay #1: The Rocky Planets", grade: "95.75 / 100", color: .course3)
        ], courseGrades: [
        ])
    }

    public static func makeWithOneCourse() -> GradeModel {
        GradeModel(assignmentGrades: [
        ], courseGrades: [
            GradeItem(name: "Introduction to Neighboring Stars", grade: "A+", color: .licorice)
        ])
    }

    public static func make() -> GradeModel {
        GradeModel(assignmentGrades: [
            GradeItem(name: "Essay #1: The Rocky Planets", grade: "95.75 / 100", color: .course3),
            GradeItem(name: "Earth: The Pale Blue Dot on two lines or more since it's very long", grade: "20 / 25", color: .textDanger),
            GradeItem(name: "American Literature IV", grade: "9.2 / 10", color: .textWarning)
        ], courseGrades: [
            GradeItem(name: "Introduction to the Solar System", grade: "A-", color: .textSuccess),
            GradeItem(name: "American Literature IV: All the Books", grade: "B"),
            GradeItem(name: "Introduction to Neighboring Stars", grade: "A+", color: .licorice),
            GradeItem(name: "Biology 101", grade: "C+", color: .electric)
        ])
    }
}
#endif
