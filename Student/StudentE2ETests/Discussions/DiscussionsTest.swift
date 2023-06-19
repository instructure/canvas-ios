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

class DiscussionsTests: E2ETestCase {
    func testDiscussionLabels() {
        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = DiscussionsHelper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        DiscussionsHelper.navigateToDiscussions(course: course)
        let discussionButton = DiscussionsHelper.discussionButton(discussion: discussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(discussionButton.label().contains(discussion.title))

        let discussionLastPostLabel = DiscussionsHelper.discussionDataLabel(discussion: discussion, label: .lastPost).waitToExist()
        XCTAssertTrue(discussionLastPostLabel.isVisible)

        let discussionRepliesLabel = DiscussionsHelper.discussionDataLabel(discussion: discussion, label: .replies).waitToExist()
        XCTAssertTrue(discussionRepliesLabel.isVisible)
        XCTAssertEqual(discussionRepliesLabel.label(), "\(discussion.discussion_subentry_count) Replies")

        let discussionUnreadLabel = DiscussionsHelper.discussionDataLabel(discussion: discussion, label: .unread).waitToExist()
        XCTAssertTrue(discussionUnreadLabel.isVisible)
        XCTAssertEqual(discussionUnreadLabel.label(), "\(discussion.unread_count) Unread")
    }

    func testDiscussionDetails() {
        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = DiscussionsHelper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions, tap on the discussion, check detail page buttons and labels
        DiscussionsHelper.navigateToDiscussions(course: course)
        let discussionButton = DiscussionsHelper.discussionButton(discussion: discussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.tap()
        let discussionDetailsNavBar = DiscussionsHelper.discussionDetailsNavBar(course: course).waitToExist()
        XCTAssertTrue(discussionDetailsNavBar.isVisible)

        let discussionDetailsOptionsButton = DiscussionsHelper.discussionDetailsOptionsButton.waitToExist()
        XCTAssertTrue(discussionDetailsOptionsButton.isVisible)

        let discussionDetailsTitleLabel = DiscussionsHelper.discussionDetailsTitleLabel.waitToExist()
        XCTAssertTrue(discussionDetailsTitleLabel.isVisible)
        XCTAssertEqual(discussionDetailsTitleLabel.label(), discussion.title)

        let discussionDetailsLastPostLabel = DiscussionsHelper.discussionDetailsLastPostLabel.waitToExist()
        XCTAssertTrue(discussionDetailsLastPostLabel.isVisible)

        let discussionDetailsMessageLabel = DiscussionsHelper.discussionDetailsMessageLabel.waitToExist()
        XCTAssertTrue(discussionDetailsMessageLabel.isVisible)
        XCTAssertEqual(discussionDetailsMessageLabel.label(), discussion.message)

        let discussionDetailsReplyButton = DiscussionsHelper.discussionDetailsReplyButton.waitToExist()
        XCTAssertTrue(discussionDetailsReplyButton.isVisible)
    }

    func testReplyToDiscussion() {
        // MARK: Seed the usual stuff and a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = DiscussionsHelper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions
        DiscussionsHelper.navigateToDiscussions(course: course)
        let discussionButton = DiscussionsHelper.discussionButton(discussion: discussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.tap()
        let discussionDetailsNavBar = DiscussionsHelper.discussionDetailsNavBar(course: course).waitToExist()
        XCTAssertTrue(discussionDetailsNavBar.isVisible)

        let discussionDetailsReplyButton = DiscussionsHelper.discussionDetailsReplyButton.waitToExist()
        XCTAssertTrue(discussionDetailsReplyButton.isVisible)

        // MARK: Tap reply button and check buttons and labels of reply screen
        discussionDetailsReplyButton.tap()
        let discussionDetailsReplyNavBar = DiscussionsHelper.discussionDetailsReplyNavBar.waitToExist()
        XCTAssertTrue(discussionDetailsReplyNavBar.isVisible)

        let discussionDetailsReplyEditorSendButton = DiscussionsHelper.discussionDetailsReplyEditorSendButton.waitToExist()
        XCTAssertTrue(discussionDetailsReplyEditorSendButton.isVisible)
        XCTAssertFalse(discussionDetailsReplyEditorSendButton.isEnabled)

        let discussionDetailsReplyEditorAttachmentButton = DiscussionsHelper.discussionDetailsReplyEditorAttachmentButton.waitToExist()
        XCTAssertTrue(discussionDetailsReplyEditorAttachmentButton.isVisible)

        let discussionDetailsReplyEditorTextField = DiscussionsHelper.discussionDetailsReplyEditorTextField.waitToExist()
        XCTAssertTrue(discussionDetailsReplyEditorTextField.isVisible)

        // MARK: Write some text into reply text input and tap Send button
        let replyText = "Test replying to discussion"
        discussionDetailsReplyEditorTextField.pasteText(replyText)
        XCTAssertTrue(discussionDetailsReplyEditorSendButton.isEnabled)

        discussionDetailsReplyEditorSendButton.tap()

        // MARK: Check visibility and label of the reply
        let discussionDetailsRepliesSection = DiscussionsHelper.discussionDetailsRepliesSection.waitToExist()
        XCTAssertTrue(discussionDetailsRepliesSection.isVisible)

        let discussionDetailsFirstReplyLabel = app.find(label: replyText)
        XCTAssertTrue(discussionDetailsFirstReplyLabel.isVisible)

        // MARK: Reply to thread
        let discussionDetailsReplyToThreadButton = DiscussionsHelper.discussionDetailsReplyToThreadButton(threadIndex: 1).waitToExist()
        let threadReplyText = "Test replying to thread"
        XCTAssertTrue(discussionDetailsReplyToThreadButton.isVisible)
        XCTAssertEqual(discussionDetailsReplyToThreadButton.label(), "Reply to thread")
        discussionDetailsReplyToThreadButton.tap()

        // MARK: Check visibility and label of the thread reply
        let replyWasSuccessful = DiscussionsHelper.replyToDiscussion(replyText: threadReplyText)
        XCTAssertTrue(replyWasSuccessful)

        let discussionDetailsThreadReplyLabel = app.find(label: threadReplyText).waitToExist()
        XCTAssertTrue(discussionDetailsThreadReplyLabel.isVisible)
    }

    func testAssignmentDiscussion() {
        // MARK: Seed the usual stuff with an assignment discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignmentDiscussion = DiscussionsHelper.createDiscussion(course: course, isAssignment: true)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments to check visibility of the assignment discussion there
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignmentDiscussion.assignment).waitToExist()
        XCTAssertTrue(assignmentButton.isVisible)
        AssignmentsHelper.backButton.tap()
        AssignmentsHelper.backButton.tap()

        // MARK: Navigate to Grades to check visibility and submission of the assignment discussion
        GradesHelper.navigateToGrades(course: course)
        var gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment).waitToExist()
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        var gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment).waitToExist()
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label(), "Not Submitted")
        AssignmentsHelper.backButton.tap()
        AssignmentsHelper.backButton.tap()

