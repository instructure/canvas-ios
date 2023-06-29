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

import Core
import TestsFoundation
import XCTest

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

        let assignmentOne = AssignmentsList.assignment(id: assignments[0].id).waitToExist()
        XCTAssertTrue(assignmentOne.isVisible)
        assignmentOne.tap()

        let grades = ["5", "100"]
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)

        pullToRefresh()
        let assignmentGrade = AssignmentDetails.pointsOutOf(actualScore: "5", maxScore: "10").waitToExist()
        XCTAssertTrue(assignmentGrade.isVisible)

        // MARK: Navigate to Grades Page and check there too
        TabBar.dashboardTab.tap()
        GradesHelper.navigateToGrades(course: course)

        XCTAssertTrue(app.find(label: "Total Grade").waitToExist().exists)
        XCTAssertTrue(GradeList.cell(assignmentID: assignments[0].id).waitToExist(5).exists())
        XCTAssertTrue(GradeList.cell(assignmentID: assignments[1].id).waitToExist(5).exists())
        XCTAssertTrue(GradeList.gradeOutOf(assignmentID: assignments[0].id, actualPoints: "5", maxPoints: "10").waitToExist(5).exists())
        XCTAssertTrue(GradeList.gradeOutOf(assignmentID: assignments[1].id, actualPoints: "100", maxPoints: "100").waitToExist(5).exists())
        XCTAssertTrue(GradeList.totalGrade(totalGrade: "95.45%").exists())
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
        let firstAssignment = AssignmentsList.assignment(id: assignments[0].id).waitToExist()
        XCTAssertTrue(firstAssignment.isVisible)

        // MARK: Grade assignments and check if grades are updated on the UI
        let grades = ["1", "100", "B-"]
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)
        pullToRefresh()

        firstAssignment.tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored \(grades[0]) out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "F")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignments[1].id).waitToExist()
        AssignmentsList.assignment(id: assignments[1].id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored \(grades[1]) out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "A")

        NavBar.backButton.tap()
        AssignmentsList.assignment(id: assignments[2].id).waitToExist()
        AssignmentsList.assignment(id: assignments[2].id).tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 83 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "B-")
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

        let firstAssignment = AssignmentsList.assignment(id: assignments[0].id).waitToExist()
        XCTAssertTrue(firstAssignment.isVisible)
        firstAssignment.tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored \(grades[0]) out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "\(grades[0])%")

        NavBar.backButton.tap()
        let secondAssignment = AssignmentsList.assignment(id: assignments[1].id).waitToExist()
        XCTAssertTrue(secondAssignment.isVisible)
        secondAssignment.tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored \(grades[1]) out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "\(grades[1])%")
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
        let firstAssignment = AssignmentsList.assignment(id: assignments[0].id).waitToExist()
        XCTAssertTrue(firstAssignment.isVisible)
        firstAssignment.tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Complete")

        NavBar.backButton.tap()
        let secondAssignment = AssignmentsList.assignment(id: assignments[1].id).waitToExist()
        XCTAssertTrue(secondAssignment.isVisible)
        secondAssignment.tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 100 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Complete")

        NavBar.backButton.tap()
        let thirdAssignment = AssignmentsList.assignment(id: assignments[2].id).waitToExist()
        XCTAssertTrue(thirdAssignment.isVisible)
        thirdAssignment.tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 0 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Incomplete")

        NavBar.backButton.tap()
        let fourthAssignment = AssignmentsList.assignment(id: assignments[3].id).waitToExist()
        XCTAssertTrue(fourthAssignment.isVisible)
        fourthAssignment.tap()
        XCTAssertEqual(AssignmentDetails.gradeCircle.label(), "Scored 0 out of 100 points possible")
        XCTAssertEqual(AssignmentDetails.gradeDisplayGrade.label(), "Incomplete")
    }
}
