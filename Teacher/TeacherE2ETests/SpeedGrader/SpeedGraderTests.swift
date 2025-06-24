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
import XCTest

class SpeedGraderTests: E2ETestCase {
    typealias Helper = GradesHelper
    typealias DetailsHelper = AssignmentsHelper.Details
    typealias EditorHelper = DetailsHelper.Editor
    typealias SubmissionsHelper = DetailsHelper.Submissions
    typealias SpeedGraderHelper = AssignmentsHelper.SpeedGrader

    func testOpenAndSwipeBetweenUsers() {
        var student1: DSUser!
        var student2: DSUser!
        var teacher: DSUser!
        var course: DSCourse!
        var assignment: DSAssignment!

        XCTContext.runActivity(named: "Seed two students") { _ in
            student1 = seeder.createUser(name: "DS iOS User A")
            student2 = seeder.createUser(name: "DS iOS User B")
            teacher = seeder.createUser()
            course = seeder.createCourse()
            assignment = AssignmentsHelper.createAssignment(course: course)
            seeder.enrollStudent(student1, in: course)
            seeder.enrollStudent(student2, in: course)
            seeder.enrollTeacher(teacher, in: course)
        }

        logInDSUser(teacher)

        XCTContext.runActivity(named: "Navigate to assignment's submission list") { _ in
            DashboardHelper.courseCard(course: course).waitUntil(.visible)
            AssignmentsHelper.navigateToAssignments(course: course)
            let assignmentItem = AssignmentsHelper.assignmentButton(assignment: assignment).waitUntil(.visible)
            assignmentItem.hit()
            let notSubmittedButton = DetailsHelper.notSubmittedButton.waitUntil(.visible)
            notSubmittedButton.hit()
        }

        XCTContext.runActivity(named: "Start SpeedGrader with the second student") { _ in
            let submissionItem = SubmissionsHelper.cell(student: student2).waitUntil(.visible)
            submissionItem.hit()
            XCTAssertVisible(SpeedGraderHelper.userNameLabel(user: student2).waitUntil(.visible))
            XCTAssertVisible(SpeedGraderHelper.userButton.waitUntil(.visible))
        }

        XCTContext.runActivity(named: "Check navigation bar") { _ in
            XCTAssertVisible(SpeedGraderHelper.doneButton.waitUntil(.visible))
            XCTAssertVisible(SpeedGraderHelper.postPolicyButton.waitUntil(.visible))
            XCTAssertVisible(SpeedGraderHelper.assignmentNameLabel(assignment: assignment).waitUntil(.visible))
            XCTAssertVisible(SpeedGraderHelper.courseNameLabel(course: course).waitUntil(.visible))
        }

        XCTContext.runActivity(named: "Check status picker values") { _ in
            SpeedGraderHelper.drawerGripper.hit()
            SpeedGraderHelper.statusPicker.hit()
            XCTAssertVisible(SpeedGraderHelper.GradeStatusButtons.excused.waitUntil(.visible))
            XCTAssertVisible(SpeedGraderHelper.GradeStatusButtons.late.waitUntil(.visible))
            XCTAssertVisible(SpeedGraderHelper.GradeStatusButtons.missing.waitUntil(.visible))
            XCTAssertVisible(SpeedGraderHelper.GradeStatusButtons.none.waitUntil(.visible))
            XCTAssertTrue(SpeedGraderHelper.GradeStatusButtons.none.isSelected)

        }

        XCTContext.runActivity(named: "Update days late value") { _ in
            SpeedGraderHelper.GradeStatusButtons.late.actionUntilElementCondition(action: .tap, condition: .vanish)
            let daysLateButton = SpeedGraderHelper.daysLateButton
            XCTAssertVisible(daysLateButton.waitUntil(.visible))
            XCTAssertTrue(daysLateButton.label.hasPrefix("0 days late"))

            daysLateButton.tapAt(CGPoint(x: daysLateButton.frame.width - 10, y: 20))
            let daysLateTextField = SpeedGraderHelper.daysLateTextField
            XCTAssertVisible(daysLateTextField.waitUntil(.visible))
            daysLateTextField.writeText(text: "6")
            daysLateTextField.waitUntil(.value(expected: "6"))
            XCTAssertEqual(daysLateTextField.stringValue, "6")
            SpeedGraderHelper.daysLateAlertOkButton.hit()

            daysLateButton.waitUntil(.labelHasPrefix(expected: "6 days late"))
            XCTAssertTrue(daysLateButton.label.hasPrefix("6 days late"))
        }

        XCTContext.runActivity(named: "Swipe to the first student") { _ in
            let firstUserNameLabel = SpeedGraderHelper.userNameLabel(user: student1)
            firstUserNameLabel.actionUntilElementCondition(
                action: .swipeRight(.onApp),
                condition: .visible
            )
            XCTAssertVisible(firstUserNameLabel)
        }
    }

    func testGradeAssignmentSubmission() {
        // MARK: Seed the usual stuff with a submitted assignment
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let assignment = AssignmentsHelper.createAssignment(course: course)
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)
        Helper.submitAssignment(course: course, student: student, assignment: assignment)

