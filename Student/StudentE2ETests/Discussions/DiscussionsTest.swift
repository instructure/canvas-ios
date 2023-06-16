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

        let discussionDetailsFirstReplyLabel = DiscussionsHelper.discussionDetailsFirstReplyLabel.waitToExist()
        XCTAssertTrue(discussionDetailsFirstReplyLabel.isVisible)
        XCTAssertEqual(discussionDetailsFirstReplyLabel.label(), replyText)
    }
}