        // MARK: Navigate to Discussions and send a reply
        DiscussionsHelper.navigateToDiscussions(course: course)
        let discussionButton = DiscussionsHelper.discussionButton(discussion: assignmentDiscussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)
        discussionButton.tap()
        let discussionDetailsNavBar = DiscussionsHelper.discussionDetailsNavBar(course: course).waitToExist()
        XCTAssertTrue(discussionDetailsNavBar.isVisible)

        DiscussionsHelper.replyToDiscussion()
        DiscussionsHelper.pullToRefresh()

        // MARK: Check visibility of the reply
        let discussionDetailsRepliesSection = DiscussionsHelper.discussionDetailsRepliesSection.waitToExist()
        XCTAssertTrue(discussionDetailsRepliesSection.isVisible)
        AssignmentsHelper.backButton.tap()

        let discussionDataLabelReplies = DiscussionsHelper.discussionDataLabel(discussion: assignmentDiscussion, label: .replies).waitToExist()
        XCTAssertEqual(discussionDataLabelReplies.label(), "1 Reply")
        AssignmentsHelper.backButton.tap()
        AssignmentsHelper.backButton.tap()

        // MARK: Navigate to Grades and check for updates regarding submission
        GradesHelper.navigateToGrades(course: course)
        GradesHelper.pullToRefresh()
        gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment).waitToExist()
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment).waitToExist()
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label(), "Submitted")
    }
}
