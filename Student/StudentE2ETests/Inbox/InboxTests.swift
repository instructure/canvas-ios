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
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(condition: .visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.tap()
        let navBar = Helper.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Tap on the "New Message" button
        let newMessageButton = Helper.newMessageButton.waitUntil(condition: .visible)
        XCTAssertTrue(newMessageButton.isVisible)

        newMessageButton.tap()

        // MARK: Check visibility of elements
        let cancelButton = ComposerHelper.cancelButton.waitUntil(condition: .visible)
        XCTAssertTrue(cancelButton.isVisible)

        let attachButton = ComposerHelper.attachButton.waitUntil(condition: .visible)
        XCTAssertTrue(attachButton.isVisible)

        var sendButton = ComposerHelper.sendButton.waitUntil(condition: .visible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertFalse(sendButton.isEnabled)

        let courseSelectButton = ComposerHelper.courseSelectButton.waitUntil(condition: .visible)
        XCTAssertTrue(courseSelectButton.isVisible)

        var recipientsLabel = ComposerHelper.recipientsLabel.waitUntil(condition: .vanish)
        XCTAssertFalse(recipientsLabel.isVisible)

        var addRecipientButton = ComposerHelper.addRecipientButton.waitUntil(condition: .vanish)
        XCTAssertFalse(addRecipientButton.isVisible)

        let subjectInput = ComposerHelper.subjectInput.waitUntil(condition: .visible)
        XCTAssertTrue(subjectInput.isVisible)

        let individualSwitch = ComposerHelper.individualSwitch.waitUntil(condition: .visible)
        XCTAssertTrue(individualSwitch.isVisible)
        XCTAssertEqual(individualSwitch.label.suffix(3), "Off")

        let messageInput = ComposerHelper.messageInput.waitUntil(condition: .visible)
        XCTAssertTrue(messageInput.isVisible)

        // MARK: Select course from the list
        courseSelectButton.tap()
        let courseSelectionItem = ComposerHelper.courseSelectionItem(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(courseSelectionItem.isVisible)

        courseSelectionItem.tap()

        // MARK: Check if "Recipients" label and "Add recipients" button appeared
        recipientsLabel = ComposerHelper.recipientsLabel.waitUntil(condition: .visible)
        XCTAssertTrue(recipientsLabel.isVisible)

        addRecipientButton = ComposerHelper.addRecipientButton.waitUntil(condition: .visible)
        XCTAssertTrue(addRecipientButton.isVisible)

        // MARK: Add recipients
        addRecipientButton.tap()
        let recipientSelectionItem = ComposerHelper.recipientSelectionItem(course: course).waitUntil(condition: .visible)
        XCTAssertTrue(recipientSelectionItem.isVisible)

        recipientSelectionItem.tap()

        // MARK: Fill "Subject" and "Message" inputs
        let subject = "Sample Subject of \(student1.name)"
        subjectInput.tap()
        subjectInput.pasteText(text: subject)
        messageInput.tap()
        messageInput.pasteText(text: "Sample Message of \(student1.name)")

        // MARK: Tap "Send" button
        sendButton = sendButton.waitUntil(condition: .visible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(sendButton.isEnabled)

        sendButton.tap()

        // MARK: Check message in "Sent" filter tab
        let filterBySentButton = FilterHelper.sent.waitUntil(condition: .visible)
        XCTAssertTrue(filterBySentButton.isVisible)

        filterBySentButton.tap()
        let sentMessage = Helper.conversationBySubject(subject: subject, unread: false).waitUntil(condition: .visible)
        XCTAssertTrue(sentMessage.isVisible)

        // MARK: Check if message is recieved by the other student of the course
        Helper.logOut()
        logInDSUser(student2)
        Helper.navigateToInbox()
        let freshMessage = Helper.conversationBySubject(subject: subject).waitUntil(condition: .visible)
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
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(condition: .visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.tap()
        let navBar = Helper.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check filter options
        let allButton = FilterHelper.all.waitUntil(condition: .visible)
        XCTAssertTrue(allButton.isVisible)
        XCTAssertTrue(allButton.isSelected)

        // MARK: Check if all is unread
        var readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(condition: .visible)
        var unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(condition: .visible)
        var starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(condition: .visible)
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertEqual(readMessageButton.label.suffix(6), "Unread")
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertEqual(unreadMessageButton.label.suffix(6), "Unread")
        XCTAssertTrue(starredMessageButton.isVisible)
        XCTAssertEqual(starredMessageButton.label.suffix(6), "Unread")

        // MARK: Tap on message and check if it becomes read
        readMessageButton.tap()
        Helper.backButton.hit()
        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(condition: .visible)
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertNotEqual(readMessageButton.label.suffix(6), "Unread")

        // MARK: Check "Unread" filter button
        let unreadButton = FilterHelper.unread.waitUntil(condition: .visible)
        XCTAssertTrue(unreadButton.isVisible)
        XCTAssertFalse(unreadButton.isSelected)

        // MARK: Tap "Unread" filter button and check messages again
        unreadButton.tap()
        XCTAssertTrue(unreadButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(condition: .vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(condition: .visible)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(condition: .visible)
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Tap on message and mark it as starred
        starredMessageButton.tap()
        let starMessageButton = DetailsHelper.starButton.waitUntil(condition: .visible)
        XCTAssertTrue(starMessageButton.isVisible)

        starMessageButton.tap()
        Helper.backButton.hit()

        // MARK: Check "Starred" filter button
        let starredButton = FilterHelper.starred.waitUntil(condition: .visible)
        XCTAssertTrue(starredButton.isVisible)
        XCTAssertFalse(starredButton.isSelected)

        // MARK: Tap "Starred" filter button and check messages again
        starredButton.tap()
        XCTAssertTrue(starredButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(condition: .vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(condition: .vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(condition: .visible)
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Check "Sent" filter button
        let sentButton = FilterHelper.sent.waitUntil(condition: .visible)
        XCTAssertTrue(sentButton.isVisible)
        XCTAssertFalse(sentButton.isSelected)

        // MARK: Tap "Sent" filter button and check messages again
        sentButton.tap()
        XCTAssertTrue(sentButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(condition: .vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(condition: .vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(condition: .vanish)
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertFalse(starredMessageButton.isVisible)

        // MARK: Check "Archived" filter button
        let archivedButton = FilterHelper.archived.waitUntil(condition: .visible)
        XCTAssertTrue(archivedButton.isVisible)
        XCTAssertFalse(archivedButton.isSelected)

        // MARK: Tap "Archived" filter button and check messages again
        archivedButton.tap()
        XCTAssertTrue(archivedButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(condition: .vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(condition: .vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(condition: .vanish)
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
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(condition: .visible)
        XCTAssertTrue(inboxTab.isVisible)

        inboxTab.tap()

        // MARK: Check message item
        let messageButton = Helper.conversation(conversation: conversation).waitUntil(condition: .visible)
        XCTAssertTrue(messageButton.isVisible)
        XCTAssertEqual(messageButton.label, Helper.addDateToSubject(subject: conversation.subject, unread: true))

        messageButton.tap()

        // MARK: Check message details
        let detailsNavBar = DetailsHelper.navBar.waitUntil(condition: .visible)
        XCTAssertTrue(detailsNavBar.isVisible)

        let starButton = DetailsHelper.starButton.waitUntil(condition: .visible)
        XCTAssertTrue(starButton.isVisible)

        let subjectLabel = DetailsHelper.subjectLabel(conversation: conversation).waitUntil(condition: .visible)
        XCTAssertTrue(subjectLabel.isVisible)

        let messageLabel = DetailsHelper.message(conversation: conversation).waitUntil(condition: .visible)
        XCTAssertTrue(messageLabel.isVisible)

        let messageBody = DetailsHelper.bodyOfMessage(conversation: conversation).waitUntil(condition: .visible)
        XCTAssertTrue(messageBody.isVisible)

        let replyButton = DetailsHelper.replyButton.waitUntil(condition: .visible)
        XCTAssertTrue(replyButton.isVisible)

        // MARK: Check options
        let optionsButton = DetailsHelper.optionsButton.waitUntil(condition: .visible)
        XCTAssertTrue(optionsButton.isVisible)
        optionsButton.tap()

        var replyOption = OptionsHelper.replyButton.waitUntil(condition: .visible)
        XCTAssertTrue(replyOption.isVisible)

        var replyAllOption = OptionsHelper.replyAllButton.waitUntil(condition: .visible)
        XCTAssertTrue(replyAllOption.isVisible)

        var forwardOption = OptionsHelper.forwardButton.waitUntil(condition: .visible)
        XCTAssertTrue(forwardOption.isVisible)

        var deleteOption = OptionsHelper.deleteButton.waitUntil(condition: .visible)
        XCTAssertTrue(deleteOption.isVisible)

        var cancelOption = OptionsHelper.cancelButton.waitUntil(condition: .visible)
        XCTAssertTrue(cancelOption.isVisible)

        cancelOption.tap()

        // MARK: Check message options
        let messageOptions = DetailsHelper.messageOptions(conversation: conversation).waitUntil(condition: .visible)
        XCTAssertTrue(messageOptions.isVisible)

        messageOptions.tap()
        replyOption = OptionsHelper.replyButton.waitUntil(condition: .visible)
        XCTAssertTrue(replyOption.isVisible)

        replyAllOption = OptionsHelper.replyAllButton.waitUntil(condition: .visible)
        XCTAssertTrue(replyAllOption.isVisible)

        forwardOption = OptionsHelper.forwardButton.waitUntil(condition: .visible)
        XCTAssertTrue(forwardOption.isVisible)

        deleteOption = OptionsHelper.deleteButton.waitUntil(condition: .visible)
        XCTAssertTrue(deleteOption.isVisible)

        cancelOption = OptionsHelper.cancelButton.waitUntil(condition: .visible)
        XCTAssertTrue(cancelOption.isVisible)

        cancelOption.tap()
    }
}
