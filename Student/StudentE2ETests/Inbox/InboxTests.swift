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

    func testSendMessage() {
        // MARK: Seed the usual stuff
        let student1 = seeder.createUser()
        let student2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudents([student1, student2], in: course)

        // MARK: Get first user logged in
        logInDSUser(student1)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.hit()
        let navBar = Helper.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Tap on the "New Message" button
        let newMessageButton = Helper.newMessageButton.waitUntil(.visible)
        XCTAssertTrue(newMessageButton.isVisible)

        newMessageButton.hit()

        // MARK: Check visibility of elements
        let cancelButton = ComposerHelper.cancelButton.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)

        let attachButton = ComposerHelper.attachButton.waitUntil(.visible)
        XCTAssertTrue(attachButton.isVisible)

        var sendButton = ComposerHelper.sendButton.waitUntil(.visible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertFalse(sendButton.isEnabled)

        let courseSelectButton = ComposerHelper.courseSelectButton.waitUntil(.visible)
        XCTAssertTrue(courseSelectButton.isVisible)

        var recipientsLabel = ComposerHelper.recipientsLabel.waitUntil(.vanish)
        XCTAssertFalse(recipientsLabel.isVisible)

        var addRecipientButton = ComposerHelper.addRecipientButton.waitUntil(.vanish)
        XCTAssertFalse(addRecipientButton.isVisible)

        let subjectInput = ComposerHelper.subjectInput.waitUntil(.visible)
        XCTAssertTrue(subjectInput.isVisible)

        let individualSwitch = ComposerHelper.individualSwitch.waitUntil(.visible)
        XCTAssertTrue(individualSwitch.isVisible)
        XCTAssertEqual(individualSwitch.label.suffix(3), "Off")

        let messageInput = ComposerHelper.messageInput.waitUntil(.visible)
        XCTAssertTrue(messageInput.isVisible)

        // MARK: Select course from the list
        courseSelectButton.hit()
        let courseSelectionItem = ComposerHelper.courseSelectionItem(course: course).waitUntil(.visible)
        XCTAssertTrue(courseSelectionItem.isVisible)

        courseSelectionItem.hit()

        // MARK: Check if "Recipients" label and "Add recipients" button appeared
        recipientsLabel = ComposerHelper.recipientsLabel.waitUntil(.visible)
        XCTAssertTrue(recipientsLabel.isVisible)

        addRecipientButton = ComposerHelper.addRecipientButton.waitUntil(.visible)
        XCTAssertTrue(addRecipientButton.isVisible)

        // MARK: Add recipients
        addRecipientButton.hit()
        let recipientSelectionItem = ComposerHelper.recipientSelectionItem(course: course).waitUntil(.visible)
        XCTAssertTrue(recipientSelectionItem.isVisible)

        recipientSelectionItem.hit()

        // MARK: Fill "Subject" and "Message" inputs
        let subject = "Sample Subject of \(student1.name)"
        subjectInput.hit()
        subjectInput.pasteText(text: subject)
        messageInput.hit()
        messageInput.pasteText(text: "Sample Message of \(student1.name)")

        // MARK: Tap "Send" button
        sendButton = sendButton.waitUntil(.visible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(sendButton.isEnabled)

        sendButton.hit()

        // MARK: Check message in "Sent" filter tab
        let filterBySentButton = FilterHelper.sent.waitUntil(.visible)
        XCTAssertTrue(filterBySentButton.isVisible)

        filterBySentButton.hit()
        let sentMessage = Helper.conversationBySubject(subject: subject, unread: false).waitUntil(.visible)
        XCTAssertTrue(sentMessage.isVisible)

        // MARK: Check if message is recieved by the other student of the course
        Helper.logOut()
        logInDSUser(student2)
        Helper.navigateToInbox()
        let freshMessage = Helper.conversationBySubject(subject: subject).waitUntil(.visible)
        XCTAssertTrue(freshMessage.isVisible)
    }

    func testInboxFilterTabs() {
        // MARK: Seed the usual stuff with a conversation
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let readConversation = Helper.createConversation(
            course: course, subject: "Read Message", recipients: [student.id])
        let unreadConversation = Helper.createConversation(
            course: course, subject: "Unread Message", recipients: [student.id])
        let starredConversation = Helper.createConversation(
            course: course, subject: "Starred Message", recipients: [student.id])

        // MARK: Get the user logged in
        logInDSUser(student)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.hit()
        let navBar = Helper.navBar.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check filter options
        let allButton = FilterHelper.all.waitUntil(.visible)
        XCTAssertTrue(allButton.isVisible)
        XCTAssertTrue(allButton.isSelected)

        // MARK: Check if all is unread
        var readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.visible)
        var unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.visible)
        var starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.visible)
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertEqual(readMessageButton.label.suffix(6), "Unread")
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertEqual(unreadMessageButton.label.suffix(6), "Unread")
        XCTAssertTrue(starredMessageButton.isVisible)
        XCTAssertEqual(starredMessageButton.label.suffix(6), "Unread")

        // MARK: Tap on message and check if it becomes read
        readMessageButton.hit()
        Helper.backButton.hit()
        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.visible)
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertNotEqual(readMessageButton.label.suffix(6), "Unread")

        // MARK: Check "Unread" filter button
        let unreadButton = FilterHelper.unread.waitUntil(.visible)
        XCTAssertTrue(unreadButton.isVisible)
        XCTAssertFalse(unreadButton.isSelected)

        // MARK: Tap "Unread" filter button and check messages again
        unreadButton.hit()
        XCTAssertTrue(unreadButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.visible)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.visible)
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Tap on message and mark it as starred
        starredMessageButton.hit()
        let starMessageButton = DetailsHelper.starButton.waitUntil(.visible)
        XCTAssertTrue(starMessageButton.isVisible)

        starMessageButton.hit()
        Helper.backButton.hit()

        // MARK: Check "Starred" filter button
        let starredButton = FilterHelper.starred.waitUntil(.visible)
        XCTAssertTrue(starredButton.isVisible)
        XCTAssertFalse(starredButton.isSelected)

        // MARK: Tap "Starred" filter button and check messages again
        starredButton.hit()
        XCTAssertTrue(starredButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.visible)
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Check "Sent" filter button
        let sentButton = FilterHelper.sent.waitUntil(.visible)
        XCTAssertTrue(sentButton.isVisible)
        XCTAssertFalse(sentButton.isSelected)

        // MARK: Tap "Sent" filter button and check messages again
        sentButton.hit()
        XCTAssertTrue(sentButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.vanish)
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertFalse(starredMessageButton.isVisible)

        // MARK: Check "Archived" filter button
        let archivedButton = FilterHelper.archived.waitUntil(.visible)
        XCTAssertTrue(archivedButton.isVisible)
        XCTAssertFalse(archivedButton.isSelected)

        // MARK: Tap "Archived" filter button and check messages again
        archivedButton.hit()
        XCTAssertTrue(archivedButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.vanish)
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertFalse(starredMessageButton.isVisible)
    }

    func testMessageDetails() {
        typealias OptionsHelper = DetailsHelper.Options
        // MARK: Seed the usual stuff with a conversation
        let student1 = seeder.createUser()
        let student2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudents([student1, student2], in: course)

        let conversation = Helper.createConversation(course: course, recipients: [student1.id, student2.id])

        // MARK: Get the first student logged in
        logInDSUser(student1)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        inboxTab.hit()

        // MARK: Check message item
        let messageButton = Helper.conversation(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageButton.isVisible)
        XCTAssertEqual(messageButton.label, Helper.addDateToSubject(subject: conversation.subject, unread: true))

        messageButton.hit()

        // MARK: Check message details
        let detailsNavBar = DetailsHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let starButton = DetailsHelper.starButton.waitUntil(.visible)
        XCTAssertTrue(starButton.isVisible)

        let subjectLabel = DetailsHelper.subjectLabel(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(subjectLabel.isVisible)

        let messageLabel = DetailsHelper.message(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageLabel.isVisible)

        let messageBody = DetailsHelper.bodyOfMessage(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageBody.isVisible)

        let replyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(replyButton.isVisible)

        // MARK: Check options
        let optionsButton = DetailsHelper.optionsButton.waitUntil(.visible)
        XCTAssertTrue(optionsButton.isVisible)
        optionsButton.hit()

        var replyOption = OptionsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(replyOption.isVisible)

        var replyAllOption = OptionsHelper.replyAllButton.waitUntil(.visible)
        XCTAssertTrue(replyAllOption.isVisible)

        var forwardOption = OptionsHelper.forwardButton.waitUntil(.visible)
        XCTAssertTrue(forwardOption.isVisible)

        var deleteOption = OptionsHelper.deleteButton.waitUntil(.visible)
        XCTAssertTrue(deleteOption.isVisible)

        var cancelOption = OptionsHelper.cancelButton.waitUntil(.visible)
        XCTAssertTrue(cancelOption.isVisible)

        cancelOption.hit()

        // MARK: Check message options
        let messageOptions = DetailsHelper.messageOptions(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageOptions.isVisible)

        messageOptions.hit()
        replyOption = OptionsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(replyOption.isVisible)

        replyAllOption = OptionsHelper.replyAllButton.waitUntil(.visible)
        XCTAssertTrue(replyAllOption.isVisible)

        forwardOption = OptionsHelper.forwardButton.waitUntil(.visible)
        XCTAssertTrue(forwardOption.isVisible)

        deleteOption = OptionsHelper.deleteButton.waitUntil(.visible)
        XCTAssertTrue(deleteOption.isVisible)

        cancelOption = OptionsHelper.cancelButton.waitUntil(.visible)
        XCTAssertTrue(cancelOption.isVisible)

        cancelOption.hit()
    }
}
