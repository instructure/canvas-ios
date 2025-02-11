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
    typealias DetailsHelper = Helper.NewDetails
    typealias ReplyHelper = DetailsHelper.Reply

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
        let detailsReplyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(detailsReplyButton.isVisible)

        // MARK: Tap reply button and check buttons and labels of reply screen
        detailsReplyButton.hit()
        let textInput = DetailsHelper.Reply.textInput.waitUntil(.visible)
        let attachButton = DetailsHelper.Reply.attachButton.waitUntil(.visible)
        let cancelButton = DetailsHelper.Reply.cancelButton.waitUntil(.visible)
        let replyButton = DetailsHelper.Reply.replyButton.waitUntil(.visible)
        XCTAssertTrue(textInput.isVisible)
        XCTAssertTrue(attachButton.isVisible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(replyButton.isVisible)

        // MARK: Write some text into reply text input and tap Reply button
        let replyText = "Test replying to discussion"
        textInput.writeText(text: replyText)
        replyButton.hit()
        XCTAssertTrue(textInput.waitUntil(.vanish).isVanished)

        // MARK: Check visibility and label of the reply
        let replyFromLabel = DetailsHelper.replyFromLabel(user: student).waitUntil(.visible)
        let replyBody = DetailsHelper.replyBody(replyText: replyText).waitUntil(.visible)
        let replyToPostButton = DetailsHelper.replyToPostButton(user: student).waitUntil(.visible)
        XCTAssertTrue(replyFromLabel.isVisible)
        XCTAssertTrue(replyBody.isVisible)
        XCTAssertTrue(replyToPostButton.isVisible)

        // MARK: Reply to thread
        let replyToPostText = "Text replying to reply of discussion"
        replyToPostButton.hit()
        XCTAssertTrue(textInput.waitUntil(.visible).isVisible)
        let threadReplyButton = DetailsHelper.Reply.replyButton.waitUntil(.visible)
        XCTAssertTrue(threadReplyButton.isVisible)

        textInput.writeText(text: replyToPostText)
        threadReplyButton.hit()
        XCTAssertTrue(textInput.waitUntil(.vanish).isVanished)

        // MARK: Check visibility and label of the thread reply
        let replyToReplyBody = DetailsHelper.replyBody(replyText: replyToPostText).waitUntil(.visible)
        XCTAssertTrue(replyToReplyBody.isVisible)
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
        Helper.replyToDiscussion()

        // MARK: Check visibility of the reply

        // On iPad: Discussion replies label is visible right after the reply is sent
        // On iPhone: Back button needs to be tapped for the label to get visible
        var discussionDataLabelReplies = Helper.discussionDataLabel(discussion: assignmentDiscussion, label: .replies)
        if discussionDataLabelReplies == nil {
            Helper.backButton.hit()
            pullToRefresh()
        }
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

    func testDiscussionDetail() {
        // MARK: Seed the usual stuff with a discussion, enable NewDiscussion feature
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
        let searchField = DetailsHelper.searchField.waitUntil(.visible)
        let filterByLabel = DetailsHelper.filterByLabel.waitUntil(.visible)
        let sortButton = DetailsHelper.sortButton.waitUntil(.visible)
        let viewSplitScreenButton = DetailsHelper.viewSplitScreenButton.waitUntil(.visible)
        let subscribeButton = DetailsHelper.subscribeButton.waitUntil(.visible)
        let manageDiscussionButton = DetailsHelper.manageDiscussionButton.waitUntil(.visible)
        let discussionTitle = DetailsHelper.discussionTitle(discussion: discussion).waitUntil(.visible)
        let discussionBody = DetailsHelper.discussionBody(discussion: discussion).waitUntil(.visible)
        var replyButton = DetailsHelper.replyButton.waitUntil(.visible)
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
        let viewInlineButton = DetailsHelper.viewInlineButton.waitUntil(.visible)
        XCTAssertTrue(viewSplitScreenButton.isVanished)
        XCTAssertTrue(viewInlineButton.isVisible)

        subscribeButton.hit()
        let unsubscribeButton = DetailsHelper.unsubscribeButton.waitUntil(.visible)
        XCTAssertTrue(subscribeButton.isVanished)
        XCTAssertTrue(unsubscribeButton.isVisible)

        manageDiscussionButton.hit()
        let markAllAsReadButton = DetailsHelper.markAllAsRead.waitUntil(.visible)
        let markAllAsUnreadButton = DetailsHelper.markAllAsUnread.waitUntil(.visible)
        XCTAssertTrue(markAllAsReadButton.isVisible)
        XCTAssertTrue(markAllAsUnreadButton.isVisible)

        markAllAsUnreadButton.hit()
        replyButton.hit()
        let textInput = DetailsHelper.Reply.textInput.waitUntil(.visible)
        let attachButton = DetailsHelper.Reply.attachButton.waitUntil(.visible)
        let cancelButton = DetailsHelper.Reply.cancelButton.waitUntil(.visible)
        replyButton = DetailsHelper.Reply.replyButton.waitUntil(.visible)
        XCTAssertTrue(textInput.isVisible)
        XCTAssertTrue(attachButton.isVisible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(replyButton.isVisible)

        cancelButton.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        cancelButton.hit()
        XCTAssertTrue(cancelButton.waitUntil(.vanish).isVanished)
    }
}
