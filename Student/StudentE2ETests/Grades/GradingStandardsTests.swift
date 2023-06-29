//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import TestsFoundation
import XCTest

class GradingStandardsTests: E2ETestCase {
    func testGradingStandards() {
        // MARK: Seed the usual stuff and a grading scheme
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let gradingScheme = seeder.postGradingStandards(courseId: course.id, requestBody: .init())
        seeder.updateCourseWithGradingScheme(courseId: course.id, gradingStandardId: Int(gradingScheme.id)!)

        // MARK: Create 2 assignments
        let assignments = GradesHelper.createAssignments(course: course, count: 2)

        logInDSUser(student)

        // MARK: Create submissions for both
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Navigate to grades
        GradesHelper.navigateToGrades(course: course)
        XCTAssertTrue(app.find(label: "Total Grade").waitToExist().isVisible)
        XCTAssertTrue(GradeList.totalGrade(totalGrade: "N/A (F)").waitToExist().isVisible)

        // MARK: Check if total is updating accordingly
        GradesHelper.gradeAssignments(grades: ["100"], course: course, assignments: [assignments[0]], user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(totalGrade: "100% (A)"))

        GradesHelper.gradeAssignments(grades: ["0"], course: course, assignments: [assignments[1]], user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(totalGrade: "50% (F)"))
    }
}
