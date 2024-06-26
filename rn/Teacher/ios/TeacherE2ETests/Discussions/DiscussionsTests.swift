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
    typealias DetailsHelper = Helper.NewDetails
    typealias ReplyHelper = DetailsHelper.Reply
    typealias EditorHelper = Helper.Editor

    func testDiscussionLabels() {
        // MARK: Seed the usual stuff with a discussion
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let discussion = Helper.createDiscussion(course: course)
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Discussions and check visibility of buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        let discussionLastPostLabel = Helper.discussionDataLabel(discussion: discussion, label: .lastPost)!.waitUntil(.visible)
        let discussionRepliesLabel = Helper.discussionDataLabel(discussion: discussion, label: .replies)!.waitUntil(.visible)
        let discussionUnreadLabel = Helper.discussionDataLabel(discussion: discussion, label: .unread)!.waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(discussionButton.hasLabel(label: discussion.title, strict: false))
        XCTAssertTrue(discussionLastPostLabel.isVisible)
        XCTAssertTrue(discussionRepliesLabel.isVisible)
        XCTAssertTrue(discussionRepliesLabel.hasLabel(label: "\(discussion.discussion_subentry_count) Replies"))
        XCTAssertTrue(discussionUnreadLabel.isVisible)
        XCTAssertTrue(discussionUnreadLabel.hasLabel(label: "\(discussion.unread_count) Unread"))
    }

    func testDiscussionDetails() {
        // MARK: Seed the usual stuff with a discussion
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let discussion = Helper.createDiscussion(course: course)
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Discussions, tap on the discussion, check detail page buttons and labels
        Helper.navigateToDiscussions(course: course)
        let discussionButton = Helper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)

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

    func testReplyToDiscussion() {
        // MARK: Seed the usual stuff and a discussion
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let discussion = Helper.createDiscussion(course: course)
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)
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
        let replyFromLabel = DetailsHelper.replyFromLabel(user: teacher).waitUntil(.visible)
        let replyBody = DetailsHelper.replyBody(replyText: replyText).waitUntil(.visible)
        let replyToPostButton = DetailsHelper.replyToPostButton(user: teacher).waitUntil(.visible)
        XCTAssertTrue(replyFromLabel.isVisible)
        XCTAssertTrue(replyBody.isVisible)
        XCTAssertTrue(replyToPostButton.isVisible)

        // MARK: Reply to thread
        let replyToPostText = "Text replying to reply of discussion"
        replyToPostButton.hit()

        let replyButtons = DetailsHelper.Reply.replyButtons(count: 2)
        XCTAssertTrue(replyButtons.count > 1)

        let secondReplyButton = replyButtons[1].waitUntil(.visible)
        XCTAssertTrue(textInput.waitUntil(.visible).isVisible)
        XCTAssertTrue(secondReplyButton.isVisible)

        textInput.writeText(text: replyToPostText)
        secondReplyButton.hit()
        XCTAssertTrue(textInput.waitUntil(.vanish).isVanished)

        // MARK: Check visibility and label of the thread reply
        let replyToReplyBody = DetailsHelper.replyBody(replyText: replyToPostText).waitUntil(.visible)
        XCTAssertTrue(replyToReplyBody.isVisible)
    }

    func testAssignmentDiscussion() {
        // MARK: Seed the usual stuff with an assignment discussion
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        let assignmentDiscussion = Helper.createDiscussion(course: course, isAssignment: true)
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments to check visibility of the assignment discussion there
        AssignmentsHelper.navigateToAssignments(course: course)
        let assignmentButton = AssignmentsHelper.assignmentButton(assignment: assignmentDiscussion.assignment!).waitUntil(.visible)
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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Discussions
        DiscussionsHelper.navigateToDiscussions(course: course)
        let newDiscussionButton = DiscussionsHelper.newButton.waitUntil(.visible)
        XCTAssertTrue(newDiscussionButton.isVisible)

        // MARK: Create new discussion, check elements
        newDiscussionButton.hit()
        let cancelButton = EditorHelper.cancelButton.waitUntil(.visible)
        let attachmentButton = EditorHelper.attachmentButton.waitUntil(.visible)
        let doneButton = EditorHelper.doneButton.waitUntil(.visible)
        let titleField = EditorHelper.titleField.waitUntil(.visible)
        let descriptionField = EditorHelper.descriptionField.waitUntil(.visible)
        let publishToggle = EditorHelper.publishedToggle.waitUntil(.visible)
        let sections = EditorHelper.sectionsButton.waitUntil(.visible)
        let threadedToggle = EditorHelper.threadedToggle.waitUntil(.visible)
        let requireInitialPostToggle = EditorHelper.requireInitialPostToggle.waitUntil(.visible)
        let allowRatingToggle = EditorHelper.allowRatingToggle.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(attachmentButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(titleField.isVisible)
        XCTAssertTrue(descriptionField.isVisible)
        XCTAssertTrue(publishToggle.isVisible)
        XCTAssertTrue(publishToggle.hasValue(value: "0"))
        XCTAssertTrue(sections.isVisible)
        XCTAssertTrue(threadedToggle.isVisible)
        XCTAssertTrue(threadedToggle.hasValue(value: "0"))
        XCTAssertTrue(requireInitialPostToggle.isVisible)
        XCTAssertTrue(requireInitialPostToggle.hasValue(value: "0"))
        XCTAssertTrue(allowRatingToggle.isVisible)
        XCTAssertTrue(allowRatingToggle.hasValue(value: "0"))

        titleField.writeText(text: newTitle)
        descriptionField.writeText(text: newDescription)
        publishToggle.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        publishToggle.hit()
        allowRatingToggle.actionUntilElementCondition(action: .swipeUp(.onApp), condition: .hittable)
        allowRatingToggle.hit()
        publishToggle.waitUntil(.value(expected: "1"))
        allowRatingToggle.waitUntil(.value(expected: "1"))
        XCTAssertTrue(publishToggle.hasValue(value: "1"))
        XCTAssertTrue(allowRatingToggle.hasValue(value: "1"))

        let onlyGradersCanRateToggle = EditorHelper.onlyGradersCanRateToggle.waitUntil(.visible)
        let sortByRatingToggle = EditorHelper.sortByRatingToggle.waitUntil(.visible)
        XCTAssertTrue(onlyGradersCanRateToggle.isVisible)
        XCTAssertTrue(onlyGradersCanRateToggle.hasValue(value: "0"))
        XCTAssertTrue(sortByRatingToggle.isVisible)
        XCTAssertTrue(sortByRatingToggle.hasValue(value: "0"))

        let availableFromButton = EditorHelper.availableFromButton.waitUntil(.visible)
        let availableUntilButton = EditorHelper.availableUntilButton.waitUntil(.visible)
        XCTAssertTrue(availableFromButton.isVisible)
        XCTAssertTrue(availableUntilButton.isVisible)

        // MARK: Finish creating discussion, check if it was successful
        doneButton.hit()

        // MARK: Check if creating new discussion was successful
        let newDiscussionElement = Helper.discussionButtonByLabel(label: newTitle).waitUntil(.visible)
        XCTAssertTrue(newDiscussionElement.isVisible)
    }
}
