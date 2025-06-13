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

class GradeModelOld: WidgetModel {
    override class var publicPreview: GradeModelOld {
        GradeModelOld(assignmentGrades: [
            GradeItemOld(name: String(localized: "Essay #1: The Rocky Planets", comment: "Example exam name"), grade: "95 / 100", color: .textInfo),
            GradeItemOld(name: String(localized: "American Literature IV", comment: "Example exam name"), grade: "9.2 / 10", color: .textSuccess),
            GradeItemOld(name: String(localized: "Biology Exam 2", comment: "Example exam name"), grade: "20 / 25", color: .course3)
        ], courseGrades: [
            GradeItemOld(name: String(localized: "Introduction to the Solar System", comment: "Example course name"), grade: "A-", color: .textInfo),
            GradeItemOld(name: String(localized: "American Literature IV: All the Books", comment: "Example course name"), grade: "B", color: .textSuccess)
        ])
    }

    let assignmentGrades: [GradeItemOld]
    let courseGrades: [GradeItemOld]

    init(isLoggedIn: Bool = true, assignmentGrades: [GradeItemOld] = [], courseGrades: [GradeItemOld] = []) {
        self.assignmentGrades = assignmentGrades
        self.courseGrades = courseGrades
        super.init(isLoggedIn: isLoggedIn)
    }

    /**
     This method returns a new `GradeModel`. Grade items are calculated by picking assignment grades first then course grades if there's still space left.
     */
    func trimmed(to count: Int) -> GradeModelOld {
        let trimmedAssignmentGrades = Array(assignmentGrades.prefix(count))
        let courseSlots = count - trimmedAssignmentGrades.count
        let trimmedCourseGrades = Array(courseGrades.prefix(courseSlots))
        return GradeModelOld(assignmentGrades: trimmedAssignmentGrades, courseGrades: trimmedCourseGrades)
    }
}

#if DEBUG
extension GradeModelOld {
    public static func makeWithOneAssigmnent() -> GradeModelOld {
        GradeModelOld(assignmentGrades: [
            GradeItemOld(name: "Essay #1: The Rocky Planets", grade: "95.75 / 100", color: .course3)
        ], courseGrades: [
        ])
    }

    public static func makeWithOneCourse() -> GradeModelOld {
        GradeModelOld(assignmentGrades: [
        ], courseGrades: [
            GradeItemOld(name: "Introduction to Neighboring Stars", grade: "A+", color: .textDarkest)
        ])
    }

    public static func make() -> GradeModelOld {
        GradeModelOld(assignmentGrades: [
            GradeItemOld(name: "Essay #1: The Rocky Planets", grade: "95.75 / 100", color: .course3),
            GradeItemOld(name: "Earth: The Pale Blue Dot on two lines or more since it's very long", grade: "20 / 25", color: .textDanger),
            GradeItemOld(name: "American Literature IV", grade: "9.2 / 10", color: .textWarning)
        ], courseGrades: [
            GradeItemOld(name: "Introduction to the Solar System", grade: "A-", color: .textSuccess),
            GradeItemOld(name: "American Literature IV: All the Books", grade: "B"),
            GradeItemOld(name: "Introduction to Neighboring Stars", grade: "A+", color: .textDarkest),
            GradeItemOld(name: "Biology 101", grade: "C+", color: .textInfo)
        ])
    }
}
#endif
