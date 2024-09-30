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
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create assignment for testing share extension
        let assignment = Helper.createAssignmentForShareExtension(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Share a photo using Canvas app share extension
        let shareSuccessful = Helper.sharePhotoUsingCanvasSE(course: course, assignment: assignment)
        XCTAssertTrue(shareSuccessful)
    }

    func testViewAssignmentAndDetails() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry])

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.hasLabel(label: assignment.name, strict: false))

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let nameLabel = DetailsHelper.name.waitUntil(.visible)
        XCTAssertTrue(nameLabel.isVisible)
        XCTAssertTrue(nameLabel.hasLabel(label: assignment.name))

        let pointsLabel = DetailsHelper.points.waitUntil(.visible)
        XCTAssertTrue(pointsLabel.isVisible)
        XCTAssertTrue(pointsLabel.hasLabel(label: "\(assignment.points_possible!) pt"))

        let statusLabel = DetailsHelper.status.waitUntil(.visible)
        XCTAssertTrue(statusLabel.isVisible)
        XCTAssertTrue(statusLabel.hasLabel(label: "Not Submitted"))

        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertTrue(dueLabel.isVisible)
        XCTAssertTrue(dueLabel.hasLabel(label: "No Due Date"))

        let submissionTypesLabel = DetailsHelper.submissionTypes.waitUntil(.visible)
        XCTAssertTrue(submissionTypesLabel.isVisible)
        XCTAssertTrue(submissionTypesLabel.hasLabel(label: "Text Entry"))

        let descriptionLabel = DetailsHelper.description(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(descriptionLabel.isVisible)
        XCTAssertTrue(descriptionLabel.hasLabel(label: assignment.description!))

        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
        XCTAssertTrue(submitAssignmentButton.hasLabel(label: "Submit Assignment"))

        let submissionButton = DetailsHelper.submissionAndRubricButton.waitUntil(.visible)
        XCTAssertTrue(submissionButton.isVisible)

        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)
        pullToRefresh()
        XCTAssertTrue(statusLabel.waitUntil(.visible).hasLabel(label: "Submitted"))

        XCTAssertTrue(submitAssignmentButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(submitAssignmentButton.hasLabel(label: "Resubmit Assignment"))
    }

    func testSubmitAssignment() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry])

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and tap the assignment
        Helper.navigateToAssignments(course: course)
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        assignmentButton.hit()

        var submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
        submitAssignmentButton.hit()

        // MARK: Check visibility of elements on submission edit screen
        let submissionCancelButton = SubmissionHelper.cancelButton.waitUntil(.visible)
        XCTAssertTrue(submissionCancelButton.isVisible)
        XCTAssertTrue(submissionCancelButton.hasLabel(label: "Cancel"))

        var submissionSubmitButton = SubmissionHelper.submitButton.waitUntil(.visible)
        XCTAssertTrue(submissionSubmitButton.isVisible)
        XCTAssertTrue(submissionSubmitButton.isDisabled)
        XCTAssertTrue(submissionSubmitButton.hasLabel(label: "Submit"))

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
        XCTAssertTrue(successfulSubmissionLabel.hasLabel(label: "Successfully submitted!"))

        submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
        XCTAssertTrue(submitAssignmentButton.hasLabel(label: "Resubmit Assignment"))
    }

    func testAssignmentDueDate() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create 2 assignments (1 due yesterday and 1 due tomorrow)
        let yesterdaysDate = Date.now.addDays(-1)
        let yesterdaysAssignment = Helper.createAssignment(course: course, name: "Yesterdays Assignment", dueDate: yesterdaysDate)

        let tomorrowsDate = Date.now.addDays(1)
        let tomorrowsAssignment = Helper.createAssignment(course: course, name: "Tomorrows Assignment", dueDate: tomorrowsDate)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Yesterdays Assignment due date
        let yesterdaysAssignmentButton = Helper.assignmentButton(assignment: yesterdaysAssignment).waitUntil(.visible)
        XCTAssertTrue(yesterdaysAssignmentButton.isVisible)
        XCTAssertTrue(yesterdaysAssignmentButton.hasLabel(label: "Due Yesterday", strict: false))

        // MARK: Check Tomorrows Assignment due date
        let tomorrowsAssignmentButton = Helper.assignmentButton(assignment: tomorrowsAssignment).waitUntil(.visible)
        XCTAssertTrue(tomorrowsAssignmentButton.isVisible)
        XCTAssertTrue(tomorrowsAssignmentButton.hasLabel(label: "Due Tomorrow", strict: false))
    }

    func testLockedAssignment() {
        // MARK: Seed the usual stuff with a locked assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let lockedAssignment = Helper.createAssignment(
            course: course,
            name: "Locked Assignment",
            dueDate: Date.now.addDays(-1),
            lockAt: Date.now)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Locked Assignment
        let lockedAssignmentButton = Helper.assignmentButton(assignment: lockedAssignment).waitUntil(.visible)
        XCTAssertTrue(lockedAssignmentButton.isVisible)
        XCTAssertTrue(lockedAssignmentButton.hasLabel(label: "Availability: Closed", strict: false))

        lockedAssignmentButton.hit()
        let lockSectionElement = DetailsHelper.lockSection.waitUntil(.visible)
        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.vanish)
        XCTAssertTrue(lockSectionElement.isVisible)
        XCTAssertTrue(submitAssignmentButton.isVanished)
    }

    func testFutureAssignment() {
        // MARK: Seed the usual stuff with a future assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let futureAssignment = Helper.createAssignment(
            course: course,
            name: "Future Assignment",
            dueDate: Date.now.addDays(3),
            unlockAt: Date.now.addDays(1))

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Future Assignment
        let futureAssignmentButton = Helper.assignmentButton(assignment: futureAssignment).waitUntil(.visible)
        XCTAssertTrue(futureAssignmentButton.isVisible)

        futureAssignmentButton.hit()
        let lockIcon = DetailsHelper.lockIcon.waitUntil(.visible)
        let lockSectionElement = DetailsHelper.lockSection.waitUntil(.visible)
        let isLockedLabel = DetailsHelper.isLockedLabel.waitUntil(.visible)
        let pandaLockedImage = DetailsHelper.pandaLockedImage.waitUntil(.visible)
        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.vanish)
        XCTAssertTrue(lockIcon.isVisible)
        XCTAssertTrue(lockSectionElement.isVisible)
        XCTAssertTrue(isLockedLabel.isVisible)
        XCTAssertTrue(pandaLockedImage.isVisible)
        XCTAssertTrue(submitAssignmentButton.isVanished)
    }

    func testExcusedStatus() {
        // MARK: Seed the usual stuff with an assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let assignment = Helper.createAssignment(course: course)
        GradesHelper.excuseStudentFromAssignment(course: course, assignment: assignment, user: student)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Assignment
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)

        assignmentButton.hit()
        let excusedLabel = DetailsHelper.gradeDisplayGrade.waitUntil(.visible)
        XCTAssertTrue(excusedLabel.isVisible)
        XCTAssertTrue(excusedLabel.hasLabel(label: "Excused"))
    }

    func testAttemptSelectorAndSubmissionAndRubricScreen() {
        // MARK: Seed the usual stuff with an assignment
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let assignment = Helper.createAssignment(course: course)
        let rubric = Helper.createRubric(in: course, rubricAssociationId: assignment.id, rubricAssociationType: .assignment)
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)
        sleep(1)
        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check Assignment
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)

        // MARK: Check ViewSubmissions
        assignmentButton.hit()
        let viewSubmissionButton = DetailsHelper.viewSubmissionButton.waitUntil(.visible)
        XCTAssertTrue(viewSubmissionButton.isVisible)

        viewSubmissionButton.hit()
        let commentsButton = DetailsHelper.SubmissionComments.commentsButton.waitUntil(.visible)
        let filesButton = DetailsHelper.SubmissionComments.filesButton.waitUntil(.visible)
        let rubricButton = DetailsHelper.SubmissionComments.rubricButton.waitUntil(.visible)
        let addMediaButton = DetailsHelper.SubmissionComments.addMediaButton.waitUntil(.visible)
        let addCommentButton = DetailsHelper.SubmissionComments.addCommentButton.waitUntil(.visible)
        let drawerGripper = DetailsHelper.SubmissionDetails.drawerGripper.waitUntil(.visible)
        let commentTextView = DetailsHelper.SubmissionComments.commentTextView.waitUntil(.visible)
        XCTAssertTrue(commentsButton.isVisible)
        XCTAssertTrue(filesButton.isVisible)
        XCTAssertTrue(rubricButton.isVisible)
        XCTAssertTrue(addMediaButton.isVisible)
        XCTAssertTrue(addCommentButton.isVisible)
        XCTAssertTrue(addCommentButton.isDisabled)
        XCTAssertTrue(drawerGripper.isVisible)
        XCTAssertTrue(commentTextView.isVisible)

        // MARK: Check attemptSelector
        drawerGripper.tapAndHoldAndDragToElement(element: commentTextView)
        let attemptPickerToggle = DetailsHelper.SubmissionDetails.attemptPickerToggle.waitUntil(.visible)
        XCTAssertTrue(attemptPickerToggle.isVisible)

        attemptPickerToggle.hit()
        let attemptPicker = DetailsHelper.SubmissionDetails.attemptPicker.waitUntil(.visible)
        let pickerWheel = DetailsHelper.SubmissionDetails.pickerWheel.waitUntil(.visible)
        XCTAssertTrue(attemptPicker.isVisible)
        XCTAssertTrue(pickerWheel.isVisible)
        XCTAssertTrue(pickerWheel.hasValue(value: "Attempt 2", strict: false))

        pickerWheel.tapAndHoldAndDragToElement(element: attemptPickerToggle)
        XCTAssertTrue(pickerWheel.hasValue(value: "Attempt 1", strict: false))

        // MARK: Check adding a comment
        attemptPickerToggle.hit()
        drawerGripper.tapAndHoldAndDragToElement(element: attemptPickerToggle)
        commentTextView.writeText(text: "Test Comment")
        XCTAssertTrue(addCommentButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(addCommentButton.isEnabled)

        addCommentButton.hit()
        let chatBubble = DetailsHelper.SubmissionComments.chatBubble.waitUntil(.visible)
        XCTAssertTrue(chatBubble.isVisible)

        // MARK: Check rubric
        rubricButton.hit()
        let rubricTitle = DetailsHelper.SubmissionComments.rubricTitle(rubric: rubric).waitUntil(.visible)
        let rubricDescriptionButton = DetailsHelper.SubmissionComments.rubricDescriptionButton(rubric: rubric).waitUntil(.visible)
        let rubricRatingZero = DetailsHelper.SubmissionComments.rubricRatingButton(rubric: rubric, index: 0).waitUntil(.visible)
        let rubricRatingOne = DetailsHelper.SubmissionComments.rubricRatingButton(rubric: rubric, index: 1).waitUntil(.visible)
        XCTAssertTrue(rubricTitle.isVisible)
        XCTAssertTrue(rubricDescriptionButton.isVisible)
        XCTAssertTrue(rubricRatingZero.isVisible)
        XCTAssertTrue(rubricRatingOne.isVisible)
        XCTAssertTrue(rubricRatingZero.hasLabel(label: rubric.data[0].ratings[1].description, strict: false))
        XCTAssertTrue(rubricRatingOne.hasLabel(label: rubric.data[0].ratings[0].description, strict: false))

        rubricRatingOne.hit()
        let rubricRatingTitle = DetailsHelper.SubmissionComments.rubricRatingTitle(rubric: rubric).waitUntil(.visible)
        XCTAssertTrue(rubricRatingTitle.isVisible)
        XCTAssertTrue(rubricRatingTitle.hasLabel(label: rubric.data[0].ratings[0].description))

        rubricRatingZero.hit()
        XCTAssertTrue(rubricRatingTitle.waitUntil(.visible).isVisible)
        XCTAssertTrue(rubricRatingTitle.hasLabel(label: rubric.data[0].ratings[1].description))

        rubricDescriptionButton.hit()
        let rubricLongDescriptionLabel = DetailsHelper.SubmissionComments
            .rubricLongDescriptionLabel(rubric: rubric).waitUntil(.visible)
        XCTAssertTrue(rubricLongDescriptionLabel.isVisible)
    }

    // Covers MBL-17735
    func testRestrictedSubmissionTypesDoesNotAllowStudio() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_upload], allowedExtensions: ["pdf"])

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and tap the assignment
        Helper.navigateToAssignments(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        assignmentButton.hit()

        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertTrue(submitAssignmentButton.isVisible)
        submitAssignmentButton.hit()

        // MARK: Check elements and if Studio is not available
        let pandaFilePicker = SubmissionHelper.pandaFilePicker.waitUntil(.visible)
        let filesButton = SubmissionHelper.filesButton.waitUntil(.visible)
        let studioLabel = SubmissionHelper.studioLabel.waitUntil(.vanish)
        XCTAssertTrue(pandaFilePicker.isVisible)
        XCTAssertTrue(filesButton.isVisible)
        XCTAssertTrue(studioLabel.isVanished)
    }
}
