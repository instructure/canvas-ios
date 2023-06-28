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
    func testGradingStandards() throws {
        // MARK: Seed the usual stuff and a grading scheme
        let student = try seeder.createUser()
        let course = try seeder.createCourse()
        try seeder.enrollStudent(student, in: course)
        let gradingScheme = try seeder.postGradingStandards(courseId: course.id, requestBody: .init())
        try seeder.updateCourseWithGradingScheme(courseId: course.id, gradingStandardId: Int(gradingScheme.id)!)

        // MARK: Create 2 assignments
        let assignments = try GradesHelper.createAssignments(course: course, count: 2)

        logInDSUser(student)

        // MARK: Create submissions for both
        try GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Navigate to grades
        GradesHelper.navigateToGrades(course: course)
        XCTAssertTrue(app.find(label: "Total Grade").waitToExist().isVisible)
        XCTAssertTrue(GradeList.totalGrade(totalGrade: "N/A (F)").waitToExist().isVisible)

        // MARK: Check if total is updating accordingly
        try GradesHelper.gradeAssignments(grades: ["100"], course: course, assignments: [assignments[0]], user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(totalGrade: "100% (A)"))

        try GradesHelper.gradeAssignments(grades: ["0"], course: course, assignments: [assignments[1]], user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(totalGrade: "50% (F)"))
    }
}
