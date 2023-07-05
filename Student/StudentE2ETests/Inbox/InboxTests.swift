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
    func testSendMessage() {
        // MARK: Seed the usual stuff
        let student1 = seeder.createUser()
        let student2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudents([student1, student2], in: course)

        // MARK: Get first user logged in
        logInDSUser(student1)
        let inboxTab = TabBar.inboxTab.waitToExist()
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.tap()
        let navBar = InboxHelper.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        // MARK: Tap on the "New Message" button
        let newMessageButton = InboxHelper.newMessageButton.waitToExist()
        XCTAssertTrue(newMessageButton.isVisible)

        newMessageButton.tap()

        // MARK: Check visibility of elements
        let cancelButton = InboxHelper.Composer.cancelButton.waitToExist()
        XCTAssertTrue(cancelButton.isVisible)

        let attachButton = InboxHelper.Composer.attachButton.waitToExist()
        XCTAssertTrue(attachButton.isVisible)

        var sendButton = InboxHelper.Composer.sendButton.waitToExist()
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertFalse(sendButton.isEnabled)

        let courseSelectButton = InboxHelper.Composer.courseSelectButton.waitToExist()
        XCTAssertTrue(courseSelectButton.isVisible)

        var recipientsLabel = InboxHelper.Composer.recipientsLabel.waitToVanish()
        XCTAssertFalse(recipientsLabel.isVisible)

        var addRecipientButton = InboxHelper.Composer.addRecipientButton.waitToVanish()
        XCTAssertFalse(addRecipientButton.isVisible)

        let subjectInput = InboxHelper.Composer.subjectInput.waitToExist()
        XCTAssertTrue(subjectInput.isVisible)

        let individualSwitch = InboxHelper.Composer.individualSwitch.waitToExist()
        XCTAssertTrue(individualSwitch.isVisible)
        XCTAssertEqual(individualSwitch.label().suffix(3), "Off")

        let messageInput = InboxHelper.Composer.messageInput.waitToExist()
        XCTAssertTrue(messageInput.isVisible)

        // MARK: Select course from the list
        courseSelectButton.tap()
        let courseSelectionItem = InboxHelper.Composer.courseSelectionItem(course: course).waitToExist()
        XCTAssertTrue(courseSelectionItem.isVisible)

        courseSelectionItem.tap()

        // MARK: Check if "Recipients" label and "Add recipients" button appeared
        recipientsLabel = InboxHelper.Composer.recipientsLabel.waitToExist()
        XCTAssertTrue(recipientsLabel.isVisible)

        addRecipientButton = InboxHelper.Composer.addRecipientButton.waitToExist()
        XCTAssertTrue(addRecipientButton.isVisible)

        // MARK: Add recipients
        addRecipientButton.tap()
        let recipientSelectionItem = InboxHelper.Composer.recipientSelectionItem(course: course).waitToExist()
        XCTAssertTrue(recipientSelectionItem.isVisible)

        recipientSelectionItem.tap()

        // MARK: Fill "Subject" and "Message" inputs
        let subject = "Sample Subject of \(student1.name)"
        subjectInput.tap().pasteText(subject)
        messageInput.tap().pasteText("Sample Message of \(student1.name)")

        // MARK: Tap "Send" button
        sendButton = sendButton.waitToExist()
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(sendButton.isEnabled)

        sendButton.tap()

        // MARK: Check message in "Sent" filter tab
        let filterBySentButton = InboxHelper.Filter.sent.waitToExist()
        XCTAssertTrue(filterBySentButton.isVisible)

        filterBySentButton.tap()
        let sentMessage = InboxHelper.conversationBySubject(subject: subject, unread: false).waitToExist()
        XCTAssertTrue(sentMessage.isVisible)

        // MARK: Check if message is recieved by the other student of the course
        InboxHelper.logOut()
        logInDSUser(student2)
        InboxHelper.navigateToInbox()
        let freshMessage = InboxHelper.conversationBySubject(subject: subject).waitToExist()
        XCTAssertTrue(freshMessage.isVisible)
    }

    func testInboxFilterTabs() {
        // MARK: Seed the usual stuff with a conversation
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        let readConversation = InboxHelper.createConversation(
            course: course, subject: "Read Message", recipients: [student.id])
        let unreadConversation = InboxHelper.createConversation(
            course: course, subject: "Unread Message", recipients: [student.id])
        let starredConversation = InboxHelper.createConversation(
            course: course, subject: "Starred Message", recipients: [student.id])

        // MARK: Get the user logged in
        logInDSUser(student)
        let inboxTab = TabBar.inboxTab.waitToExist()
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.tap()
        let navBar = InboxHelper.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check filter options
        let allButton = InboxHelper.Filter.all.waitToExist()
        XCTAssertTrue(allButton.isVisible)
        XCTAssertTrue(allButton.isSelected)

        // MARK: Check if all is unread
        var readMessageButton = InboxHelper.conversation(conversation: readConversation).waitToExist()
        var unreadMessageButton = InboxHelper.conversation(conversation: unreadConversation).waitToExist()
        var starredMessageButton = InboxHelper.conversation(conversation: starredConversation).waitToExist()
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertEqual(readMessageButton.label().suffix(6), "Unread")
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertEqual(unreadMessageButton.label().suffix(6), "Unread")
        XCTAssertTrue(starredMessageButton.isVisible)
        XCTAssertEqual(starredMessageButton.label().suffix(6), "Unread")

        // MARK: Tap on message and check if it becomes read
        readMessageButton.tap()
        InboxHelper.backButton.tap()
        readMessageButton = InboxHelper.conversation(conversation: readConversation).waitToExist()
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertNotEqual(readMessageButton.label().suffix(6), "Unread")

        // MARK: Check "Unread" filter button
        let unreadButton = InboxHelper.Filter.unread.waitToExist()
        XCTAssertTrue(unreadButton.isVisible)
        XCTAssertFalse(unreadButton.isSelected)

        // MARK: Tap "Unread" filter button and check messages again
        unreadButton.tap()
        XCTAssertTrue(unreadButton.isSelected)

        readMessageButton = InboxHelper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = InboxHelper.conversation(conversation: unreadConversation).waitToExist()
        starredMessageButton = InboxHelper.conversation(conversation: starredConversation).waitToExist()
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Tap on message and mark it as starred
        starredMessageButton.tap()
        let starMessageButton = InboxHelper.Details.starButton.waitToExist()
        XCTAssertTrue(starMessageButton.isVisible)

        starMessageButton.tap()
        InboxHelper.backButton.tap()

        // MARK: Check "Starred" filter button
        let starredButton = InboxHelper.Filter.starred.waitToExist()
        XCTAssertTrue(starredButton.isVisible)
        XCTAssertFalse(starredButton.isSelected)

        // MARK: Tap "Starred" filter button and check messages again
        starredButton.tap()
        XCTAssertTrue(starredButton.isSelected)

        readMessageButton = InboxHelper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = InboxHelper.conversation(conversation: unreadConversation).waitToVanish()
        starredMessageButton = InboxHelper.conversation(conversation: starredConversation).waitToExist()
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Check "Sent" filter button
        let sentButton = InboxHelper.Filter.sent.waitToExist()
        XCTAssertTrue(sentButton.isVisible)
        XCTAssertFalse(sentButton.isSelected)

        // MARK: Tap "Sent" filter button and check messages again
        sentButton.tap()
        XCTAssertTrue(sentButton.isSelected)

        readMessageButton = InboxHelper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = InboxHelper.conversation(conversation: unreadConversation).waitToVanish()
        starredMessageButton = InboxHelper.conversation(conversation: starredConversation).waitToVanish()
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertFalse(starredMessageButton.isVisible)

        // MARK: Check "Archived" filter button
        let archivedButton = InboxHelper.Filter.archived.waitToExist()
        XCTAssertTrue(archivedButton.isVisible)
        XCTAssertFalse(archivedButton.isSelected)

        // MARK: Tap "Archived" filter button and check messages again
        archivedButton.tap()
        XCTAssertTrue(archivedButton.isSelected)

        readMessageButton = InboxHelper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = InboxHelper.conversation(conversation: unreadConversation).waitToVanish()
        starredMessageButton = InboxHelper.conversation(conversation: starredConversation).waitToVanish()
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertFalse(starredMessageButton.isVisible)
    }

    func testNewUnreadMessage() {
        // MARK: Seed the usual stuff with a conversation
        let student1 = seeder.createUser()
        let student2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudents([student1, student2], in: course)

        let conversation = InboxHelper.createConversation(course: course, recipients: [student1.id, student2.id])

        // MARK: Get the first student logged in
        logInDSUser(student1)
        let inboxTab = TabBar.inboxTab.waitToExist()
        XCTAssertTrue(inboxTab.isVisible)
        let inboxTabValue = inboxTab.value()
        XCTAssertTrue(inboxTabValue!.contains("1 item"))

        inboxTab.tap()

        // MARK: Check inbox for new unread message
        let messageButton = InboxHelper.conversation(conversation: conversation).waitToExist()
        XCTAssertTrue(messageButton.isVisible)
        XCTAssertTrue(messageButton.label().contains(conversation.subject))

        // MARK: Check visibility of new message button
        let newMessageButton = InboxHelper.newMessageButton.waitToExist()
        XCTAssertTrue(newMessageButton.isVisible)
    }
}
