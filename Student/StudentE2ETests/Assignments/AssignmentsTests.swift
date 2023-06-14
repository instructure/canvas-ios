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

import Foundation
import TestsFoundation
import Core

class AssignmentsTests: E2ETestCase {
    func testSubmitAssignmentWithShareExtension() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create assignment for testing share extension
        let assignment = AssignmentsHelper.createAssignmentForShareExtension(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Share a photo using Canvas app share extension
        let shareSuccessful = AssignmentsHelper.sharePhotoUsingCanvasSE(course: course, assignment: assignment)
        XCTAssertTrue(shareSuccessful)
    }

    func testViewAssignmentAndDetails() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = AssignmentsHelper.createAssignment(course: course, submissionTypes: [.online_text_entry])

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments and check visibility
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentsNavBar = AssignmentsHelper.assignmentsNavBar(course: course).waitToExist()
        XCTAssertTrue(assignmentsNavBar.isVisible)

        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignment).waitToExist()
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.label().contains(assignment.name))

        // MARK: Tap on the assignment and check details
        assignmentButton.tap()
        let assignmentDetailsNavBar = AssignmentsHelper.assignmentDetailsNavBar(course: course).waitToExist()
        XCTAssertTrue(assignmentDetailsNavBar.isVisible)

        let assignmentDetailsName = AssignmentsHelper.assignmentDetailsName.waitToExist()
        XCTAssertTrue(assignmentDetailsName.isVisible)
        XCTAssertEqual(assignmentDetailsName.label(), assignment.name)

        let assignmentDetailsPoints = AssignmentsHelper.assignmentDetailsPoints.waitToExist()
        XCTAssertTrue(assignmentDetailsPoints.isVisible)
        XCTAssertEqual(assignmentDetailsPoints.label(), "0 pts")

        let assignmentDetailsStatus = AssignmentsHelper.assignmentDetailsStatus.waitToExist()
        XCTAssertTrue(assignmentDetailsStatus.isVisible)
        XCTAssertEqual(assignmentDetailsStatus.label(), "Not Submitted")

        let assignmentDetailsDue = AssignmentsHelper.assignmentDetailsDue.waitToExist()
        XCTAssertTrue(assignmentDetailsDue.isVisible)
        XCTAssertEqual(assignmentDetailsDue.label(), "No Due Date")

        let assignmentDetailsSubmissionTypes = AssignmentsHelper.assignmentDetailsSubmissionTypes.waitToExist()
        XCTAssertTrue(assignmentDetailsSubmissionTypes.isVisible)
        XCTAssertEqual(assignmentDetailsSubmissionTypes.label(), "Text Entry")

        let assignmentDetailsSubmissionsButton = AssignmentsHelper.assignmentDetailsSubmissionsButton.waitToExist()
        XCTAssertTrue(assignmentDetailsSubmissionsButton.isVisible)

        let assignmentDetailsSubmissionsButtonLabel = AssignmentsHelper.assignmentDetailsSubmissionsButtonLabel.waitToExist()
        XCTAssertTrue(assignmentDetailsSubmissionsButtonLabel.isVisible)
        XCTAssertEqual(assignmentDetailsSubmissionsButtonLabel.label(), "Submission & Rubric")

        let assignmentDetailsDescription = AssignmentsHelper.assignmentDetailsDescription.waitToExist()
        XCTAssertTrue(assignmentDetailsDescription.isVisible)
        XCTAssertEqual(assignmentDetailsDescription.label(), assignment.description)

        let assignmentDetailsSubmitAssignmentButton = AssignmentsHelper.assignmentDetailsSubmitAssignmentButton.waitToExist()
        XCTAssertTrue(assignmentDetailsSubmitAssignmentButton.isVisible)
    }

    func testSubmitAssignment() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = AssignmentsHelper.createAssignment(course: course, submissionTypes: [.online_text_entry])

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments and tap the assignment
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentsNavBar = AssignmentsHelper.assignmentsNavBar(course: course).waitToExist()
        XCTAssertTrue(assignmentsNavBar.isVisible)

        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignment).waitToExist()
        XCTAssertTrue(assignmentButton.isVisible)
        assignmentButton.tap()

        var assignmentDetailsSubmitAssignmentButton = AssignmentsHelper.assignmentDetailsSubmitAssignmentButton.waitToExist()
        XCTAssertTrue(assignmentDetailsSubmitAssignmentButton.isVisible)
        assignmentDetailsSubmitAssignmentButton.tap()

        // MARK: Check visibility of elements on submission edit screen
        let assignmentSubmissionTextEntryNavBar = AssignmentsHelper.assignmentSubmissionTextEntryNavBar.waitToExist()
        XCTAssertTrue(assignmentSubmissionTextEntryNavBar.isVisible)

        let assignmentSubmissionCancelButton = AssignmentsHelper.assignmentSubmissionCancelButton.waitToExist()
        XCTAssertTrue(assignmentSubmissionCancelButton.isVisible)
        XCTAssertEqual(assignmentSubmissionCancelButton.label(), "Cancel")

        var assignmentSubmissionSubmitButton = AssignmentsHelper.assignmentSubmissionSubmitButton.waitToExist()
        XCTAssertTrue(assignmentSubmissionSubmitButton.isVisible)
        XCTAssertFalse(assignmentSubmissionSubmitButton.isEnabled)
        XCTAssertEqual(assignmentSubmissionSubmitButton.label(), "Submit")

        let assignmentSubmissionEditor = AssignmentsHelper.assignmentSubmissionEditor.waitToExist()
        XCTAssertTrue(assignmentSubmissionEditor.isVisible)

        // MARK: Write some text and submit the assignment
        let testText = "SubmitAssignment test"
        assignmentSubmissionEditor.pasteText(testText)

        assignmentSubmissionSubmitButton = AssignmentsHelper.assignmentSubmissionSubmitButton.waitToExist()
        XCTAssertTrue(assignmentSubmissionSubmitButton.isEnabled)

        assignmentSubmissionSubmitButton.tap()

        // MARK: Check if submission was successful
        let assignmentDetailsSuccessfulSubmission = AssignmentsHelper.assignmentDetailsSuccessfulSubmission.waitToExist()
        XCTAssertTrue(assignmentDetailsSuccessfulSubmission.isVisible)
        XCTAssertEqual(assignmentDetailsSuccessfulSubmission.label(), "Successfully submitted!")

        assignmentDetailsSubmitAssignmentButton = AssignmentsHelper.assignmentDetailsSubmitAssignmentButton.waitToExist()
        XCTAssertTrue(assignmentDetailsSubmitAssignmentButton.isVisible)
        XCTAssertEqual(assignmentDetailsSubmitAssignmentButton.label(), "Resubmit Assignment")
    }
}
