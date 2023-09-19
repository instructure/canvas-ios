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
    func testGradeAssignmentSubmission() {
        // MARK: Seed the usual stuff with a submitted assignment
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)

        let assignment = AssignmentsHelper.createAssignment(course: course)
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)

        // MARK: Get the user logged in, navigate to Assignments
        logInDSUser(teacher)
        AssignmentsHelper.navigateToAssignments(course: course)

        let assignmentItem = AssignmentsHelper.assignmentButton(assignment: assignment).waitUntil(.visible)
        let oneNeedsGradingLabel = AssignmentsHelper.oneNeedsGradingLabel(assignmentItem: assignmentItem).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)
        XCTAssertTrue(oneNeedsGradingLabel.isVisible)

        // MARK: Check Assignment Details
        assignmentItem.hit()
        let viewAllSubmissionsButton = AssignmentsHelper.Details.viewAllSubmissionsButton.waitUntil(.visible)
        let oneNeedsGradingButton = AssignmentsHelper.Details.oneNeedsGradingButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(oneNeedsGradingButton.isVisible)

        oneNeedsGradingButton.hit()

        let submissionsNavBar = AssignmentsHelper.Details.Submissions.navBar(assignment: assignment).waitUntil(.visible)
        let needsGradingLabel = AssignmentsHelper.Details.Submissions.needsGradingLabel.waitUntil(.visible)
        let submissionItem = AssignmentsHelper.Details.Submissions.cell(student: student).waitUntil(.visible)
        XCTAssertTrue(submissionsNavBar.isVisible)
        XCTAssertTrue(needsGradingLabel.isVisible)
        XCTAssertTrue(submissionItem.isVisible)

        submissionItem.hit()

        // MARK: Grade the submitted assignment
        let speedGraderUserButton = AssignmentsHelper.SpeedGrader.userButton.waitUntil(.visible)
        let speedGraderPostPolicyButton = AssignmentsHelper.SpeedGrader.postPolicyButton.waitUntil(.visible)
        let speedGraderDoneButton = AssignmentsHelper.SpeedGrader.doneButton.waitUntil(.visible)
        let speedGraderDrawerGripper = AssignmentsHelper.SpeedGrader.drawerGripper.waitUntil(.visible)
        XCTAssertTrue(speedGraderUserButton.isVisible)
        XCTAssertTrue(speedGraderPostPolicyButton.isVisible)
        XCTAssertTrue(speedGraderDoneButton.isVisible)
        XCTAssertTrue(speedGraderDrawerGripper.isVisible)

        speedGraderDrawerGripper.swipeUp()

        let speedGraderGradeButton = AssignmentsHelper.SpeedGrader.gradeButton.waitUntil(.visible)
        let speedGraderGradeSlider = AssignmentsHelper.SpeedGrader.gradeSlider.waitUntil(.visible)
        XCTAssertTrue(speedGraderGradeButton.isVisible)
        XCTAssertTrue(speedGraderGradeSlider.isVisible)
        XCTAssertTrue(speedGraderGradeSlider.hasValue(value: "0"))

        speedGraderGradeSlider.swipeRight()
        speedGraderGradeSlider.waitUntil(.value(expected: "1"))
        XCTAssertTrue(speedGraderGradeSlider.hasValue(value: "1"))

        speedGraderDoneButton.hit()
        submissionItem.waitUntil(.vanish)
        let backButton = AssignmentsHelper.Details.Submissions.backButton.waitUntil(.visible)
        XCTAssertTrue(submissionItem.isVanished)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Check if the submission got graded
        backButton.hit()
        viewAllSubmissionsButton.waitUntil(.visible)
        let oneGradedLabel = AssignmentsHelper.Details.oneGradedButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(oneGradedLabel.isVisible)
    }

    func testEditGrade() {
        // MARK: Seed the usual stuff with a submitted and graded assignment
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        seeder.enrollTeacher(teacher, in: course)

        let assignment = AssignmentsHelper.createAssignment(course: course)
        let score = "1"
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)
        GradesHelper.gradeAssignment(grade: score, course: course, assignment: assignment, user: student)

        // MARK: Get the user logged in, navigate to Assignments
        logInDSUser(teacher)
        AssignmentsHelper.navigateToAssignments(course: course)

        let assignmentItem = AssignmentsHelper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentItem.isVisible)

        assignmentItem.hit()
        let viewAllSubmissionsButton = AssignmentsHelper.Details.viewAllSubmissionsButton.waitUntil(.visible)
        let oneGradedLabel = AssignmentsHelper.Details.oneGradedButton.waitUntil(.visible)
        let editButton = AssignmentsHelper.Details.editButton.waitUntil(.visible)
        XCTAssertTrue(viewAllSubmissionsButton.isVisible)
        XCTAssertTrue(oneGradedLabel.isVisible)
        XCTAssertTrue(editButton.isVisible)

        // MARK: Edit the assignment with new score
        editButton.hit()
        let titleField = AssignmentsHelper.Details.Editor.titleField.waitUntil(.visible)
        let pointsField = AssignmentsHelper.Details.Editor.pointsField.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(titleField.hasValue(value: assignment.name))
        XCTAssertTrue(pointsField.isVisible)
        XCTAssertTrue(pointsField.hasValue(value: score))

        let newScore = "0"
        pointsField.cutText()
        pointsField.writeText(text: newScore)
        pointsField.waitUntil(.value(expected: newScore))
        XCTAssertTrue(pointsField.hasValue(value: newScore))

        let doneButton = AssignmentsHelper.Details.Editor.doneButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)

        doneButton.hit()

        // MARK: Check new score
        let pointsLabel = AssignmentsHelper.Details.points.waitUntil(.visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertTrue(pointsLabel.hasLabel(label: "\(newScore) pts"))
    }
}
