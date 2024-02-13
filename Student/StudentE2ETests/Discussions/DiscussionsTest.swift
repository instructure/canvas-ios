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
    typealias NewDiscussion = Helper.NewDetails

    override func tearDown() {
        let featureFlagResponse = seeder.setFeatureFlag(featureFlag: .newDiscussion, state: .off)
        XCTAssertEqual(featureFlagResponse.state, DSFeatureFlagState.off.rawValue)
    }

    func testDiscussionLabels() {
        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(discussionButton.hasLabel(label: discussion.title, strict: false))

        let discussionLastPostLabel = Helper.discussionDataLabel(discussion: discussion, label: .lastPost)!.waitUntil(.visible)
        XCTAssertTrue(discussionLastPostLabel.isVisible)

        let discussionRepliesLabel = Helper.discussionDataLabel(discussion: discussion, label: .replies)!.waitUntil(.visible)
        XCTAssertTrue(discussionRepliesLabel.isVisible)
        XCTAssertTrue(discussionRepliesLabel.hasLabel(label: "\(discussion.discussion_subentry_count) Replies"))

        let discussionUnreadLabel = Helper.discussionDataLabel(discussion: discussion, label: .unread)!
            .waitUntil(.visible)
        XCTAssertTrue(discussionUnreadLabel.isVisible)
        XCTAssertTrue(discussionUnreadLabel.hasLabel(label: "\(discussion.unread_count) Unread"))
    }

    func testDiscussionDetails() {
        // MARK: Seed the usual stuff with a discussion
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

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
        XCTAssertTrue(detailsTitleLabel.hasLabel(label: discussion.title))

        let detailsLastPostLabel = DetailsHelper.lastPostLabel.waitUntil(.visible)
        XCTAssertTrue(detailsLastPostLabel.isVisible)

        let detailsMessageLabel = DetailsHelper.messageLabel.waitUntil(.visible)
        XCTAssertTrue(detailsMessageLabel.isVisible)
        XCTAssertTrue(detailsMessageLabel.hasLabel(label: discussion.message))

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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

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
        XCTAssertTrue(replySendButton.isDisabled)

        let replyAttachmentButton = ReplyHelper.attachmentButton.waitUntil(.visible)
        XCTAssertTrue(replyAttachmentButton.isVisible)

        let replyTextField = ReplyHelper.textField.waitUntil(.visible)
        XCTAssertTrue(replyTextField.isVisible)

        // MARK: Write some text into reply text input and tap Send button
        let replyText = "Test replying to discussion"
        replyTextField.writeText(text: replyText)
        XCTAssertTrue(replySendButton.waitUntil(.enabled).isEnabled)

        // MARK: Check visibility and label of the reply
        replySendButton.hit()
        let repliesSection = DetailsHelper.repliesSection.waitUntil(.visible)
        XCTAssertTrue(repliesSection.isVisible)

        let replyLabel = app.find(label: replyText).waitUntil(.visible)
        XCTAssertTrue(replyLabel.isVisible)

        // MARK: Reply to thread
        let replyToThreadButton = DetailsHelper.replyToThreadButton(threadIndex: 1).waitUntil(.visible)
        let threadReplyText = "Test replying to thread"
        XCTAssertTrue(replyToThreadButton.isVisible)
        XCTAssertTrue(replyToThreadButton.hasLabel(label: "Reply to thread"))

        // MARK: Check visibility and label of the thread reply
        replyToThreadButton.hit()
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments to check visibility of the assignment discussion there
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)

        // MARK: Navigate to Grades to check visibility and submission of the assignment discussion
        Helper.backButton.hit()
        Helper.backButton.hit()
        GradesHelper.navigateToGrades(course: course)
        var gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        var gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)
        XCTAssertTrue(gradesAssignmentSubmittedLabel.hasLabel(label: "Not Submitted"))

        // MARK: Navigate to Discussions and send a reply
        Helper.backButton.hit()
        Helper.backButton.hit()
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: assignmentDiscussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)

        discussionButton.hit()
        let detailsNavBar = DetailsHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        Helper.replyToDiscussion(shouldPullToRefresh: true)

        // MARK: Check visibility of the reply
        let repliesSection = DetailsHelper.repliesSection.waitUntil(.visible)
        XCTAssertTrue(repliesSection.isVisible)

        // On iPad: Discussion replies label is visible right after the reply is sent
        // On iPhone: Back button needs to be tapped for the label to get visible
        var discussionDataLabelReplies = Helper.discussionDataLabel(discussion: assignmentDiscussion, label: .replies)
        if discussionDataLabelReplies == nil { Helper.backButton.hit() }
        discussionDataLabelReplies = Helper.discussionDataLabel(discussion: assignmentDiscussion, label: .replies)!.waitUntil(.visible)

        XCTAssertTrue(discussionDataLabelReplies!.hasLabel(label: "1 Reply"))

        // MARK: Navigate to Grades and check for updates regarding submission
        Helper.backButton.hit()
        Helper.backButton.hit()
        GradesHelper.navigateToGrades(course: course)
        GradesHelper.pullToRefresh()
        gradesAssignmentButton = GradesHelper.gradesAssignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentButton.isVisible)

        gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertTrue(gradesAssignmentSubmittedLabel.isVisible)

        gradesAssignmentSubmittedLabel.actionUntilElementCondition(action: .pullToRefresh, condition: .label(expected: "Submitted"))
        XCTAssertTrue(gradesAssignmentSubmittedLabel.hasLabel(label: "Submitted"))
    }

    func testNewDiscussionScreen() {
        // MARK: Seed the usual stuff with a discussion, enable NewDiscussion feature
        let featureFlagResponse = seeder.setFeatureFlag(featureFlag: .newDiscussion, state: .allowedOn)
        XCTAssertEqual(featureFlagResponse.state, DSFeatureFlagState.allowedOn.rawValue)

        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)
        let discussion = Helper.createDiscussion(course: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(discussionButton.hasLabel(label: discussion.title, strict: false))

        discussionButton.hit()
        let searchField = NewDiscussion.searchField.waitUntil(.visible)
        let filterByLabel = NewDiscussion.filterByLabel.waitUntil(.visible)
        let sortButton = NewDiscussion.sortButton.waitUntil(.visible)
        let viewSplitScreenButton = NewDiscussion.viewSplitScreenButton.waitUntil(.visible)
        let subscribeButton = NewDiscussion.subscribeButton.waitUntil(.visible)
        let manageDiscussionButton = NewDiscussion.manageDiscussionButton.waitUntil(.visible)
        let discussionTitle = NewDiscussion.discussionTitle(discussion: discussion).waitUntil(.visible)
        let discussionBody = NewDiscussion.discussionBody(discussion: discussion).waitUntil(.visible)
        var replyButton = NewDiscussion.replyButton.waitUntil(.visible)
        XCTAssertTrue(searchField.isVisible)
        XCTAssertTrue(searchField.hasValue(value: "Search entries or author..."))
        XCTAssertTrue(filterByLabel.isVisible)
        XCTAssertTrue(sortButton.isVisible)
        XCTAssertTrue(sortButton.hasLabel(label: "Sorted by Descending", strict: false))
        XCTAssertTrue(viewSplitScreenButton.isVisible)
        XCTAssertTrue(subscribeButton.isVisible)
        XCTAssertTrue(manageDiscussionButton.isVisible)
        XCTAssertTrue(discussionTitle.isVisible)
        XCTAssertTrue(discussionBody.isVisible)
        XCTAssertTrue(replyButton.isVisible)

        viewSplitScreenButton.hit()
        let viewInlineButton = NewDiscussion.viewInlineButton.waitUntil(.visible)
        XCTAssertTrue(viewSplitScreenButton.isVanished)
        XCTAssertTrue(viewInlineButton.isVisible)

        subscribeButton.hit()
        let unsubscribeButton = NewDiscussion.unsubscribeButton.waitUntil(.visible)
        XCTAssertTrue(subscribeButton.isVanished)
        XCTAssertTrue(unsubscribeButton.isVisible)

        manageDiscussionButton.hit()
        let markAllAsReadButton = NewDiscussion.markAllAsRead.waitUntil(.visible)
        let markAllAsUnreadButton = NewDiscussion.markAllAsUnread.waitUntil(.visible)
        XCTAssertTrue(markAllAsReadButton.isVisible)
        XCTAssertTrue(markAllAsUnreadButton.isVisible)

        markAllAsUnreadButton.hit()
        replyButton.hit()
        let textInput = NewDiscussion.Reply.textInput.waitUntil(.visible)
        let attachButton = NewDiscussion.Reply.attachButton.waitUntil(.visible)
        let cancelButton = NewDiscussion.Reply.cancelButton.waitUntil(.visible)
        replyButton = NewDiscussion.Reply.replyButton.waitUntil(.visible)
        XCTAssertTrue(textInput.isVisible)
        XCTAssertTrue(attachButton.isVisible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(replyButton.isVisible)

        cancelButton.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        cancelButton.hit()
        XCTAssertTrue(cancelButton.waitUntil(.vanish).isVanished)
    }
}
