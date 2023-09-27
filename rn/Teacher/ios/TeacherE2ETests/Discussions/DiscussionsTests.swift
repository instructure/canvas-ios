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

class DiscussionsTests: E2ETestCase {
    typealias Helper = DiscussionsHelper
    typealias DetailsHelper = Helper.Details
    typealias ReplyHelper = DetailsHelper.Reply
    typealias EditorHelper = Helper.Editor

    func testDiscussionLabels() {
        // MARK: Seed the usual stuff with a discussion
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(discussionButton.label.contains(discussion.title))

        let discussionLastPostLabel = Helper.discussionDataLabel(discussion: discussion, label: .lastPost)!
            .waitUntil(.visible)
        XCTAssertTrue(discussionLastPostLabel.isVisible)

        let discussionRepliesLabel = Helper.discussionDataLabel(discussion: discussion, label: .replies)!
            .waitUntil(.visible)
        XCTAssertTrue(discussionRepliesLabel.isVisible)
        XCTAssertEqual(discussionRepliesLabel.label, "\(discussion.discussion_subentry_count) Replies")

        let discussionUnreadLabel = Helper.discussionDataLabel(discussion: discussion, label: .unread)!
            .waitUntil(.visible)
        XCTAssertTrue(discussionUnreadLabel.isVisible)
        XCTAssertEqual(discussionUnreadLabel.label, "\(discussion.unread_count) Unread")
    }

    func testDiscussionDetails() {
        // MARK: Seed the usual stuff with a discussion
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)

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
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)

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
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        let assignmentDiscussion = Helper.createDiscussion(course: course, isAssignment: true)

        // MARK: Get the user logged in
        logInDSUser(teacher)

        // MARK: Navigate to Assignments to check visibility of the assignment discussion there
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
    }

    func testCreateDiscussion() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let newTitle = "New Test Discussion"
        let newDescription = "Description of \(newTitle)"
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)

        // MARK: Navigate to Discussions
        DiscussionsHelper.navigateToDiscussions(course: course)
        let newDiscussionButton = DiscussionsHelper.newButton.waitUntil(.visible)
        XCTAssertTrue(newDiscussionButton.isVisible)

        // MARK: Create new discussion
        newDiscussionButton.hit()
        let titleField = EditorHelper.titleField.waitUntil(.visible)
        let descriptionField = EditorHelper.descriptionField.waitUntil(.visible)
        let publishToggle = EditorHelper.publishedToggle.waitUntil(.visible)
        let sectionsButton = EditorHelper.sectionsButton.waitUntil(.visible)
        let threadedReplies = EditorHelper.threadedToggle.waitUntil(.visible)
        let userMustPostToggle = EditorHelper.requireInitialPostToggle.waitUntil(.visible)
        let allowLikingToggle = EditorHelper.allowRatingToggle.waitUntil(.visible)
        let availableFromButton = EditorHelper.availableFromButton.waitUntil(.visible)
        let availableUntilButton = EditorHelper.availableUntilButton.waitUntil(.visible)
        let doneButton = EditorHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(descriptionField.isVisible)
        XCTAssertTrue(publishToggle.isVisible)
        XCTAssertTrue(sectionsButton.isVisible)
        XCTAssertTrue(threadedReplies.isVisible)
        XCTAssertTrue(userMustPostToggle.isVisible)
        XCTAssertTrue(allowLikingToggle.isVisible)
        XCTAssertTrue(availableFromButton.isVisible)
        XCTAssertTrue(availableUntilButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        titleField.writeText(text: newTitle)
        descriptionField.writeText(text: newDescription)
        publishToggle.actionUntilElementCondition(action: .tap, condition: .value(expected: "1"))
        threadedReplies.actionUntilElementCondition(action: .tap, condition: .value(expected: "1"))
        allowLikingToggle.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        allowLikingToggle.actionUntilElementCondition(action: .tap, condition: .value(expected: "1"))
        let onlyGradersCanLikeToggle = EditorHelper.onlyGradersCanRateToggle.waitUntil(.visible)
        let sortByLikesToggle = EditorHelper.sortByRatingToggle.waitUntil(.visible)
        XCTAssertTrue(publishToggle.hasValue(value: "1"))
        XCTAssertTrue(threadedReplies.hasValue(value: "1"))
        XCTAssertTrue(allowLikingToggle.hasValue(value: "1"))
        XCTAssertTrue(onlyGradersCanLikeToggle.isVisible)
        XCTAssertTrue(sortByLikesToggle.isVisible)

        doneButton.hit()

        // MARK: Check if creating new discussion was successful
        let newDiscussionElement = Helper.discussionButtonByLabel(label: newTitle).waitUntil(.visible)
        XCTAssertTrue(newDiscussionElement.isVisible)
    }
}
