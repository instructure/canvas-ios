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

class AssignmentsTests: E2ETestCase {
    typealias Helper = AssignmentsHelper
    typealias DetailsHelper = Helper.Details
    typealias SubmissionHelper = Helper.Submission

    func testSubmitAssignmentWithShareExtension() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create assignment for testing share extension
        let assignment = Helper.createAssignmentForShareExtension(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Share a photo using Canvas app share extension
        let shareSuccessful = Helper.sharePhotoUsingCanvasSE(course: course, assignment: assignment)
        XCTAssertTrue(shareSuccessful)
    }

    func testViewAssignmentAndDetails() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry])

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.label.contains(assignment.name))

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let nameLabel = DetailsHelper.name.waitUntil(.visible)
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertEqual(nameLabel.label, assignment.name)

        let pointsLabel = DetailsHelper.points.waitUntil(.visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertEqual(pointsLabel.label, "\(assignment.points_possible!) pt")

        let statusLabel = DetailsHelper.status.waitUntil(.visible)
        XCTAssertTrue(statusLabel.isVisible)
        XCTAssertEqual(statusLabel.label, "Not Submitted")

        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertTrue(dueLabel.isVisible)
        XCTAssertEqual(dueLabel.label, "No Due Date")

        let submissionTypesLabel = DetailsHelper.submissionTypes.waitUntil(.visible)
        XCTAssertTrue(submissionTypesLabel.isVisible)
        XCTAssertEqual(submissionTypesLabel.label, "Text Entry")

        let submissionsButton = DetailsHelper.submissionsButton.waitUntil(.visible)
        XCTAssertTrue(submissionsButton.isVisible)

        let submissionsButtonLabel = DetailsHelper.submissionsButtonLabel.waitUntil(.visible)
        XCTAssertTrue(submissionsButtonLabel.isVisible)
        XCTAssertEqual(submissionsButtonLabel.label, "Submission & Rubric")

        let descriptionLabel = DetailsHelper.description(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(descriptionLabel.isVisible)
        XCTAssertEqual(descriptionLabel.label, assignment.description)

        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
    }

    func testSubmitAssignment() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry])

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments and tap the assignment
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        assignmentButton.hit()

        var submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
        submitAssignmentButton.hit()

        // MARK: Check visibility of elements on submission edit screen
        let submissionNavBar = SubmissionHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(submissionNavBar.isVisible)

        let submissionCancelButton = SubmissionHelper.cancelButton.waitUntil(.visible)
        XCTAssertTrue(submissionCancelButton.isVisible)
        XCTAssertEqual(submissionCancelButton.label, "Cancel")

        var submissionSubmitButton = SubmissionHelper.submitButton.waitUntil(.visible)
        XCTAssertTrue(submissionSubmitButton.isVisible)
        XCTAssertFalse(submissionSubmitButton.isEnabled)
        XCTAssertEqual(submissionSubmitButton.label, "Submit")

        let textField = SubmissionHelper.textField.waitUntil(.visible)
        XCTAssertTrue(textField.isVisible)

        // MARK: Write some text and submit the assignment
        let testText = "SubmitAssignment test"
        textField.pasteText(text: testText)

        submissionSubmitButton = SubmissionHelper.submitButton.waitUntil(.visible)
        XCTAssertTrue(submissionSubmitButton.isEnabled)

        submissionSubmitButton.hit()

        // MARK: Check if submission was successful
        let successfulSubmissionLabel = DetailsHelper.successfulSubmissionLabel.waitUntil(.visible)
        XCTAssertTrue(successfulSubmissionLabel.isVisible)
        XCTAssertEqual(successfulSubmissionLabel.label, "Successfully submitted!")

        submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
        XCTAssertEqual(submitAssignmentButton.label, "Resubmit Assignment")
    }

    func testAssignmentDueDate() {
        // MARK: Seed the usual stuff
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // MARK: Create 2 assignments (1 due yesterday and 1 due tomorrow)
        let yesterdaysDate = Date.now.addDays(-1)
        let yesterdaysAssignment = Helper.createAssignment(
            course: course, name: "Yesterdays Assignment", dueDate: yesterdaysDate)

        let tomorrowsDate = Date.now.addDays(1)
        let tomorrowsAssignment = Helper.createAssignment(
            course: course, name: "Tomorrows Assignment", dueDate: tomorrowsDate)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Yesterdays Assignment due date
        let yesterdaysAssignmentButton = Helper.assignmentButton(assignment: yesterdaysAssignment)
            .waitUntil(.visible)
        XCTAssertTrue(yesterdaysAssignmentButton.isVisible)
        XCTAssertTrue(yesterdaysAssignmentButton.label.contains("Due Yesterday"))

        // MARK: Check Tomorrows Assignment due date
        let tomorrowsAssignmentButton = Helper.assignmentButton(assignment: tomorrowsAssignment)
            .waitUntil(.visible)
        XCTAssertTrue(tomorrowsAssignmentButton.isVisible)
        XCTAssertTrue(tomorrowsAssignmentButton.label.contains("Due Tomorrow"))
    }
}
