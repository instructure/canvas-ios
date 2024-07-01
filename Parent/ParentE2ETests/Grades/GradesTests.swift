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

import TestsFoundation

class GradesTests: E2ETestCase {
    typealias Helper = GradesHelper

    func testGrades() {
        // MARK: Seed the usual stuff, 3 assignments with submissions
        let student = seeder.createUser()
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        seeder.enrollParent(parent, in: course, student: student)

        let pointsAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .points)
        let percentAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .percent)
        let passFailAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .pass_fail)
        let assignments = [pointsAssignment, percentAssignment, passFailAssignment]

        Helper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Grade assignments, get the user logged in, tap on course
        let grades = ["6", "70%", "complete"]
        let totalGrade = "76.67%"
        Helper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)

        logInDSUser(parent)

        let courseCard = DashboardHelperParent.courseCard(course: course).waitUntil(.visible)
        let courseCardGradeLabel = DashboardHelperParent.courseGradeLabel(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(courseCardGradeLabel.isVisible)
        XCTAssertTrue(courseCardGradeLabel.hasLabel(label: totalGrade), "\(courseCardGradeLabel.label) != \(totalGrade)")

        // MARK: Tap on course, check grades
        courseCard.hit()
        let courseTotalGradeLabel = GradesHelper.totalGrade.waitUntil(.visible)
        let pointsAssignmentCell = GradesHelper.cell(assignment: pointsAssignment).waitUntil(.visible)
        let pointsAssignmentGrade = pointsAssignmentCell.find(labelContaining: "Grade, ", type: .staticText).waitUntil(.visible)
        let percentAssignmentCell = GradesHelper.cell(assignment: percentAssignment).waitUntil(.visible)
        let percentAssignmentGrade = percentAssignmentCell.find(labelContaining: "Grade, ", type: .staticText).waitUntil(.visible)
        let passFailAssignmentCell = GradesHelper.cell(assignment: passFailAssignment).waitUntil(.visible)
        let passFailAssignmentGrade = passFailAssignmentCell.find(labelContaining: "Grade, ", type: .staticText).waitUntil(.visible)
        XCTAssertTrue(courseTotalGradeLabel.isVisible)
        XCTAssertTrue(courseTotalGradeLabel.hasLabel(label: "Total grade is \(totalGrade)"))
        XCTAssertTrue(pointsAssignmentCell.isVisible)
        XCTAssertTrue(pointsAssignmentGrade.isVisible)
        XCTAssertTrue(pointsAssignmentGrade.hasLabel(label: "6 out of 10", strict: false))
        XCTAssertTrue(percentAssignmentCell.isVisible)
        XCTAssertTrue(percentAssignmentGrade.isVisible)
        XCTAssertTrue(percentAssignmentGrade.hasLabel(label: "70%", strict: false))
        XCTAssertTrue(passFailAssignmentCell.isVisible)
        XCTAssertTrue(passFailAssignmentGrade.isVisible)
        XCTAssertTrue(passFailAssignmentGrade.hasLabel(label: "Complete", strict: false))
    }

    func testLetterGradeOnly() {
        // MARK: Seed the usual stuff, 3 assignments with submissions
        let student = seeder.createUser()
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.updateCourseSettings(course: course, restrictQuantitativeData: true)
        seeder.enrollStudent(student, in: course)
        seeder.enrollParent(parent, in: course, student: student)

        let pointsAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .points)
        let percentAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .percent)
        let passFailAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .pass_fail)
        let assignments = [pointsAssignment, percentAssignment, passFailAssignment]

        Helper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Grade assignments, get the user logged in, tap on course
        let grades = ["7.9", "79%", "complete"]
        let totalGrade = "B"
        Helper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)

        logInDSUser(parent)

        let courseCard = DashboardHelperParent.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        courseCard.hit()

        // MARK: Check total grade on Grades page, check assignments
        let courseTotalGradeLabel = GradesHelper.totalGrade.waitUntil(.visible)
        let pointsAssignmentCell = GradesHelper.cell(assignment: pointsAssignment).waitUntil(.visible)
        let percentAssignmentCell = GradesHelper.cell(assignment: percentAssignment).waitUntil(.visible)
        let passFailAssignmentCell = GradesHelper.cell(assignment: passFailAssignment).waitUntil(.visible)
        XCTAssertTrue(courseTotalGradeLabel.isVisible)
        XCTAssertTrue(courseTotalGradeLabel.hasLabel(label: "Total grade is \(totalGrade)"))
        XCTAssertTrue(pointsAssignmentCell.isVisible)
        XCTAssertTrue(percentAssignmentCell.isVisible)
        XCTAssertTrue(passFailAssignmentCell.isVisible)
    }
}
