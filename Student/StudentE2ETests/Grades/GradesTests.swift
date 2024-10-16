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

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Create submissions for both assignments
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
        let gradeCell1 = GradesHelper.cell(assignment: assignments[0]).waitUntil(.visible, timeout: 5)
        let gradeCell2 = GradesHelper.cell(assignment: assignments[1]).waitUntil(.visible, timeout: 5)
        let gradeOutOfLabel1 = GradesHelper.gradeOutOf(assignment: assignments[0], actualPoints: "5", maxPoints: "10")
            .waitUntil(.visible, timeout: 5)
        let gradeOutOfLabel2 = GradesHelper.gradeOutOf(assignment: assignments[1], actualPoints: "100", maxPoints: "100")
            .waitUntil(.visible, timeout: 5)
        let totalGrade = GradesHelper.totalGrade.waitUntil(.label(expected: "95.45%"), timeout: 5)
        XCTAssertTrue(gradeCell1.isVisible)
        XCTAssertTrue(gradeCell2.isVisible)
        XCTAssertTrue(gradeOutOfLabel1.isVisible)
        XCTAssertTrue(gradeOutOfLabel2.isVisible)
        XCTAssertTrue(totalGrade.isVisible)
    }

    func testLetterGrades() {
        // MARK: Seed the usual stuff with 3 letter grade assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let assignments = GradesHelper.createAssignments(course: course, count: 3, grading_type: .letter_grade)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

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
        let gradeCircle = AssignmentsHelper.Details.gradeCircle.waitUntil(.visible)
        let gradeLabel = AssignmentsHelper.Details.gradeDisplayGrade.waitUntil(.visible)
        XCTAssertTrue(gradeCircle.hasLabel(label: "Scored \(grades[0]) out of 100 points possible"))
        XCTAssertTrue(gradeLabel.hasLabel(label: "F"))

        // On iPhone: Back button needs to be tapped
        // On iPad: No button tap needed to see other assignments
        let assignment1 = AssignmentsHelper.assignmentButton(assignment: assignments[1]).waitUntil(.visible, timeout: 5)
        if assignment1.isVanished { GradesHelper.backButton.hit() }
        assignment1.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(gradeCircle.waitUntil(.visible).hasLabel(label: "Scored \(grades[1]) out of 100 points possible"))
        XCTAssertTrue(gradeLabel.waitUntil(.visible).hasLabel(label: "A"))

        // On iPhone: Back button needs to be tapped
        // On iPad: No button tap needed to see other assignments
        let assignment2 = AssignmentsHelper.assignmentButton(assignment: assignments[2]).waitUntil(.visible, timeout: 5)
        if assignment2.isVanished { GradesHelper.backButton.hit() }
        assignment2.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(gradeCircle.waitUntil(.visible).hasLabel(label: "Scored 83 out of 100 points possible"))
        XCTAssertTrue(gradeLabel.waitUntil(.visible).hasLabel(label: "B-"))
    }

    func testPercentageGrades() {
        // MARK: Seed the usual stuff with 2 percentage grade assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let assignments = GradesHelper.createAssignments(course: course, count: 2, grading_type: .percent)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

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
        let gradeCircle = AssignmentsHelper.Details.gradeCircle.waitUntil(.visible)
        let gradeLabel = AssignmentsHelper.Details.gradeDisplayGrade.waitUntil(.visible)
        XCTAssertTrue(gradeCircle.hasLabel(label: "Scored \(grades[0]) out of 100 points possible"))
        XCTAssertTrue(gradeLabel.hasLabel(label: "\(grades[0])%"))

        let secondAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[1]).waitUntil(.visible, timeout: 5)
        if secondAssignment.isVanished { GradesHelper.backButton.hit() }
        XCTAssertTrue(secondAssignment.waitUntil(.visible).isVisible)

        secondAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(gradeCircle.hasLabel(label: "Scored \(grades[1]) out of 100 points possible"))
        XCTAssertTrue(gradeLabel.hasLabel(label: "\(grades[1])%"))
    }

    func testPassFailGrades() {
        // MARK: Seed the usual stuff with 4 pass-fail grade assignments
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let assignments = GradesHelper.createAssignments(course: course, count: 4, grading_type: .pass_fail)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

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
        let gradeCircle = AssignmentsHelper.Details.gradeCircle.waitUntil(.visible)
        let gradeLabel = AssignmentsHelper.Details.gradeDisplayGrade.waitUntil(.visible)
        XCTAssertTrue(gradeCircle.hasLabel(label: "Scored 100 out of 100 points possible"))
        XCTAssertTrue(gradeLabel.hasLabel(label: "Complete"))

        let secondAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[1]).waitUntil(.visible, timeout: 5)
        if secondAssignment.isVanished { GradesHelper.backButton.hit() }
        XCTAssertTrue(secondAssignment.waitUntil(.visible).isVisible)

        secondAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(gradeCircle.hasLabel(label: "Scored 100 out of 100 points possible"))
        XCTAssertTrue(gradeLabel.hasLabel(label: "Complete"))

        let thirdAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[2]).waitUntil(.visible, timeout: 5)
        if thirdAssignment.isVanished { GradesHelper.backButton.hit() }
        XCTAssertTrue(thirdAssignment.waitUntil(.visible).isVisible)

        thirdAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(gradeCircle.hasLabel(label: "Scored 0 out of 100 points possible"))
        XCTAssertTrue(gradeLabel.hasLabel(label: "Incomplete"))

        let fourthAssignment = AssignmentsHelper.assignmentButton(assignment: assignments[3]).waitUntil(.visible, timeout: 5)
        if fourthAssignment.isVanished { GradesHelper.backButton.hit() }
        XCTAssertTrue(fourthAssignment.waitUntil(.visible).isVisible)

        fourthAssignment.hit()
        AssignmentsHelper.Details.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(gradeCircle.hasLabel(label: "Scored 0 out of 100 points possible"))
        XCTAssertTrue(gradeLabel.hasLabel(label: "Incomplete"))
    }

    func testLetterGradeOnly() {
        // MARK: Seed the usual stuff, 3 assignments with submissions
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let pointsAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .points)
        let percentAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .percent)
        let passFailAssignment = AssignmentsHelper.createAssignment(course: course, pointsPossible: 10, gradingType: .pass_fail)
        let assignments = [pointsAssignment, percentAssignment, passFailAssignment]
        seeder.updateCourseSettings(course: course, restrictQuantitativeData: true)
        seeder.enrollStudent(student, in: course)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)

        // MARK: Grade assignments, get the user logged in, check grade pill
        let grades = ["6", "7", "8"]
        let totalGrade = "D"
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: assignments, user: student)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        DashboardHelper.turnOnShowGrades()
        courseCard.waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        let courseCardGradeLabel = DashboardHelper.courseCardGradeLabel(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCardGradeLabel.isVisible)
        XCTAssertTrue(courseCardGradeLabel.actionUntilElementCondition(action: .pullToRefresh, condition: .label(expected: totalGrade)))

        // MARK: Check total grade on Grades page
        GradesHelper.navigateToGrades(course: course)
        let pointsAssignmentCell = GradesHelper.cell(assignment: pointsAssignment).waitUntil(.visible)
        let percentAssignmentCell = GradesHelper.cell(assignment: percentAssignment).waitUntil(.visible)
        let passFailAssignmentCell = GradesHelper.cell(assignment: passFailAssignment).waitUntil(.visible)
        let totalGradeLabel = GradesHelper.totalGrade.waitUntil(.visible)
        XCTAssertTrue(pointsAssignmentCell.isVisible)
        XCTAssertTrue(percentAssignmentCell.isVisible)
        XCTAssertTrue(passFailAssignmentCell.isVisible)
        XCTAssertTrue(totalGradeLabel.hasLabel(label: "Total grade is \(totalGrade)"))
    }

    func testAssignmentGroupsWithGradedAssignments() {
        // MARK: Seed the usual stuff with assignment groups and graded submissions
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let testAG1 = AssignmentsHelper.createAssignmentGroup(in: course, name: "Test AG 1")
        let testAG2 = AssignmentsHelper.createAssignmentGroup(in: course, name: "Test AG 2")

        let maxPointOfAssignment: Float = 10
        let assignment1 = AssignmentsHelper.createAssignment(
            course: course,
            name: "Assignment for Test AG 1",
            pointsPossible: maxPointOfAssignment,
            assignmentGroup: testAG1
        )
        let assignment2 = AssignmentsHelper.createAssignment(
            course: course,
            name: "Assignment for Test AG 2",
            pointsPossible: maxPointOfAssignment,
            assignmentGroup: testAG2
        )
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment1)
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment2)

        let gradeOfAssignment1 = "9"
        let gradeOfAssignment2 = "7"
        GradesHelper.gradeAssignment(grade: gradeOfAssignment1, course: course, assignment: assignment1, user: student)
        GradesHelper.gradeAssignment(grade: gradeOfAssignment2, course: course, assignment: assignment2, user: student)
        let expectedTotalGrade = "80%"

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Grades page, check for assignment groups and grades
        GradesHelper.navigateToGrades(course: course)
        let totalGradeLabel = GradesHelper.totalGrade.waitUntil(.visible)
        XCTAssertTrue(totalGradeLabel.isVisible)
        XCTAssertTrue(totalGradeLabel.hasLabel(label: "Total grade is \(expectedTotalGrade)"))

        let filterButton = GradesHelper.filterButton.waitUntil(.visible)
        let upcomingAssignmentsLabel = GradesHelper.upcomingAssignmentsLabel.waitUntil(.visible)
        XCTAssertTrue(filterButton.isVisible)
        XCTAssertTrue(upcomingAssignmentsLabel.isVisible)

        filterButton.hit()
        let sortByGroupSwitch = GradesHelper.Filter.sortByGroupSwitch.waitUntil(.visible)
        let sortByDateSwitch = GradesHelper.Filter.sortByDateSwitch.waitUntil(.visible)
        let saveButton = GradesHelper.Filter.saveButton.waitUntil(.visible)
        XCTAssertTrue(sortByGroupSwitch.isVisible)
        XCTAssertTrue(sortByDateSwitch.isVisible)
        XCTAssertTrue(saveButton.isVisible)
        XCTAssertTrue(saveButton.isDisabled)

        sortByGroupSwitch.hit()
        XCTAssertTrue(saveButton.waitUntil(.enabled).isEnabled)

        saveButton.hit()

        let labelOfAG1 = GradesHelper.labelOfAG(assignmentGroup: testAG1).waitUntil(.visible)
        let labelOfAG2 = GradesHelper.labelOfAG(assignmentGroup: testAG2).waitUntil(.visible)
        XCTAssertTrue(labelOfAG1.isVisible)
        XCTAssertTrue(labelOfAG2.isVisible)

        let assignmentCellOfTestAG1 = GradesHelper.cell(assignment: assignment1).waitUntil(.visible)
        let assignmentCellOfTestAG2 = GradesHelper.cell(assignment: assignment2).waitUntil(.visible)
        XCTAssertTrue(assignmentCellOfTestAG1.isVisible)
        XCTAssertTrue(assignmentCellOfTestAG2.isVisible)

        let gradedLabelOfAssignment1 = GradesHelper.gradedLabel(assignmentCell: assignmentCellOfTestAG1).waitUntil(.visible)
        let gradeLabelOfAssignment1 = GradesHelper.gradeLabel(assignmentCell: assignmentCellOfTestAG1).waitUntil(.visible)
        let gradedLabelOfAssignment2 = GradesHelper.gradedLabel(assignmentCell: assignmentCellOfTestAG2).waitUntil(.visible)
        let gradeLabelOfAssignment2 = GradesHelper.gradeLabel(assignmentCell: assignmentCellOfTestAG2).waitUntil(.visible)
        XCTAssertTrue(gradeLabelOfAssignment1.isVisible)
        XCTAssertTrue(gradedLabelOfAssignment1.isVisible)
        XCTAssertTrue(gradeLabelOfAssignment2.isVisible)
        XCTAssertTrue(gradedLabelOfAssignment2.isVisible)
        XCTAssertTrue(gradeLabelOfAssignment1.hasLabel(label: "Grade, \(gradeOfAssignment1) out of \(Int(maxPointOfAssignment))"))
        XCTAssertTrue(gradeLabelOfAssignment2.hasLabel(label: "Grade, \(gradeOfAssignment2) out of \(Int(maxPointOfAssignment))"))
    }

    func testHiddenFinalGrade() {
        // MARK: Seed the usual stuff with 2 graded assignments
        let student = seeder.createUser()
        let course = seeder.createCourse(hide_final_grades: true)
        seeder.enrollStudent(student, in: course)
        let assignments = GradesHelper.createAssignments(course: course, count: 2)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: assignments)
        GradesHelper.gradeAssignments(grades: ["100", "100"], course: course, assignments: assignments, user: student)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        DashboardHelper.turnOnShowGrades()
        courseCard.waitUntil(.visible)
        let gradePill = DashboardHelper.courseCardGradeLabel(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)
        XCTAssertTrue(gradePill.isVisible)
        XCTAssertTrue(gradePill.hasLabel(label: "lockSolid"))

        // MARK: Navigate to grades and check if final grade is hidden
        GradesHelper.navigateToGrades(course: course)
        let lockIcon = GradesHelper.lockIcon.waitUntil(.visible)
        let totalGrade = GradesHelper.totalGrade.waitUntil(.vanish)
        XCTAssertTrue(lockIcon.isVisible)
        XCTAssertTrue(totalGrade.isVanished)
    }

    func testBasedOnGradedAssignments() {
        // MARK: Seed the usual stuff with 4 assignments (2 graded, 2 ungraded)
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let pointsPossible = [Float(10), Float(100)]
        let grades = ["5", "100"]
        let gradedAssignments = GradesHelper.createAssignments(course: course, count: 2, points_possible: pointsPossible)
        let ungradedAssignments = GradesHelper.createAssignments(course: course, count: 2, points_possible: pointsPossible)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: gradedAssignments)
        GradesHelper.createSubmissionsForAssignments(course: course, student: student, assignments: ungradedAssignments)
        GradesHelper.gradeAssignments(grades: grades, course: course, assignments: gradedAssignments, user: student)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Grades, check Total Grade, check Based On Graded Assignments switch
        let basedOnGradedExpected = "95.45"
        let notBasedOnGradedExpected = "47.73"
        GradesHelper.navigateToGrades(course: course)
        let basedOnGradedSwitch = GradesHelper.basedOnGradedSwitch.waitUntil(.visible)
        let totalGrade = GradesHelper.totalGrade.waitUntil(.visible)
        totalGrade.waitUntil(.label(expected: basedOnGradedExpected))
        XCTAssertTrue(basedOnGradedSwitch.isVisible)
        XCTAssertTrue(basedOnGradedSwitch.hasValue(value: "1"))
        XCTAssertTrue(totalGrade.isVisible)
        XCTAssertTrue(totalGrade.hasLabel(label: basedOnGradedExpected, strict: false))

        // MARK: Toggle switch, check Total Grade again
        basedOnGradedSwitch.hit()
        XCTAssertTrue(basedOnGradedSwitch.waitUntil(.value(expected: "0")).hasValue(value: "0"))
        XCTAssertTrue(totalGrade.isVisible)
        XCTAssertTrue(totalGrade.hasLabel(label: notBasedOnGradedExpected, strict: false))
    }
}
