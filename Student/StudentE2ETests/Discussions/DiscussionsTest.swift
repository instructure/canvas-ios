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
        typealias Helper = DiscussionsHelper

        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(discussionButton.label().contains(discussion.title))

        let discussionLastPostLabel = Helper.discussionDataLabel(discussion: discussion, label: .lastPost).waitToExist()
        XCTAssertTrue(discussionLastPostLabel.isVisible)

        let discussionRepliesLabel = Helper.discussionDataLabel(discussion: discussion, label: .replies).waitToExist()
        XCTAssertTrue(discussionRepliesLabel.isVisible)
        XCTAssertEqual(discussionRepliesLabel.label(), "\(discussion.discussion_subentry_count) Replies")

        let discussionUnreadLabel = Helper.discussionDataLabel(discussion: discussion, label: .unread).waitToExist()
        XCTAssertTrue(discussionUnreadLabel.isVisible)
        XCTAssertEqual(discussionUnreadLabel.label(), "\(discussion.unread_count) Unread")
    }

    func testDiscussionDetails() {
        typealias Helper = DiscussionsHelper
        typealias DetailsHelper = Helper.Details

        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions, tap on the discussion, check detail page buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.tap()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitToExist()
        XCTAssertTrue(detailsNavBar.isVisible)

        let detailsOptionsButton = DetailsHelper.optionsButton.waitToExist()
        XCTAssertTrue(detailsOptionsButton.isVisible)

        let detailsTitleLabel = DetailsHelper.titleLabel.waitToExist()
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertEqual(detailsTitleLabel.label(), discussion.title)

        let detailsLastPostLabel = DetailsHelper.lastPostLabel.waitToExist()
        XCTAssertTrue(detailsLastPostLabel.isVisible)

        let detailsMessageLabel = DetailsHelper.messageLabel.waitToExist()
        XCTAssertTrue(detailsMessageLabel.isVisible)
        XCTAssertEqual(detailsMessageLabel.label(), discussion.message)

        let detailsReplyButton = DetailsHelper.replyButton.waitToExist()
        XCTAssertTrue(detailsReplyButton.isVisible)
    }

    func testReplyToDiscussion() {
        typealias Helper = DiscussionsHelper
        typealias DetailsHelper = Helper.Details
        typealias ReplyHelper = Helper.Details.Reply

        // MARK: Seed the usual stuff and a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.tap()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitToExist()
        XCTAssertTrue(detailsNavBar.isVisible)

        let detailsReplyButton = DetailsHelper.replyButton.waitToExist()
        XCTAssertTrue(detailsReplyButton.isVisible)

        // MARK: Tap reply button and check buttons and labels of reply screen
        detailsReplyButton.tap()
        let replyNavBar = ReplyHelper.navBar.waitToExist()
        XCTAssertTrue(replyNavBar.isVisible)

        let replySendButton = ReplyHelper.sendButton.waitToExist()
        XCTAssertTrue(replySendButton.isVisible)
        XCTAssertFalse(replySendButton.isEnabled)

        let replyAttachmentButton = ReplyHelper.attachmentButton.waitToExist()
        XCTAssertTrue(replyAttachmentButton.isVisible)

        let replyTextField = ReplyHelper.textField.waitToExist()
        XCTAssertTrue(replyTextField.isVisible)

        // MARK: Write some text into reply text input and tap Send button
        let replyText = "Test replying to discussion"
        replyTextField.pasteText(replyText)
        XCTAssertTrue(replySendButton.isEnabled)

        replySendButton.tap()

        // MARK: Check visibility and label of the reply
        let repliesSection = DetailsHelper.repliesSection.waitToExist()
        XCTAssertTrue(repliesSection.isVisible)

        let replyLabel = app.find(label: replyText)
        XCTAssertTrue(replyLabel.isVisible)

        // MARK: Reply to thread
        let replyToThreadButton = DetailsHelper.replyToThreadButton(threadIndex: 1).waitToExist()
        let threadReplyText = "Test replying to thread"
        XCTAssertTrue(replyToThreadButton.isVisible)
        XCTAssertEqual(replyToThreadButton.label(), "Reply to thread")

        replyToThreadButton.tap()

        // MARK: Check visibility and label of the thread reply
        let replyWasSuccessful = Helper.replyToDiscussion(replyText: threadReplyText)
        XCTAssertTrue(replyWasSuccessful)

        let threadReplyLabel = app.find(label: threadReplyText).waitToExist()
        XCTAssertTrue(threadReplyLabel.isVisible)
    }

    func testAssignmentDiscussion() {
        typealias Helper = DiscussionsHelper
        typealias DetailsHelper = Helper.Details

        // MARK: Seed the usual stuff with an assignment discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignmentDiscussion = Helper.createDiscussion(course: course, isAssignment: true)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments to check visibility of the assignment discussion there
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignmentDiscussion.assignment!).waitToExist()
        XCTAssertTrue(assignmentButton.isVisible)

        AssignmentsHelper.backButton.tap()
        AssignmentsHelper.backButton.tap()

        // MARK: Navigate to Grades to check visibility and submission of the assignment discussion
        GradesHelper.navigateToGrades(course: course)
        var gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment!).waitToExist()
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        var gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!).waitToExist()
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label(), "Not Submitted")

        AssignmentsHelper.backButton.tap()
        AssignmentsHelper.backButton.tap()

        // MARK: Navigate to Discussions and send a reply
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: assignmentDiscussion).waitToExist()
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.tap()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitToExist()
        XCTAssertTrue(detailsNavBar.isVisible)

        Helper.replyToDiscussion(shouldPullToRefresh: true)

        // MARK: Check visibility of the reply
        let repliesSection = DetailsHelper.repliesSection.waitToExist()
        XCTAssertTrue(repliesSection.isVisible)

        AssignmentsHelper.backButton.tap()
        let discussionDataLabelReplies = Helper.discussionDataLabel(discussion: assignmentDiscussion, label: .replies).waitToExist()
        XCTAssertEqual(discussionDataLabelReplies.label(), "1 Reply")

        AssignmentsHelper.backButton.tap()
        AssignmentsHelper.backButton.tap()

        // MARK: Navigate to Grades and check for updates regarding submission
        GradesHelper.navigateToGrades(course: course)
        GradesHelper.pullToRefresh()
        gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment!).waitToExist()
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!).waitToExist()
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label(), "Submitted")
    }
}
