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
    typealias Helper = DiscussionsHelper
    typealias DetailsHelper = Helper.Details
    typealias ReplyHelper = DetailsHelper.Reply

    func testDiscussionLabels() {
        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(discussionButton.label.contains(discussion.title))

        let discussionLastPostLabel = Helper.discussionDataLabel(discussion: discussion, label: .lastPost)
            .waitUntil(.visible)
        XCTAssertTrue(discussionLastPostLabel.isVisible)

        let discussionRepliesLabel = Helper.discussionDataLabel(discussion: discussion, label: .replies)
            .waitUntil(.visible)
        XCTAssertTrue(discussionRepliesLabel.isVisible)
        XCTAssertEqual(discussionRepliesLabel.label, "\(discussion.discussion_subentry_count) Replies")

        let discussionUnreadLabel = Helper.discussionDataLabel(discussion: discussion, label: .unread)
            .waitUntil(.visible)
        XCTAssertTrue(discussionUnreadLabel.isVisible)
        XCTAssertEqual(discussionUnreadLabel.label, "\(discussion.unread_count) Unread")
    }

    func testDiscussionDetails() {
        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions, tap on the discussion, check detail page buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.hit()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let detailsOptionsButton = DetailsHelper.optionsButton.waitUntil(.visible)
        XCTAssertTrue(detailsOptionsButton.isVisible)

        let detailsTitleLabel = DetailsHelper.titleLabel.waitUntil(.visible)
        XCTAssertTrue(detailsTitleLabel.isVisible)
        XCTAssertEqual(detailsTitleLabel.label, discussion.title)

        let detailsLastPostLabel = DetailsHelper.lastPostLabel.waitUntil(.visible)
        XCTAssertTrue(detailsLastPostLabel.isVisible)

        let detailsMessageLabel = DetailsHelper.messageLabel.waitUntil(.visible)
        XCTAssertTrue(detailsMessageLabel.isVisible)
        XCTAssertEqual(detailsMessageLabel.label, discussion.message)

        let detailsReplyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(detailsReplyButton.isVisible)
    }

    func testReplyToDiscussion() {
        // MARK: Seed the usual stuff and a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Discussions
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.hit()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let detailsReplyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(detailsReplyButton.isVisible)

        // MARK: Tap reply button and check buttons and labels of reply screen
        detailsReplyButton.hit()
        let replyNavBar = ReplyHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(replyNavBar.isVisible)

        let replySendButton = ReplyHelper.sendButton.waitUntil(.visible)
        XCTAssertTrue(replySendButton.isVisible)
        XCTAssertFalse(replySendButton.isEnabled)

        let replyAttachmentButton = ReplyHelper.attachmentButton.waitUntil(.visible)
        XCTAssertTrue(replyAttachmentButton.isVisible)

        let replyTextField = ReplyHelper.textField.waitUntil(.visible)
        XCTAssertTrue(replyTextField.isVisible)

        // MARK: Write some text into reply text input and tap Send button
        let replyText = "Test replying to discussion"
        replyTextField.pasteText(text: replyText)
        XCTAssertTrue(replySendButton.waitUntil(.enabled).isEnabled)

        replySendButton.hit()

        // MARK: Check visibility and label of the reply
        let repliesSection = DetailsHelper.repliesSection.waitUntil(.visible)
        XCTAssertTrue(repliesSection.isVisible)

        let replyLabel = app.find(label: replyText).waitUntil(.visible)
        XCTAssertTrue(replyLabel.isVisible)

        // MARK: Reply to thread
        let replyToThreadButton = DetailsHelper.replyToThreadButton(threadIndex: 1).waitUntil(.visible)
        let threadReplyText = "Test replying to thread"
        XCTAssertTrue(replyToThreadButton.isVisible)
        XCTAssertEqual(replyToThreadButton.label, "Reply to thread")

        replyToThreadButton.hit()

        // MARK: Check visibility and label of the thread reply
        let replyWasSuccessful = Helper.replyToDiscussion(replyText: threadReplyText)
        XCTAssertTrue(replyWasSuccessful)

        let threadReplyLabel = app.find(label: threadReplyText).waitUntil(.visible)
        XCTAssertTrue(threadReplyLabel.isVisible)
    }

    func testAssignmentDiscussion() {
        // MARK: Seed the usual stuff with an assignment discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let assignmentDiscussion = Helper.createDiscussion(course: course, isAssignment: true)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Navigate to Assignments to check visibility of the assignment discussion there
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)

        Helper.backButton.hit()
        Helper.backButton.hit()

        // MARK: Navigate to Grades to check visibility and submission of the assignment discussion
        GradesHelper.navigateToGrades(course: course)
        var gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        var gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label, "Not Submitted")

        Helper.backButton.hit()
        Helper.backButton.hit()

        // MARK: Navigate to Discussions and send a reply
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: assignmentDiscussion)
            .waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.hit()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        Helper.replyToDiscussion(shouldPullToRefresh: true)

        // MARK: Check visibility of the reply
        let repliesSection = DetailsHelper.repliesSection.waitUntil(.visible)
        XCTAssertTrue(repliesSection.isVisible)

        Helper.backButton.hit()
        let discussionDataLabelReplies = Helper.discussionDataLabel(discussion: assignmentDiscussion, label: .replies)
            .waitUntil(.visible)
        XCTAssertEqual(discussionDataLabelReplies.label, "1 Reply")

        Helper.backButton.hit()
        Helper.backButton.hit()

        // MARK: Navigate to Grades and check for updates regarding submission
        GradesHelper.navigateToGrades(course: course)
        GradesHelper.pullToRefresh()
        gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)

        gradesAssignmentSubmittedLabel.actionUntilElementCondition(action: .pullToRefresh, condition: .label(expected: "Submitted"))
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label, "Submitted")
    }
}
