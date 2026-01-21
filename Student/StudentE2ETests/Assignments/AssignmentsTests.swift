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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        assertNavbarVisible(course: course)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(assignmentButton)
        XCTAssertContains(assignmentButton.label, assignment.name)

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let nameLabel = DetailsHelper.name.waitUntil(.visible)
        XCTAssertVisible(nameLabel)
        XCTAssertEqual(nameLabel.label, assignment.name)

        let pointsLabel = DetailsHelper.points.waitUntil(.visible)
        XCTAssertVisible(pointsLabel)
        XCTAssertEqual(pointsLabel.label, "\(assignment.points_possible!) pt")

        let statusLabel = DetailsHelper.status.waitUntil(.visible)
        XCTAssertVisible(statusLabel)
        XCTAssertEqual(statusLabel.label, "Not Submitted")

        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertVisible(dueLabel)
        XCTAssertEqual(dueLabel.label, "No Due Date")

        let submissionTypesLabel = DetailsHelper.submissionTypes.waitUntil(.visible)
        XCTAssertVisible(submissionTypesLabel)
        XCTAssertEqual(submissionTypesLabel.label, "Text Entry")

        let descriptionLabel = DetailsHelper.description(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(descriptionLabel)
        XCTAssertEqual(descriptionLabel.label, assignment.description!)

        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertVisible(submitAssignmentButton)
        XCTAssertEqual(submitAssignmentButton.label, "Submit Assignment")

        let submissionButton = DetailsHelper.submissionAndRubricButton.waitUntil(.visible)
        XCTAssertVisible(submissionButton)

        GradesHelper.submitAssignment(course: course, student: student, assignment: assignment)
        app.pullToRefresh()
        XCTAssertEqual(statusLabel.waitUntil(.visible).label, "Submitted")

        XCTAssertVisible(submitAssignmentButton.waitUntil(.visible))
        XCTAssertEqual(submitAssignmentButton.label, "Resubmit Assignment")
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments and tap the assignment
        Helper.navigateToAssignments(course: course)
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(assignmentButton)
        assignmentButton.hit()

        var submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertVisible(submitAssignmentButton)
        // simply `hit()` does not register sometimes, even if the button is there
        submitAssignmentButton.actionUntilElementCondition(
            action: .tap,
            element: SubmissionHelper.cancelButton,
            condition: .visible,
            gracePeriod: 2
        )

        // MARK: Check visibility of elements on submission edit screen
        let submissionCancelButton = SubmissionHelper.cancelButton.waitUntil(.visible)
        XCTAssertVisible(submissionCancelButton)
        XCTAssertEqual(submissionCancelButton.label, "Cancel")

        var submissionSubmitButton = SubmissionHelper.submitButton.waitUntil(.visible)
        XCTAssertVisible(submissionSubmitButton)
        XCTAssertTrue(submissionSubmitButton.isDisabled)
        XCTAssertEqual(submissionSubmitButton.label, "Submit")

        let textView = SubmissionHelper.textView.waitUntil(.visible)
        XCTAssertVisible(textView)

        // MARK: Write some text and submit the assignment
        let testText = "SubmitAssignment test"
        textView.writeText(text: testText)

        submissionSubmitButton = SubmissionHelper.submitButton.waitUntil(.visible)
        XCTAssertTrue(submissionSubmitButton.isEnabled)

        submissionSubmitButton.hit()

        // MARK: Check if submission was successful
        let successfulSubmissionLabel = DetailsHelper.successfulSubmissionLabel.waitUntil(.visible)
        XCTAssertVisible(successfulSubmissionLabel)
        XCTAssertEqual(successfulSubmissionLabel.label, "Successfully submitted!")

        submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertVisible(submitAssignmentButton)
        XCTAssertEqual(submitAssignmentButton.label, "Resubmit Assignment")
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        assertNavbarVisible(course: course)

        // MARK: Check Yesterdays Assignment due date
        let yesterdaysAssignmentButton = Helper.assignmentButton(assignment: yesterdaysAssignment).waitUntil(.visible)
        XCTAssertVisible(yesterdaysAssignmentButton)
        XCTAssertContains(yesterdaysAssignmentButton.label, "Due Yesterday")

        // MARK: Check Tomorrows Assignment due date
        let tomorrowsAssignmentButton = Helper.assignmentButton(assignment: tomorrowsAssignment).waitUntil(.visible)
        XCTAssertVisible(tomorrowsAssignmentButton)
        XCTAssertContains(tomorrowsAssignmentButton.label, "Due Tomorrow")
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        assertNavbarVisible(course: course)

        // MARK: Check Locked Assignment
        let lockedAssignmentButton = Helper.assignmentButton(assignment: lockedAssignment).waitUntil(.visible)
        XCTAssertVisible(lockedAssignmentButton)
        XCTAssertContains(lockedAssignmentButton.label, "Closed For Submission")

        lockedAssignmentButton.hit()
        let lockSectionElement = DetailsHelper.lockSection.waitUntil(.visible)
        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.vanish)
        XCTAssertVisible(lockSectionElement)
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        assertNavbarVisible(course: course)

        // MARK: Check Future Assignment
        let futureAssignmentButton = Helper.assignmentButton(assignment: futureAssignment).waitUntil(.visible)
        XCTAssertVisible(futureAssignmentButton)

        futureAssignmentButton.hit()
        let lockIcon = DetailsHelper.lockIcon.waitUntil(.visible)
        let lockSectionElement = DetailsHelper.lockSection.waitUntil(.visible)
        let isLockedLabel = DetailsHelper.isLockedLabel.waitUntil(.visible)
        let pandaLockedImage = DetailsHelper.pandaLockedImage.waitUntil(.visible)
        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.vanish)
        XCTAssertVisible(lockIcon)
        XCTAssertVisible(lockSectionElement)
        XCTAssertVisible(isLockedLabel)
        XCTAssertVisible(pandaLockedImage)
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        assertNavbarVisible(course: course)

        // MARK: Check Assignment
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(assignmentButton)

        assignmentButton.hit()
        let excusedLabel = DetailsHelper.gradeDisplayGrade.waitUntil(.visible)
        XCTAssertVisible(excusedLabel)
        XCTAssertEqual(excusedLabel.label, "Excused")
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments
        Helper.navigateToAssignments(course: course)
        assertNavbarVisible(course: course)

        // MARK: Check Assignment
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(assignmentButton)

        // MARK: Check ViewSubmissions
        assignmentButton.hit()
        let viewSubmissionButton = DetailsHelper.viewSubmissionButton.waitUntil(.visible)
        XCTAssertVisible(viewSubmissionButton)

        viewSubmissionButton.hit()
        let commentsButton = DetailsHelper.SubmissionComments.commentsButton.waitUntil(.visible)
        let filesButton = DetailsHelper.SubmissionComments.filesButton.waitUntil(.visible)
        let rubricButton = DetailsHelper.SubmissionComments.rubricButton.waitUntil(.visible)
        let addMediaButton = DetailsHelper.SubmissionComments.addMediaButton.waitUntil(.visible)
        let addCommentButton = DetailsHelper.SubmissionComments.addCommentButton.waitUntil(.visible)
        let drawerGripper = DetailsHelper.SubmissionDetails.drawerGripper.waitUntil(.visible)
        let commentTextView = DetailsHelper.SubmissionComments.commentTextView.waitUntil(.visible)
        XCTAssertVisible(commentsButton)
        XCTAssertVisible(filesButton)
        XCTAssertVisible(rubricButton)
        XCTAssertVisible(addMediaButton)
        XCTAssertVisible(addCommentButton)
        XCTAssertTrue(addCommentButton.isDisabled)
        XCTAssertVisible(drawerGripper)
        XCTAssertVisible(commentTextView)

        // MARK: Check attemptSelector
        let attemptPicker = DetailsHelper.SubmissionDetails.attemptPicker.waitUntil(.visible)
        XCTAssert(attemptPicker.isVisible)
        XCTAssertHasPrefix(attemptPicker.label, "Attempt 2")

        attemptPicker.tap()
        let attemptPickerItems = DetailsHelper.SubmissionDetails.attemptPickerItems.map { $0.waitUntil(.visible) }
        if attemptPickerItems.count == 2 {
            XCTAssert(attemptPickerItems[0].label.contains("Attempt 2"))
            XCTAssert(attemptPickerItems[0].isSelected)
            XCTAssert(attemptPickerItems[1].label.contains("Attempt 1"))
            XCTAssert(attemptPickerItems[1].isUnselected)

            attemptPickerItems[1].tap()
            attemptPicker.waitUntil(.visible)
            XCTAssertHasPrefix(attemptPicker.label, "Attempt 1")
        } else {
            XCTFail("Invalid count")
        }

        // MARK: Check adding a comment
        commentTextView.writeText(text: "Test Comment")
        XCTAssertVisible(addCommentButton.waitUntil(.visible))
        XCTAssertTrue(addCommentButton.isEnabled)

        addCommentButton.hit()
        let chatBubble = DetailsHelper.SubmissionComments.chatBubble.waitUntil(.visible)
        XCTAssertVisible(chatBubble)

        // MARK: Check rubric
        rubricButton.hit()
        let rubricTitle = DetailsHelper.SubmissionComments.rubricTitle(rubric: rubric).waitUntil(.visible)
        let rubricDescriptionButton = DetailsHelper.SubmissionComments.rubricDescriptionButton(rubric: rubric).waitUntil(.visible)
        let rubricRatingZero = DetailsHelper.SubmissionComments.rubricRatingButton(rubric: rubric, index: 0).waitUntil(.visible)
        let rubricRatingOne = DetailsHelper.SubmissionComments.rubricRatingButton(rubric: rubric, index: 1).waitUntil(.visible)
        XCTAssertVisible(rubricTitle)
        XCTAssertVisible(rubricDescriptionButton)
        XCTAssertVisible(rubricRatingZero)
        XCTAssertVisible(rubricRatingOne)
        XCTAssertContains(rubricRatingZero.label, rubric.data[0].ratings[1].description)
        XCTAssertContains(rubricRatingOne.label, rubric.data[0].ratings[0].description)

        rubricRatingOne.hit()
        let rubricRatingTitle = DetailsHelper.SubmissionComments.rubricRatingTitle(rubric: rubric).waitUntil(.visible)
        XCTAssertVisible(rubricRatingTitle)
        XCTAssertEqual(rubricRatingTitle.label, rubric.data[0].ratings[0].description)

        rubricRatingZero.hit()
        XCTAssertVisible(rubricRatingTitle.waitUntil(.visible))
        XCTAssertEqual(rubricRatingTitle.label, rubric.data[0].ratings[1].description)

        rubricDescriptionButton.hit()
        let rubricLongDescriptionLabel = DetailsHelper.SubmissionComments
            .rubricLongDescriptionLabel(rubric: rubric).waitUntil(.visible)
        XCTAssertVisible(rubricLongDescriptionLabel)
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments and tap the assignment
        Helper.navigateToAssignments(course: course)
        assertNavbarVisible(course: course)

        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(assignmentButton)
        assignmentButton.hit()

        let submitAssignmentButton = DetailsHelper.submitAssignmentButton.waitUntil(.visible)
        XCTAssertVisible(submitAssignmentButton)
        submitAssignmentButton.hit()

        // MARK: Check elements and if Studio is not available
        let pandaFilePicker = SubmissionHelper.pandaFilePicker.waitUntil(.visible)
        let filesButton = SubmissionHelper.filesButton.waitUntil(.visible)
        let studioLabel = SubmissionHelper.studioLabel.waitUntil(.vanish)
        XCTAssertVisible(pandaFilePicker)
        XCTAssertVisible(filesButton)
        XCTAssertTrue(studioLabel.isVanished)
    }

    private func assertNavbarVisible(course: DSCourse) {
        // TODO: Replace with commented version after a11y issues are fixed (see comments for `NavigationBarTitleView`)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        XCTAssertVisible(navBar)

//        if #available(iOS 26, *) {
//            let navTitle = Helper.navTitle.waitUntil(.visible)
//            let navSubtitle = Helper.navSubtitle(course: course).waitUntil(.visible)
//            XCTAssertVisible(navTitle)
//            XCTAssertVisible(navSubtitle)
//        } else {
//            let navBar = Helper.navBar(course: course).waitUntil(.visible)
//            XCTAssertVisible(navBar)
//        }
    }
}
