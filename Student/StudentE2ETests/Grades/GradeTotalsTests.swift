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

class GradeTotalsTests: E2ETestCase {
    func testGradeTotals() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create different grade type assigments
        let assignments = GradesHelper.createAssignments(course: course, count: 2)
        let pfg_assignments = GradesHelper.createAssignments(course: course, count: 2, grading_type: .pass_fail)
        let pg_assignments = GradesHelper.createAssignments(course: course, count: 2, grading_type: .percent)
        let lg_assignments = GradesHelper.createAssignments(course: course, count: 2, grading_type: .letter_grade)

        logInDSUser(student)

        // MARK: Create submissions for all
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: pfg_assignments)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: pg_assignments)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: lg_assignments)

        // MARK: See if total grades is N/A
        GradesHelper.navigateToGrades(course: course)
        XCTAssertTrue(app.find(label: "Total Grade").waitUntil(.visible).isVisible)
        XCTAssertTrue(GradesHelper.totalGrade.waitUntil(.visible).hasLabel(label: "N/A"))

        // MARK: Check if total is updating accordingly
        let grades = ["100", "25"]
        let pfg_grades = ["fail", "pass"]
        let pg_grades = ["30%", "90%"]
        let lg_grades = ["A", "E"]
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(value: "62.5%"))

        GradesHelper.gradeAssignments(grades: pfg_grades, course: course, assignments: pfg_assignments, user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(value: "56.25%"))

        GradesHelper.gradeAssignments(grades: pg_grades, course: course, assignments: pg_assignments, user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(value: "57.5%"))

        GradesHelper.gradeAssignments(grades: lg_grades, course: course, assignments: lg_assignments, user: student)
        XCTAssertTrue(GradesHelper.checkForTotalGrade(value: "63.57%"))
    }
}
