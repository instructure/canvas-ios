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
import XCTest

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
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertVisible(discussionButton)
        XCTAssertContains(discussionButton.label, discussion.title)

        let discussionLastPostLabel = discussionButton
            .find(labelContaining: "Last post", type: .staticText)
            .waitUntil(.visible)
        XCTAssert(discussionLastPostLabel.isVisible)

        let discussionRepliesLabel = discussionButton
            .find(label: "\(discussion.discussion_subentry_count) Replies", type: .staticText)
            .waitUntil(.visible)
        XCTAssert(discussionRepliesLabel.isVisible)

        let discussionUnreadLabel = discussionButton
            .find(label: "\(discussion.unread_count) Unread", type: .staticText)
            .waitUntil(.visible)
        XCTAssert(discussionUnreadLabel.isVisible)
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
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Discussions
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertVisible(discussionButton)

        discussionButton.hit()
        let detailsReplyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertVisible(detailsReplyButton)

        // MARK: Tap reply button and check buttons and labels of reply screen
        detailsReplyButton.hit()
        let textInput = DetailsHelper.Reply.textInput.waitUntil(.visible)
        let attachButton = DetailsHelper.Reply.attachButton.waitUntil(.visible)
        let cancelButton = DetailsHelper.Reply.cancelButton.waitUntil(.visible)
        let replyButton = DetailsHelper.Reply.replyButton.waitUntil(.visible)
        XCTAssertVisible(textInput)
        XCTAssertVisible(attachButton)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(replyButton)

        // MARK: Write some text into reply text input and tap Reply button
        let replyText = "Test replying to discussion"
        textInput.writeText(text: replyText)
        replyButton.hit()
        XCTAssertTrue(textInput.waitUntil(.vanish).isVanished)

        // MARK: Check visibility and label of the reply
        let replyFromLabel = DetailsHelper.replyFromLabel(user: student).waitUntil(.visible)
        let replyBody = DetailsHelper.replyBody(replyText: replyText).waitUntil(.visible)
        let replyToPostButton = DetailsHelper.replyToPostButton(user: student).waitUntil(.visible)
        XCTAssertVisible(replyFromLabel)
        XCTAssertVisible(replyBody)
        XCTAssertVisible(replyToPostButton)

        // MARK: Reply to thread
        let replyToPostText = "Text replying to reply of discussion"
        replyToPostButton.hit()
        XCTAssertTrue(textInput.waitUntil(.visible).isVisible)
        let threadReplyButton = DetailsHelper.Reply.replyButton.waitUntil(.visible)
        XCTAssertVisible(threadReplyButton)

        textInput.writeText(text: replyToPostText)
        threadReplyButton.hit()
        XCTAssertTrue(textInput.waitUntil(.vanish).isVanished)

        // MARK: Check visibility and label of the thread reply
        let replyToReplyBody = DetailsHelper.replyBody(replyText: replyToPostText).waitUntil(.visible)
        XCTAssertVisible(replyToReplyBody)
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
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Assignments to check visibility of the assignment discussion there
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertVisible(assignmentButton)

        // MARK: Navigate to Grades to check visibility and submission of the assignment discussion
        Helper.backButton.hit()
        Helper.backButton.hit()
        GradesHelper.navigateToGrades(course: course)
        var gradesAssignmentButton = GradesHelper.cell(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertVisible(gradesAssignmentButton)

        var gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertVisible(gradesAssignmentSubmittedLabel)
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label, "Not Submitted")

        // MARK: Navigate to Discussions and send a reply
        Helper.backButton.hit()
        Helper.backButton.hit()
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: assignmentDiscussion).waitUntil(.visible)
        XCTAssertVisible(discussionButton)

        discussionButton.hit()
        Helper.replyToDiscussion()

        // MARK: Check visibility of the reply

        // On iPad: Discussion replies label is visible right after the reply is sent
        // On iPhone: Back button needs to be tapped for the label to get visible
        let discussionDataLabelReplies = Helper.discussionDataLabel(discussion: assignmentDiscussion, label: .replies)
        if discussionDataLabelReplies == nil {
            Helper.backButton.hit()
            app.pullToRefresh()
        }
        let discussionRepliesLabel = Helper.discussionButton(discussion: assignmentDiscussion)
            .waitUntil(.visible)
            .find(label: "1 Reply", type: .staticText)
            .waitUntil(.visible)
        XCTAssert(discussionRepliesLabel.isVisible)

        // MARK: Navigate to Grades and check for updates regarding submission
        Helper.backButton.hit()
        Helper.backButton.hit()
        GradesHelper.navigateToGrades(course: course)
        GradesHelper.refreshGradesScreen()
        gradesAssignmentButton = GradesHelper.cell(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertVisible(gradesAssignmentButton)

        gradesAssignmentSubmittedLabel = GradesHelper.gradesAssignmentSubmittedLabel(assignment: assignmentDiscussion.assignment!)
            .waitUntil(.visible)
        XCTAssertVisible(gradesAssignmentSubmittedLabel)
        XCTAssertEqual(gradesAssignmentSubmittedLabel.label, "Submitted")
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
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertVisible(discussionButton)
        XCTAssertContains(discussionButton.label, discussion.title)

        discussionButton.hit()
        let searchField = DetailsHelper.searchField.waitUntil(.visible)
        let filterByLabel = DetailsHelper.filterByLabel.waitUntil(.visible)
        let sortButton = DetailsHelper.sort.waitUntil(.visible)
        let viewSplitScreenButton = DetailsHelper.viewSplitScreenButton.waitUntil(.visible)
        let subscribeButton = DetailsHelper.subscribeButton.waitUntil(.visible)
        let manageDiscussionButton = DetailsHelper.manageDiscussionButton.waitUntil(.visible)
        let discussionTitle = DetailsHelper.discussionTitle(discussion: discussion).waitUntil(.visible)
        let discussionBody = DetailsHelper.discussionBody(discussion: discussion).waitUntil(.visible)
        var replyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertVisible(searchField)
        XCTAssertEqual(searchField.stringValue, "Search entries or author...")
        XCTAssertVisible(filterByLabel)
        XCTAssertVisible(sortButton)
        XCTAssertContains(sortButton.stringValue, "Sort by")
        XCTAssertVisible(viewSplitScreenButton)
        XCTAssertVisible(subscribeButton)
        XCTAssertVisible(manageDiscussionButton)
        XCTAssertVisible(discussionTitle)
        XCTAssertVisible(discussionBody)
        XCTAssertVisible(replyButton)

        viewSplitScreenButton.hit()
        let viewInlineButton = DetailsHelper.viewInlineButton.waitUntil(.visible)
        XCTAssertTrue(viewSplitScreenButton.isVanished)
        XCTAssertVisible(viewInlineButton)

        subscribeButton.hit()
        let unsubscribeButton = DetailsHelper.unsubscribeButton.waitUntil(.visible)
        XCTAssertTrue(subscribeButton.isVanished)
        XCTAssertVisible(unsubscribeButton)

        manageDiscussionButton.hit()
        let markAllAsReadButton = DetailsHelper.markAllAsRead.waitUntil(.visible)
        let markAllAsUnreadButton = DetailsHelper.markAllAsUnread.waitUntil(.visible)
        XCTAssertVisible(markAllAsReadButton)
        XCTAssertVisible(markAllAsUnreadButton)

        markAllAsUnreadButton.hit()
        replyButton.hit()
        let textInput = DetailsHelper.Reply.textInput.waitUntil(.visible)
        let attachButton = DetailsHelper.Reply.attachButton.waitUntil(.visible)
        let cancelButton = DetailsHelper.Reply.cancelButton.waitUntil(.visible)
        replyButton = DetailsHelper.Reply.replyButton.waitUntil(.visible)
        XCTAssertVisible(textInput)
        XCTAssertVisible(attachButton)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(replyButton)

        cancelButton.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        cancelButton.hit()
        XCTAssertTrue(cancelButton.waitUntil(.vanish).isVanished)
    }
}
