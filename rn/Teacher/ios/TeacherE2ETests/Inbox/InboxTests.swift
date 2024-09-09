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

class InboxTests: E2ETestCase {
    typealias Helper = InboxHelper
    typealias ComposerHelper = Helper.Composer
    typealias FilterHelper = Helper.Filter
    typealias DetailsHelper = Helper.Details
    typealias OptionsHelper = DetailsHelper.Options

    func testSendMessage() {
        // MARK: Seed the usual stuff
        let teacher1 = seeder.createUser()
        let teacher2 = seeder.createUser()
        let course = seeder.createCourse()
        let subject = "Sample Subject of \(teacher1.name)"
        let message = "Sample Message of \(teacher1.name)"
        seeder.enrollTeacher(teacher1, in: course)
        seeder.enrollTeacher(teacher2, in: course)

        // MARK: Get first user logged in
        logInDSUser(teacher1)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox, Tap on the "New Message" button
        inboxTab.hit()
        let newMessageButton = Helper.newMessageButton.waitUntil(.visible)
        XCTAssertTrue(newMessageButton.isVisible)

        newMessageButton.hit()

        // MARK: Check visibility of elements
        let cancelButton = ComposerHelper.cancelButton.waitUntil(.visible)
        let subjectLabel = ComposerHelper.subjectLabel.waitUntil(.visible)
        let subjectInput = ComposerHelper.subjectInput.waitUntil(.visible)
        let sendButton = ComposerHelper.sendButton.waitUntil(.visible)
        let selectCourseButton = ComposerHelper.selectCourseButton.waitUntil(.visible)
        let individualToggle = ComposerHelper.individualToggle.waitUntil(.visible)
        let addAttachmentButton = ComposerHelper.addAttachmentButton.waitUntil(.visible)
        let bodyInput = ComposerHelper.bodyInput.waitUntil(.visible)
        let addRecipientButton = ComposerHelper.addRecipientButton.waitUntil(.vanish)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(subjectLabel.isVisible)
        XCTAssertTrue(subjectInput.isVisible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(selectCourseButton.isVisible)
        XCTAssertTrue(individualToggle.isVisible)
        XCTAssertTrue(addAttachmentButton.isVisible)
        XCTAssertTrue(addRecipientButton.isVanished)
        XCTAssertTrue(bodyInput.isVisible)

        // MARK: Select course from the list
        selectCourseButton.hit()
        let courseItem = ComposerHelper.courseItem(course: course).waitUntil(.visible)
        XCTAssertTrue(courseItem.isVisible)

        courseItem.hit()
        XCTAssertTrue(addRecipientButton.waitUntil(.visible).isVisible)

        // MARK: Add "teacher2" as recipient
        addRecipientButton.hit()
        let allInCourseButton = ComposerHelper.Recipients.allInCourse(course: course).waitUntil(.visible)
        let teachersButton = ComposerHelper.Recipients.teachers.waitUntil(.visible)
        let doneButton = ComposerHelper.Recipients.doneButton.waitUntil(.visible)
        XCTAssertTrue(allInCourseButton.isVisible)
        XCTAssertTrue(teachersButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        teachersButton.hit()
        let recipientButton = ComposerHelper.recipient(user: teacher2).waitUntil(.visible)
        XCTAssertTrue(recipientButton.isVisible)

        recipientButton.hit()
        XCTAssertTrue(recipientButton.hasLabel(label: "Selected", strict: false))

        doneButton.hit()
        let recipientPill = ComposerHelper.recipientPillById(recipient: teacher2).waitUntil(.visible)
        XCTAssertTrue(recipientPill.isVisible)

        // MARK: Fill "Subject" and "Message" inputs
        subjectInput.writeText(text: subject)
        bodyInput.writeText(text: message)

        // MARK: Tap "Send" button
        XCTAssertTrue(sendButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(sendButton.isEnabled)

        sendButton.hit()

        // MARK: Check message in "Sent" filter tab
        let filterByTypeButton = Helper.filterByTypeButton.waitUntil(.visible)
        XCTAssertTrue(filterByTypeButton.isVisible)

        filterByTypeButton.hit()
        let filterBySentButton = FilterHelper.sent.waitUntil(.visible)
        XCTAssertTrue(filterBySentButton.isVisible)

        filterBySentButton.hit()
        let sentMessage = Helper.conversationBySubject(subject: subject).waitUntil(.visible)
        XCTAssertTrue(sentMessage.isVisible)

        // MARK: Check if message is recieved by the other teacher of the course
        Helper.logOut()
        logInDSUser(teacher2)
        Helper.navigateToInbox()
        let freshMessage = Helper.conversationBySubject(subject: subject).waitUntil(.visible)
        XCTAssertTrue(freshMessage.isVisible)
    }

    func testInboxFilterTabs() {
        // MARK: Seed the usual stuff with a conversation
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        Helper.createConversation(course: course, recipients: [teacher.id])

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.hit()
        let newMessageButton = Helper.newMessageButton.waitUntil(.visible)
        let filterByCourseButton = Helper.filterByCourseButton.waitUntil(.visible)
        let filterByTypeButton = Helper.filterByTypeButton.waitUntil(.visible)
        XCTAssertTrue(newMessageButton.isVisible)
        XCTAssertTrue(filterByCourseButton.isVisible)
        XCTAssertTrue(filterByTypeButton.isVisible)

        // MARK: Check filter by course options
        filterByCourseButton.hit()
        let allCoursesOption = Helper.Filter.allCourses.waitUntil(.visible)
        let courseOption = Helper.Filter.course(course: course).waitUntil(.visible)
        let cancelButton = Helper.Filter.cancelButton.waitUntil(.visible)
        XCTAssertTrue(allCoursesOption.isVisible)
        XCTAssertTrue(courseOption.isVisible)
        XCTAssertTrue(cancelButton.isVisible)

        // MARK: Check filter by type options
        cancelButton.hit()
        filterByTypeButton.hit()
        let inboxOption = Helper.Filter.inbox.waitUntil(.visible)
        let unreadOption = Helper.Filter.unread.waitUntil(.visible)
        let starredOption = Helper.Filter.starred.waitUntil(.visible)
        let sentOption = Helper.Filter.sent.waitUntil(.visible)
        let archivedOption = Helper.Filter.archived.waitUntil(.visible)
        XCTAssertTrue(inboxOption.isVisible)
        XCTAssertTrue(unreadOption.isVisible)
        XCTAssertTrue(starredOption.isVisible)
        XCTAssertTrue(sentOption.isVisible)
        XCTAssertTrue(archivedOption.isVisible)
        XCTAssertTrue(cancelButton.waitUntil(.visible).isVisible)
    }

    func testMessageDetails() {
        // MARK: Seed the usual stuff with a conversation
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)
        let conversation = Helper.createConversation(course: course, recipients: [teacher.id])

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        inboxTab.hit()

        // MARK: Check message item
        let messageButton = Helper.conversation(conversation: conversation).waitUntil(.visible)
        let messageParticipantLabel = Helper.conversationParticipantLabel(conversation: conversation).waitUntil(.visible)
        let messageDateLabel = Helper.conversationDateLabel(conversation: conversation).waitUntil(.visible)
        let messageTitleLabel = Helper.conversationTitleLabel(conversation: conversation).waitUntil(.visible)
        let messageMessageLabel = Helper.conversationMessageLabel(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageButton.isVisible)
        XCTAssertTrue(messageButton.hasLabel(label: "Unread", strict: false))
        XCTAssertTrue(messageParticipantLabel.isVisible)
        XCTAssertTrue(messageDateLabel.isVisible)
        XCTAssertTrue(messageTitleLabel.isVisible)
        XCTAssertTrue(messageTitleLabel.hasLabel(label: conversation.subject))
        XCTAssertTrue(messageMessageLabel.isVisible)
        XCTAssertTrue(messageMessageLabel.hasLabel(label: conversation.last_authored_message))

        messageButton.hit()

        // MARK: Check message details
        let optionsButton = DetailsHelper.optionsButton.waitUntil(.visible)
        let moreButton = DetailsHelper.moreButton.waitUntil(.visible)
        let replyButton = DetailsHelper.replyButton.waitUntil(.visible)
        let replyImage = DetailsHelper.replyImage.waitUntil(.visible)
        let authorLabel = DetailsHelper.authorLabel.waitUntil(.visible)
        let starButton = DetailsHelper.starButton.waitUntil(.visible)
        let dateLabel = DetailsHelper.dateLabel.waitUntil(.visible)
        let bodyLabel = DetailsHelper.bodyLabel.waitUntil(.visible)
        let subjectLabel = DetailsHelper.subjectLabel.waitUntil(.visible)
        XCTAssertTrue(optionsButton.isVisible)
        XCTAssertTrue(moreButton.isVisible)
        XCTAssertTrue(replyButton.isVisible)
        XCTAssertTrue(replyImage.isVisible)
        XCTAssertTrue(authorLabel.isVisible)
        XCTAssertTrue(starButton.isVisible)
        XCTAssertTrue(dateLabel.isVisible)
        XCTAssertTrue(bodyLabel.isVisible)
        XCTAssertTrue(subjectLabel.isVisible)
        XCTAssertTrue(bodyLabel.hasLabel(label: conversation.last_authored_message))
        XCTAssertTrue(subjectLabel.hasLabel(label: conversation.subject))

        // MARK: Check "More options"
        moreButton.hit()

        var replyOption = OptionsHelper.replyButton.waitUntil(.visible)
        var replyAllOption = OptionsHelper.replyAllButton.waitUntil(.visible)
        var forwardOption = OptionsHelper.forwardButton.waitUntil(.visible)
        let markAsUnreadOption = OptionsHelper.markAsUnreadButton.waitUntil(.visible)
        let archiveOption = OptionsHelper.archiveButton.waitUntil(.visible)
        var deleteOption = OptionsHelper.deleteButton.waitUntil(.visible)
        XCTAssertTrue(replyOption.isVisible)
        XCTAssertTrue(replyAllOption.isVisible)
        XCTAssertTrue(forwardOption.isVisible)
        XCTAssertTrue(markAsUnreadOption.isVisible)
        XCTAssertTrue(archiveOption.isVisible)
        XCTAssertTrue(deleteOption.isVisible)

        moreButton.forceTap()

        // MARK: Check "Conversation options"
        optionsButton.hit()
        replyOption = OptionsHelper.replyButton.waitUntil(.visible)
        replyAllOption = OptionsHelper.replyAllButton.waitUntil(.visible)
        forwardOption = OptionsHelper.forwardButton.waitUntil(.visible)
        deleteOption = OptionsHelper.deleteButton.waitUntil(.visible)
        XCTAssertTrue(replyOption.isVisible)
        XCTAssertTrue(replyAllOption.isVisible)
        XCTAssertTrue(forwardOption.isVisible)
        XCTAssertTrue(deleteOption.isVisible)
    }
}
