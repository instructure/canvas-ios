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
    typealias DetailsHelper = AssignmentsHelper.Details
    typealias EditorHelper = DetailsHelper.Editor
    typealias SubmissionsHelper = DetailsHelper.Submissions
    typealias SpeedGraderHelper = AssignmentsHelper.SpeedGrader

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
        let oneNeedsGradingButton = DetailsHelper.oneNeedsGradingButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(oneNeedsGradingButton.isVisible)

        oneNeedsGradingButton.hit()
        let submissionsNavBar = SubmissionsHelper.navBar(assignment: assignment).waitUntil(.visible)
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
        XCTAssertTrue(speedGraderGradeSlider.hasValue(value: "0"))

        speedGraderGradeSlider.swipeRight()
        speedGraderGradeSlider.waitUntil(.value(expected: "1"))
        XCTAssertTrue(speedGraderGradeSlider.hasValue(value: "1"))

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
        let oneGradedLabel = DetailsHelper.oneGradedButton.waitUntil(.visible)
        let editButton = DetailsHelper.editButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(oneGradedLabel.isVisible)
        XCTAssertTrue(editButton.isVisible)

        // MARK: Edit the assignment with new score
        editButton.hit()
        let titleField = EditorHelper.titleField.waitUntil(.visible)
        let pointsField = EditorHelper.pointsField.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(titleField.hasValue(value: assignment.name))
        XCTAssertTrue(pointsField.isVisible)
        XCTAssertTrue(pointsField.hasValue(value: score))

        let newScore = "0"
        pointsField.cutText()
        pointsField.writeText(text: newScore)
        pointsField.waitUntil(.value(expected: newScore))
        XCTAssertTrue(pointsField.hasValue(value: newScore))

        let doneButton = EditorHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Check new score
        doneButton.hit()
        let pointsLabel = DetailsHelper.points.waitUntil(.visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertTrue(pointsLabel.hasLabel(label: "\(newScore) pts"))
    }
}
