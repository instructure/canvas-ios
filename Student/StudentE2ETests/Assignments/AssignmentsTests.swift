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
        typealias Helper = AssignmentsHelper

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
        typealias Helper = AssignmentsHelper
        typealias DetailsHelper = Helper.Details

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
        let navBar = Helper.navBar(course: course).waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitToExist()
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.label().contains(assignment.name))

        // MARK: Tap on the assignment and check details
        assignmentButton.tap()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitToExist()
        XCTAssertTrue(detailsNavBar.isVisible)

        let nameLabel = DetailsHelper.name.waitToExist()
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertEqual(nameLabel.label(), assignment.name)

        let pointsLabel = DetailsHelper.points.waitToExist()
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertEqual(pointsLabel.label(), "0 pts")

        let statusLabel = DetailsHelper.status.waitToExist()
        XCTAssertTrue(statusLabel.isVisible)
        XCTAssertEqual(statusLabel.label(), "Not Submitted")

        let dueLabel = DetailsHelper.due.waitToExist()
        XCTAssertTrue(dueLabel.isVisible)
        XCTAssertEqual(dueLabel.label(), "No Due Date")

        let submissionTypesLabel = DetailsHelper.submissionTypes.waitToExist()
        XCTAssertTrue(submissionTypesLabel.isVisible)
        XCTAssertEqual(submissionTypesLabel.label(), "Text Entry")

        let submissionsButton = DetailsHelper.submissionsButton.waitToExist()
        XCTAssertTrue(submissionsButton.isVisible)

        let submissionsButtonLabel = DetailsHelper.submissionsButtonLabel.waitToExist()
        XCTAssertTrue(submissionsButtonLabel.isVisible)
        XCTAssertEqual(submissionsButtonLabel.label(), "Submission & Rubric")

        let descriptionLabel = DetailsHelper.description.waitToExist()
        XCTAssertTrue(descriptionLabel.isVisible)
        XCTAssertEqual(descriptionLabel.label(), assignment.description)

        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitToExist()
        XCTAssertTrue(submitAssignmentButton.isVisible)
    }

    func testSubmitAssignment() {
        typealias Helper = AssignmentsHelper
        typealias DetailsHelper = Helper.Details
        typealias SubmissionHelper = Helper.Submission

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
        let navBar = Helper.navBar(course: course).waitToExist()
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitToExist()
        XCTAssertTrue(assignmentButton.isVisible)
        assignmentButton.tap()

        var submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitToExist()
        XCTAssertTrue(submitAssignmentButton.isVisible)
        submitAssignmentButton.tap()

        // MARK: Check visibility of elements on submission edit screen
        let submissionNavBar = SubmissionHelper.navBar.waitToExist()
        XCTAssertTrue(submissionNavBar.isVisible)

        let submissionCancelButton = SubmissionHelper.cancelButton.waitToExist()
        XCTAssertTrue(submissionCancelButton.isVisible)
        XCTAssertEqual(submissionCancelButton.label(), "Cancel")

        var submissionSubmitButton = SubmissionHelper.submitButton.waitToExist()
        XCTAssertTrue(submissionSubmitButton.isVisible)
        XCTAssertFalse(submissionSubmitButton.isEnabled)
        XCTAssertEqual(submissionSubmitButton.label(), "Submit")

        let textField = SubmissionHelper.textField.waitToExist()
        XCTAssertTrue(textField.isVisible)

        // MARK: Write some text and submit the assignment
        let testText = "SubmitAssignment test"
        textField.pasteText(testText)

        submissionSubmitButton = SubmissionHelper.submitButton.waitToExist()
        XCTAssertTrue(submissionSubmitButton.isEnabled)

        submissionSubmitButton.tap()

        // MARK: Check if submission was successful
        let successfulSubmissionLabel = DetailsHelper.successfulSubmissionLabel.waitToExist()
        XCTAssertTrue(successfulSubmissionLabel.isVisible)
        XCTAssertEqual(successfulSubmissionLabel.label(), "Successfully submitted!")

        submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitToExist()
        XCTAssertTrue(submitAssignmentButton.isVisible)
        XCTAssertEqual(submitAssignmentButton.label(), "Resubmit Assignment")
    }

    func testAssignmentDueDate() {
        typealias Helper = AssignmentsHelper

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
        let navBar = Helper.navBar(course: course).waitToExist()
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Yesterdays Assignment due date
        let yesterdaysAssignmentButton = Helper.assignmentButton(assignment: yesterdaysAssignment).waitToExist()
        XCTAssertTrue(yesterdaysAssignmentButton.isVisible)
        XCTAssertTrue(yesterdaysAssignmentButton.label().contains("Due Yesterday"))

        // MARK: Check Tomorrows Assignment due date
        let tomorrowsAssignmentButton = Helper.assignmentButton(assignment: tomorrowsAssignment).waitToExist()
        XCTAssertTrue(tomorrowsAssignmentButton.isVisible)
        XCTAssertTrue(tomorrowsAssignmentButton.label().contains("Due Tomorrow"))
    }
}
