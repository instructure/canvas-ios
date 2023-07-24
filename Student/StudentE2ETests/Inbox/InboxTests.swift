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
        let inboxTab = TabBar.inboxTab.waitToExist()
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.tap()
        let navBar = Helper.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        // MARK: Tap on the "New Message" button
        let newMessageButton = Helper.newMessageButton.waitToExist()
        XCTAssertTrue(newMessageButton.isVisible)

        newMessageButton.tap()

        // MARK: Check visibility of elements
        let cancelButton = ComposerHelper.cancelButton.waitToExist()
        XCTAssertTrue(cancelButton.isVisible)

        let attachButton = ComposerHelper.attachButton.waitToExist()
        XCTAssertTrue(attachButton.isVisible)

        var sendButton = ComposerHelper.sendButton.waitToExist()
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertFalse(sendButton.isEnabled)

        let courseSelectButton = ComposerHelper.courseSelectButton.waitToExist()
        XCTAssertTrue(courseSelectButton.isVisible)

        var recipientsLabel = ComposerHelper.recipientsLabel.waitToVanish()
        XCTAssertFalse(recipientsLabel.isVisible)

        var addRecipientButton = ComposerHelper.addRecipientButton.waitToVanish()
        XCTAssertFalse(addRecipientButton.isVisible)

        let subjectInput = ComposerHelper.subjectInput.waitToExist()
        XCTAssertTrue(subjectInput.isVisible)

        let individualSwitch = ComposerHelper.individualSwitch.waitToExist()
        XCTAssertTrue(individualSwitch.isVisible)
        XCTAssertEqual(individualSwitch.label().suffix(3), "Off")

        let messageInput = ComposerHelper.messageInput.waitToExist()
        XCTAssertTrue(messageInput.isVisible)

        // MARK: Select course from the list
        courseSelectButton.tap()
        let courseSelectionItem = ComposerHelper.courseSelectionItem(course: course).waitToExist()
        XCTAssertTrue(courseSelectionItem.isVisible)

        courseSelectionItem.tap()

        // MARK: Check if "Recipients" label and "Add recipients" button appeared
        recipientsLabel = ComposerHelper.recipientsLabel.waitToExist()
        XCTAssertTrue(recipientsLabel.isVisible)

        addRecipientButton = ComposerHelper.addRecipientButton.waitToExist()
        XCTAssertTrue(addRecipientButton.isVisible)

        // MARK: Add recipients
        addRecipientButton.tap()
        let recipientSelectionItem = ComposerHelper.recipientSelectionItem(course: course).waitToExist()
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
        let filterBySentButton = FilterHelper.sent.waitToExist()
        XCTAssertTrue(filterBySentButton.isVisible)

        filterBySentButton.tap()
        let sentMessage = Helper.conversationBySubject(subject: subject, unread: false).waitToExist()
        XCTAssertTrue(sentMessage.isVisible)

        // MARK: Check if message is recieved by the other student of the course
        Helper.logOut()
        logInDSUser(student2)
        Helper.navigateToInbox()
        let freshMessage = Helper.conversationBySubject(subject: subject).waitToExist()
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
        let inboxTab = TabBar.inboxTab.waitToExist()
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.tap()
        let navBar = Helper.navBar.waitToExist()
        XCTAssertTrue(navBar.isVisible)

        // MARK: Check filter options
        let allButton = FilterHelper.all.waitToExist()
        XCTAssertTrue(allButton.isVisible)
        XCTAssertTrue(allButton.isSelected)

        // MARK: Check if all is unread
        var readMessageButton = Helper.conversation(conversation: readConversation).waitToExist()
        var unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitToExist()
        var starredMessageButton = Helper.conversation(conversation: starredConversation).waitToExist()
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertEqual(readMessageButton.label().suffix(6), "Unread")
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertEqual(unreadMessageButton.label().suffix(6), "Unread")
        XCTAssertTrue(starredMessageButton.isVisible)
        XCTAssertEqual(starredMessageButton.label().suffix(6), "Unread")

        // MARK: Tap on message and check if it becomes read
        readMessageButton.tap()
        Helper.backButton.tap()
        readMessageButton = Helper.conversation(conversation: readConversation).waitToExist()
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertNotEqual(readMessageButton.label().suffix(6), "Unread")

        // MARK: Check "Unread" filter button
        let unreadButton = FilterHelper.unread.waitToExist()
        XCTAssertTrue(unreadButton.isVisible)
        XCTAssertFalse(unreadButton.isSelected)

        // MARK: Tap "Unread" filter button and check messages again
        unreadButton.tap()
        XCTAssertTrue(unreadButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitToExist()
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitToExist()
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Tap on message and mark it as starred
        starredMessageButton.tap()
        let starMessageButton = DetailsHelper.starButton.waitToExist()
        XCTAssertTrue(starMessageButton.isVisible)

        starMessageButton.tap()
        Helper.backButton.tap()

        // MARK: Check "Starred" filter button
        let starredButton = FilterHelper.starred.waitToExist()
        XCTAssertTrue(starredButton.isVisible)
        XCTAssertFalse(starredButton.isSelected)

        // MARK: Tap "Starred" filter button and check messages again
        starredButton.tap()
        XCTAssertTrue(starredButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitToVanish()
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitToExist()
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Check "Sent" filter button
        let sentButton = FilterHelper.sent.waitToExist()
        XCTAssertTrue(sentButton.isVisible)
        XCTAssertFalse(sentButton.isSelected)

        // MARK: Tap "Sent" filter button and check messages again
        sentButton.tap()
        XCTAssertTrue(sentButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitToVanish()
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitToVanish()
        XCTAssertFalse(readMessageButton.isVisible)
        XCTAssertFalse(unreadMessageButton.isVisible)
        XCTAssertFalse(starredMessageButton.isVisible)

        // MARK: Check "Archived" filter button
        let archivedButton = FilterHelper.archived.waitToExist()
        XCTAssertTrue(archivedButton.isVisible)
        XCTAssertFalse(archivedButton.isSelected)

        // MARK: Tap "Archived" filter button and check messages again
        archivedButton.tap()
        XCTAssertTrue(archivedButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitToVanish()
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitToVanish()
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitToVanish()
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
        let inboxTab = TabBar.inboxTab.waitToExist()
        XCTAssertTrue(inboxTab.isVisible)

        inboxTab.tap()

        // MARK: Check message item
        let messageButton = Helper.conversation(conversation: conversation).waitToExist()
        XCTAssertTrue(messageButton.isVisible)
        XCTAssertEqual(messageButton.label(), Helper.addDateToSubject(subject: conversation.subject, unread: true))

        messageButton.tap()

        // MARK: Check message details
        let detailsNavBar = DetailsHelper.navBar.waitToExist()
        XCTAssertTrue(detailsNavBar.isVisible)

        let starButton = DetailsHelper.starButton.waitToExist()
        XCTAssertTrue(starButton.isVisible)

        let subjectLabel = DetailsHelper.subjectLabel(conversation: conversation).waitToExist()
        XCTAssertTrue(subjectLabel.isVisible)

        let messageLabel = DetailsHelper.message(conversation: conversation).waitToExist()
        XCTAssertTrue(messageLabel.isVisible)

        let messageBody = DetailsHelper.bodyOfMessage(conversation: conversation).waitToExist()
        XCTAssertTrue(messageBody.isVisible)

        let replyButton = DetailsHelper.replyButton.waitToExist()
        XCTAssertTrue(replyButton.isVisible)

        // MARK: Check options
        let optionsButton = DetailsHelper.optionsButton.waitToExist()
        XCTAssertTrue(optionsButton.isVisible)
        optionsButton.tap()

        var replyOption = OptionsHelper.replyButton.waitToExist()
        XCTAssertTrue(replyOption.isVisible)

        var replyAllOption = OptionsHelper.replyAllButton.waitToExist()
        XCTAssertTrue(replyAllOption.isVisible)

        var forwardOption = OptionsHelper.forwardButton.waitToExist()
        XCTAssertTrue(forwardOption.isVisible)

        var deleteOption = OptionsHelper.deleteButton.waitToExist()
        XCTAssertTrue(deleteOption.isVisible)

        var cancelOption = OptionsHelper.cancelButton.waitToExist()
        XCTAssertTrue(cancelOption.isVisible)

        cancelOption.tap()

        // MARK: Check message options
        let messageOptions = DetailsHelper.messageOptions(conversation: conversation).waitToExist()
        XCTAssertTrue(messageOptions.isVisible)

        messageOptions.tap()
        replyOption = OptionsHelper.replyButton.waitToExist()
        XCTAssertTrue(replyOption.isVisible)

        replyAllOption = OptionsHelper.replyAllButton.waitToExist()
        XCTAssertTrue(replyAllOption.isVisible)

        forwardOption = OptionsHelper.forwardButton.waitToExist()
        XCTAssertTrue(forwardOption.isVisible)

        deleteOption = OptionsHelper.deleteButton.waitToExist()
        XCTAssertTrue(deleteOption.isVisible)

        cancelOption = OptionsHelper.cancelButton.waitToExist()
        XCTAssertTrue(cancelOption.isVisible)

        cancelOption.tap()
    }
}