        // MARK: Get the user logged in, navigate to Assignments
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentItem = AssignmentsHelper.assignmentButton(assignment: assignment).waitUntil(.visible)
        let oneNeedsGradingLabel = AssignmentsHelper.oneNeedsGradingLabel(assignmentItem: assignmentItem).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(oneNeedsGradingLabel.isVisible)

        // MARK: Check Assignment Details
        assignmentItem.hit()
        let viewAllSubmissionsButton = DetailsHelper.viewAllSubmissionsButton.waitUntil(.visible)
        let needsGradingButton = DetailsHelper.oneNeedsGradingButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(needsGradingButton.isVisible)
        XCTAssertEqual(needsGradingButton.stringValue, "1 item")

        needsGradingButton.hit()
        let submissionsNavBar = SubmissionsHelper.navBar.waitUntil(.visible)
        let needsGradingLabel = SubmissionsHelper.needsGradingLabel.waitUntil(.visible)
        let submissionItem = SubmissionsHelper.cell(student: student).waitUntil(.visible)
        XCTAssertTrue(submissionsNavBar.isVisible)
        XCTAssertTrue(needsGradingLabel.isVisible)
        XCTAssertTrue(submissionItem.isVisible)

        // MARK: Grade the submitted assignment
        submissionItem.hit()
        let speedGraderUserButton = SpeedGraderHelper.userButton.waitUntil(.visible)
        let speedGraderPostPolicyButton = SpeedGraderHelper.postPolicyButton.waitUntil(.visible)
        let speedGraderDoneButton = SpeedGraderHelper.doneButton.waitUntil(.visible)
        let speedGraderDrawerGripper = SpeedGraderHelper.drawerGripper.waitUntil(.visible)
        let speedGraderGradeSlider = SpeedGraderHelper.gradeSlider.waitUntil(.visible, timeout: 5)
        XCTAssertTrue(speedGraderUserButton.isVisible)
        XCTAssertTrue(speedGraderPostPolicyButton.isVisible)
        XCTAssertTrue(speedGraderDoneButton.isVisible)

        if speedGraderGradeSlider.isVanished {
            XCTAssertTrue(speedGraderDrawerGripper.isVisible)
            speedGraderDrawerGripper.swipeUp()
        }

        let speedGraderGradeButton = SpeedGraderHelper.gradeButton.waitUntil(.visible)
        speedGraderGradeSlider.waitUntil(.visible)
        XCTAssertTrue(speedGraderGradeButton.isVisible)
        XCTAssertTrue(speedGraderGradeSlider.isVisible)
        XCTAssertEqual(speedGraderGradeSlider.stringValue, "0")

        speedGraderGradeSlider.swipeRight()
        speedGraderGradeSlider.waitUntil(.value(expected: "1"))
        XCTAssertEqual(speedGraderGradeSlider.stringValue, "1")

        speedGraderDoneButton.hit()
        submissionItem.waitUntil(.vanish)
        let backButton = SubmissionsHelper.backButton.waitUntil(.visible, timeout: 5)
        XCTAssertTrue(submissionItem.isVanished)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Check if the submission got graded
        backButton.hit()
        viewAllSubmissionsButton.waitUntil(.visible)
        let oneGradedLabel = DetailsHelper.oneGradedButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(oneGradedLabel.isVisible)
    }

    func testEditGrade() {
        // MARK: Seed the usual stuff with a submitted and graded assignment
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let assignment = AssignmentsHelper.createAssignment(course: course)
        let score = "1"
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)
        Helper.submitAssignment(course: course, student: student, assignment: assignment)
        Helper.gradeAssignment(grade: score, course: course, assignment: assignment, user: student)

        // MARK: Get the user logged in, navigate to Assignments
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentItem = AssignmentsHelper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)

        assignmentItem.hit()
        let viewAllSubmissionsButton = DetailsHelper.viewAllSubmissionsButton.waitUntil(.visible)
        let gradedButton = DetailsHelper.oneGradedButton.waitUntil(.visible)
        let editButton = DetailsHelper.editButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(gradedButton.isVisible)
        XCTAssertEqual(gradedButton.stringValue, "1 item")
        XCTAssertTrue(editButton.isVisible)

        // MARK: Edit the assignment with new score
        editButton.hit()
        let titleField = EditorHelper.titleField.waitUntil(.visible)
        let pointsField = EditorHelper.pointsField.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertEqual(titleField.stringValue, assignment.name)
        XCTAssertTrue(pointsField.isVisible)
        XCTAssertEqual(pointsField.stringValue, score)

        let newScore = "0"
        pointsField.cutText(tapSelectAll: false, tapSelect: true)
        pointsField.writeText(text: newScore)
        pointsField.waitUntil(.value(expected: newScore))
        XCTAssertEqual(pointsField.stringValue, newScore)

        let doneButton = EditorHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Check new score
        doneButton.hit()
        let pointsLabel = DetailsHelper.points.waitUntil(.visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertEqual(pointsLabel.label, "\(newScore) pts")
    }
}
