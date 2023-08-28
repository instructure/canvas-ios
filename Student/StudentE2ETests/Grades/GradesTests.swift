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

class GradesTests: E2ETestCase {
    func testGrades() {
        // MARK: Seed the usual stuff with 2 assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let pointsPossible = [Float(10), Float(100)]
        let assignments = GradesHelper.createAssignments(course: course, count: 2, points_possible: pointsPossible)

        logInDSUser(student)

        // MARK: Create submissions for both
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Navigate to an assignment detail and check if grade updates
        GradesHelper.navigateToAssignments(course: course)

        let assignmentOne = AssignmentsHelper.assignmentButton(assignment: assignments[0]).waitUntil(.visible)
        XCTAssertTrue(assignmentOne.isVisible)
        assignmentOne.hit()

        let grades = ["5", "100"]
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)

        pullToRefresh()
        let assignmentGrade = AssignmentsHelper.pointsOutOf(actualScore: "5", maxScore: "10").waitUntil(.visible)
        XCTAssertTrue(assignmentGrade.isVisible)

        // MARK: Navigate to Grades Page and check there too
        GradesHelper.TabBar.dashboardTab.hit()
        GradesHelper.navigateToGrades(course: course)

        XCTAssertTrue(app.find(label: "Total Grade").waitUntil(.visible).isVisible)
        XCTAssertTrue(GradesHelper.cell(assignment: assignments[0]).waitUntil(.visible, timeout: 5).isVisible)
        XCTAssertTrue(GradesHelper.cell(assignment: assignments[1]).waitUntil(.visible, timeout: 5).isVisible)
        XCTAssertTrue(GradesHelper.gradeOutOf(assignment: assignments[0], actualPoints: "5", maxPoints: "10").waitUntil(.visible, timeout: 5).isVisible)
        XCTAssertTrue(GradesHelper.gradeOutOf(assignment: assignments[1], actualPoints: "100", maxPoints: "100").waitUntil(.visible, timeout: 5).isVisible)
        XCTAssertTrue(GradesHelper.totalGrade.waitUntil(.label(expected: "95.45%"), timeout: 5).isVisible)
    }

    func testLetterGrades() {
        // MARK: Seed the usual stuff with 3 letter grade assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignments = GradesHelper.createAssignments(course: course, count: 3, grading_type: .letter_grade)

        logInDSUser(student)

        // MARK: Create submissions for all
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Navigate to assignments
        GradesHelper.navigateToAssignments(course: course)

        pullToRefresh()
        let firstAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[0]).waitUntil(.visible)
        XCTAssertTrue(firstAssignment.isVisible)

        // MARK: Grade assignments and check if grades are updated on the UI
        let grades = ["1", "100", "B-"]
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)
        pullToRefresh()

        firstAssignment.hit()
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored \(grades[0]) out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "F")

        GradesHelper.backButton.hit()
        let assignment1 = AssignmentsHelper.assignmentButton(assignment: assignments[1]).waitUntil(.visible)
        assignment1.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored \(grades[1]) out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "A")

        GradesHelper.backButton.hit()
        let assignment2 = AssignmentsHelper.assignmentButton(assignment: assignments[2]).waitUntil(.visible)
        assignment2.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored 83 out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "B-")
    }

    func testPercentageGrades() {
        // MARK: Seed the usual stuff with 2 percentage grade assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignments = GradesHelper.createAssignments(course: course, count: 2, grading_type: .percent)

        logInDSUser(student)

        // MARK: Create submissions for both
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Navigate to assignments
        GradesHelper.navigateToAssignments(course: course)

        // MARK: Grade both assignments and check if grades are updated on the UI
        let grades = ["1", "100"]
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)
        pullToRefresh()

        let firstAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[0]).waitUntil(.visible)
        XCTAssertTrue(firstAssignment.isVisible)

        firstAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored \(grades[0]) out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "\(grades[0])%")

        GradesHelper.backButton.hit()
        let secondAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[1]).waitUntil(.visible)
        XCTAssertTrue(secondAssignment.isVisible)

        secondAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored \(grades[1]) out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "\(grades[1])%")
    }

    func testPassFailGrades() {
        // MARK: Seed the usual stuff with 4 pass-fail grade assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignments = GradesHelper.createAssignments(course: course, count: 4, grading_type: .pass_fail)

        logInDSUser(student)

        // MARK: Create submissions for both
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Navigate to assignments
        GradesHelper.navigateToAssignments(course: course)

        // MARK: Grade assignments and check if grades are updated on the UI
        let grades = ["pass", "100", "fail", "fail"]
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)

        pullToRefresh()
        let firstAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[0]).waitUntil(.visible)
        XCTAssertTrue(firstAssignment.isVisible)

        firstAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "Complete")

        GradesHelper.backButton.hit()
        let secondAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[1]).waitUntil(.visible)
        XCTAssertTrue(secondAssignment.isVisible)

        secondAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "Complete")

        GradesHelper.backButton.hit()
        let thirdAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[2]).waitUntil(.visible)
        XCTAssertTrue(thirdAssignment.isVisible)

        thirdAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored 0 out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "Incomplete")

        GradesHelper.backButton.hit()
        let fourthAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[3]).waitUntil(.visible)
        XCTAssertTrue(fourthAssignment.isVisible)

        fourthAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertEqual(AssignmentsHelper.Details.gradeCircle.label, "Scored 0 out of 100 points possible")
        XCTAssertEqual(AssignmentsHelper.Details.gradeDisplayGrade.label, "Incomplete")
    }

    func testLetterGradeOnly() {
        // MARK: Seed the usual stuff, 3 assignments with submissions
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.updateCourseSettings(course: course, restrictQuantitativeData: true)
        seeder.enrollStudent(student, in: course)

        let pointsAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .points)
        let percentAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .percent)
        let passFailAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .pass_fail)
        let assignments = [pointsAssignment, percentAssignment, passFailAssignment]

        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Grade assignments, get the user logged in, check grade pill
        let grades = ["6", "7", "8"]
        let totalGrade = "D"
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)

        logInDSUser(student)

        DashboardHelper.turnOnShowGrades()

        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let courseCardGradeLabel = DashboardHelper.courseCardGradeLabel(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCardGradeLabel.isVisible)
        XCTAssertTrue(courseCardGradeLabel.actionUntilElementCondition(action: .pullToRefresh, condition: .label(expected: totalGrade)))

        // MARK: Check total grade on Grades page
        GradesHelper.navigateToGrades(course: course)
        let pointsAssignmentCell = GradesHelper.cell(assignment: pointsAssignment).waitUntil(.visible)
        let percentAssignmentCell = GradesHelper.cell(assignment: percentAssignment).waitUntil(.visible)
        let passFailAssignmentCell = GradesHelper.cell(assignment: passFailAssignment).waitUntil(.visible)
        XCTAssertTrue(pointsAssignmentCell.isVisible)
        XCTAssertTrue(percentAssignmentCell.isVisible)
        XCTAssertTrue(passFailAssignmentCell.isVisible)

        XCTAssertTrue(GradesHelper.totalGrade.waitUntil(.label(expected: totalGrade)).isVisible)
    }
}
