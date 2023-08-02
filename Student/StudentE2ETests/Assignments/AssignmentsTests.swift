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
        let navBar = Helper.navBar(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(condition: .visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.label.contains(assignment.name))

        // MARK: Tap on the assignment and check details
        assignmentButton.tap()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let nameLabel = DetailsHelper.name.waitUntil(condition: .visible)
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertEqual(nameLabel.label, assignment.name)

        let pointsLabel = DetailsHelper.points.waitUntil(condition: .visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertEqual(pointsLabel.label, "0 pts")

        let statusLabel = DetailsHelper.status.waitUntil(condition: .visible)
        XCTAssertTrue(statusLabel.isVisible)
        XCTAssertEqual(statusLabel.label, "Not Submitted")

        let dueLabel = DetailsHelper.due.waitUntil(condition: .visible)
        XCTAssertTrue(dueLabel.isVisible)
        XCTAssertEqual(dueLabel.label, "No Due Date")

        let submissionTypesLabel = DetailsHelper.submissionTypes.waitUntil(condition: .visible)
        XCTAssertTrue(submissionTypesLabel.isVisible)
        XCTAssertEqual(submissionTypesLabel.label, "Text Entry")

        let submissionsButton = DetailsHelper.submissionsButton.waitUntil(condition: .visible)
        XCTAssertTrue(submissionsButton.isVisible)

        let submissionsButtonLabel = DetailsHelper.submissionsButtonLabel.waitUntil(condition: .visible)
        XCTAssertTrue(submissionsButtonLabel.isVisible)
        XCTAssertEqual(submissionsButtonLabel.label, "Submission & Rubric")

        let descriptionLabel = DetailsHelper.description(assignment: assignment).waitUntil(condition: .visible)
        XCTAssertTrue(descriptionLabel.isVisible)
        XCTAssertEqual(descriptionLabel.label, assignment.description)

        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(condition: .visible)
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
        let navBar = Helper.navBar(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(condition: .visible)
        XCTAssertTrue(assignmentButton.isVisible)
        assignmentButton.hit()

        var submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(condition: .visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
        submitAssignmentButton.hit()

        // MARK: Check visibility of elements on submission edit screen
        let submissionNavBar = SubmissionHelper.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(submissionNavBar.isVisible)

        let submissionCancelButton = SubmissionHelper.cancelButton.waitUntil(condition: .visible)
        XCTAssertTrue(submissionCancelButton.isVisible)
        XCTAssertEqual(submissionCancelButton.label, "Cancel")

        var submissionSubmitButton = SubmissionHelper.submitButton.waitUntil(condition: .visible)
        XCTAssertTrue(submissionSubmitButton.isVisible)
        XCTAssertFalse(submissionSubmitButton.isEnabled)
        XCTAssertEqual(submissionSubmitButton.label, "Submit")

        let textField = SubmissionHelper.textField.waitUntil(condition: .visible)
        XCTAssertTrue(textField.isVisible)

        // MARK: Write some text and submit the assignment
        let testText = "SubmitAssignment test"
        textField.pasteText(text: testText)

        submissionSubmitButton = SubmissionHelper.submitButton.waitUntil(condition: .visible)
        XCTAssertTrue(submissionSubmitButton.isEnabled)

        submissionSubmitButton.tap()

        // MARK: Check if submission was successful
        let successfulSubmissionLabel = DetailsHelper.successfulSubmissionLabel.waitUntil(condition: .visible)
        XCTAssertTrue(successfulSubmissionLabel.isVisible)
        XCTAssertEqual(successfulSubmissionLabel.label, "Successfully submitted!")

        submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(condition: .visible)
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
        let yesterdaysDate = Helper.getYesterdaysDateString
        let yesterdaysAssignment = Helper.createAssignment(
            course: course, name: "Yesterdays Assignment", dueDate: yesterdaysDate)

        let tomorrowsDate = Helper.getTomorrowsDateString
        let tomorrowsAssignment = Helper.createAssignment(
            course: course, name: "Tomorrows Assignment", dueDate: tomorrowsDate)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Yesterdays Assignment due date
        let yesterdaysAssignmentButton = Helper.assignmentButton(assignment: yesterdaysAssignment)
            .waitUntil(condition: .visible)
        XCTAssertTrue(yesterdaysAssignmentButton.isVisible)
        XCTAssertTrue(yesterdaysAssignmentButton.label.contains("Due Yesterday"))

        // MARK: Check Tomorrows Assignment due date
        let tomorrowsAssignmentButton = Helper.assignmentButton(assignment: tomorrowsAssignment)
            .waitUntil(condition: .visible)
        XCTAssertTrue(tomorrowsAssignmentButton.isVisible)
        XCTAssertTrue(tomorrowsAssignmentButton.label.contains("Due Tomorrow"))
    }
}
