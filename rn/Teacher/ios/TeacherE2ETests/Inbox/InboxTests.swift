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

        // MARK: Get teacher1 logged in
        logInDSUser(teacher1)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Navigate to Inbox
        inboxTab.hit()
        let navBar = Helper.navBar.waitUntil(.visible)
        let newMessageButton = Helper.newMessageButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(newMessageButton.isVisible)

        // MARK: Tap "New Message" button, Check visibility of elements
        newMessageButton.hit()
        let cancelButton = ComposerHelper.cancelButton.waitUntil(.visible)
        let attachButton = ComposerHelper.attachButton.waitUntil(.visible)
        var sendButton = ComposerHelper.sendButton.waitUntil(.visible)
        let courseSelectButton = ComposerHelper.courseSelectButton.waitUntil(.visible)
        var recipientsLabel = ComposerHelper.recipientsLabel.waitUntil(.vanish)
        var addRecipientButton = ComposerHelper.addRecipientButton.waitUntil(.vanish)
        let subjectInput = ComposerHelper.subjectInput.waitUntil(.visible)
        let individualSwitch = ComposerHelper.individualSwitch.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(attachButton.isVisible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(sendButton.isDisabled)
        XCTAssertTrue(courseSelectButton.isVisible)
        XCTAssertTrue(recipientsLabel.isVanished)
        XCTAssertTrue(addRecipientButton.isVanished)
        XCTAssertTrue(subjectInput.isVisible)
        XCTAssertTrue(individualSwitch.isVisible)
        XCTAssertTrue(individualSwitch.labelHasSuffix("Off"))

        let messageInput = ComposerHelper.messageInput.waitUntil(.visible)
        XCTAssertTrue(messageInput.isVisible)

        // MARK: Select course from the list
        courseSelectButton.hit()
        let courseSelectionItem = ComposerHelper.courseSelectionItem(course: course).waitUntil(.visible)
        XCTAssertTrue(courseSelectionItem.isVisible)

        courseSelectionItem.hit()

        // MARK: Check if "Recipients" label and "Add recipients" button appeared
        addRecipientButton = ComposerHelper.addRecipientButton.waitUntil(.visible)
        recipientsLabel = ComposerHelper.recipientsLabel.waitUntil(.visible)
        XCTAssertTrue(recipientsLabel.isVisible)
        XCTAssertTrue(addRecipientButton.isVisible)

        // MARK: Add recipients
        addRecipientButton.hit()
        let recipientSelectionItem = ComposerHelper.recipientSelectionItem(course: course).waitUntil(.visible)
        XCTAssertTrue(recipientSelectionItem.isVisible)

        recipientSelectionItem.hit()

        // MARK: Fill "Subject" and "Message" inputs
        subjectInput.hit()
        subjectInput.pasteText(text: subject)
        messageInput.hit()
        messageInput.pasteText(text: message)

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

        // MARK: Check if message is recieved by teacher2
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

        let readConversation = Helper.createConversation(
            course: course, subject: "Read Message", recipients: [teacher.id])
        let unreadConversation = Helper.createConversation(
            course: course, subject: "Unread Message", recipients: [teacher.id])
        let starredConversation = Helper.createConversation(
            course: course, subject: "Starred Message", recipients: [teacher.id])

        // MARK: Get the user logged in
        logInDSUser(teacher)
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
        XCTAssertTrue(readMessageButton.labelHasSuffix("Unread"))
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertTrue(unreadMessageButton.labelHasSuffix("Unread"))
        XCTAssertTrue(starredMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.labelHasSuffix("Unread"))

        // MARK: Tap on message and check if it becomes read
        readMessageButton.hit()
        let backButton = Helper.backButton.waitUntil(.visible, timeout: 5)
        if backButton.isVisible { backButton.hit() }
        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.visible)
        XCTAssertTrue(readMessageButton.isVisible)
        XCTAssertFalse(readMessageButton.labelHasSuffix("Unread"))

        // MARK: Check "Unread" filter button
        let unreadButton = FilterHelper.unread.waitUntil(.visible)
        XCTAssertTrue(unreadButton.isVisible)
        XCTAssertTrue(unreadButton.isUnselected)

        // MARK: Tap "Unread" filter button and check messages again
        unreadButton.hit()
        XCTAssertTrue(unreadButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.visible)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.visible)
        XCTAssertTrue(readMessageButton.isVanished)
        XCTAssertTrue(unreadMessageButton.isVisible)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Tap on message and mark it as starred
        starredMessageButton.hit()
        let starMessageButton = DetailsHelper.starButton.waitUntil(.visible)
        XCTAssertTrue(starMessageButton.isVisible)

        starMessageButton.hit()
        backButton.waitUntil(.visible, timeout: 5)
        if backButton.isVisible { backButton.hit() }

        // MARK: Check "Starred" filter button
        let starredButton = FilterHelper.starred.waitUntil(.visible)
        XCTAssertTrue(starredButton.isVisible)
        XCTAssertTrue(starredButton.isUnselected)

        // MARK: Tap "Starred" filter button and check messages again
        starredButton.hit()
        XCTAssertTrue(starredButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.visible)
        XCTAssertTrue(readMessageButton.isVanished)
        XCTAssertTrue(unreadMessageButton.isVanished)
        XCTAssertTrue(starredMessageButton.isVisible)

        // MARK: Check "Sent" filter button
        let sentButton = FilterHelper.sent.waitUntil(.visible)
        XCTAssertTrue(sentButton.isVisible)
        XCTAssertTrue(sentButton.isUnselected)

        // MARK: Tap "Sent" filter button and check messages again
        sentButton.hit()
        XCTAssertTrue(sentButton.isSelected)

        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.vanish)
        XCTAssertTrue(readMessageButton.isVanished)
        XCTAssertTrue(unreadMessageButton.isVanished)
        XCTAssertTrue(starredMessageButton.isVanished)

        // MARK: Check "Archived" filter button
        let archivedButton = FilterHelper.archived.waitUntil(.visible)
        XCTAssertTrue(archivedButton.isVisible)
        XCTAssertTrue(archivedButton.isUnselected)

        // MARK: Tap "Archived" filter button and check messages again
        archivedButton.hit()
        readMessageButton = Helper.conversation(conversation: readConversation).waitUntil(.vanish)
        unreadMessageButton = Helper.conversation(conversation: unreadConversation).waitUntil(.vanish)
        starredMessageButton = Helper.conversation(conversation: starredConversation).waitUntil(.vanish)
        XCTAssertTrue(archivedButton.isSelected)
        XCTAssertTrue(readMessageButton.isVanished)
        XCTAssertTrue(unreadMessageButton.isVanished)
        XCTAssertTrue(starredMessageButton.isVanished)
    }

    func testMessageDetails() {
        // MARK: Seed the usual stuff with a conversation
        let teacher1 = seeder.createUser()
        let teacher2 = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeachers([teacher1, teacher2], in: course)
        let conversation = Helper.createConversation(course: course, recipients: [teacher1.id, teacher2.id])

        // MARK: Get teacher1 logged in
        logInDSUser(teacher1)
        let inboxTab = Helper.TabBar.inboxTab.waitUntil(.visible)
        XCTAssertTrue(inboxTab.isVisible)

        // MARK: Check message item
        inboxTab.hit()
        let messageButton = Helper.conversation(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageButton.isVisible)
        XCTAssertTrue(messageButton.hasLabel(label: Helper.addDateToSubject(subject: conversation.subject, unread: true)))

        // MARK: Check message details
        messageButton.hit()
        let detailsNavBar = DetailsHelper.navBar.waitUntil(.visible)
        let starButton = DetailsHelper.starButton.waitUntil(.visible)
        let subjectLabel = DetailsHelper.subjectLabel(conversation: conversation).waitUntil(.visible)
        let messageLabel = DetailsHelper.message(conversation: conversation).waitUntil(.visible)
        let messageBody = DetailsHelper.bodyOfMessage(conversation: conversation).waitUntil(.visible)
        let replyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(detailsNavBar.isVisible)
        XCTAssertTrue(starButton.isVisible)
        XCTAssertTrue(subjectLabel.isVisible)
        XCTAssertTrue(messageLabel.isVisible)
        XCTAssertTrue(messageBody.isVisible)
        XCTAssertTrue(replyButton.isVisible)

        // MARK: Check options
        let optionsButton = DetailsHelper.optionsButton.waitUntil(.visible)
        XCTAssertTrue(optionsButton.isVisible)
        optionsButton.hit()

        var replyOption = OptionsHelper.replyButton.waitUntil(.visible)
        var replyAllOption = OptionsHelper.replyAllButton.waitUntil(.visible)
        var forwardOption = OptionsHelper.forwardButton.waitUntil(.visible)
        var deleteOption = OptionsHelper.deleteButton.waitUntil(.visible)
        XCTAssertTrue(replyOption.isVisible)
        XCTAssertTrue(replyAllOption.isVisible)
        XCTAssertTrue(forwardOption.isVisible)
        XCTAssertTrue(deleteOption.isVisible)

        // On iPhone: There is a cancel button to hit
        // On iPad: No cancel button, need to tap somewhere outside the box
        let cancelOption = OptionsHelper.cancelButton.waitUntil(.visible, timeout: 5)
        if cancelOption.isVisible {
            cancelOption.hit()
        } else {
            optionsButton.forceTap()
        }

        // MARK: Check message options
        let messageOptions = DetailsHelper.messageOptions(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageOptions.isVisible)

        messageOptions.hit()
        replyOption = OptionsHelper.replyButton.waitUntil(.visible)
        replyAllOption = OptionsHelper.replyAllButton.waitUntil(.visible)
        forwardOption = OptionsHelper.forwardButton.waitUntil(.visible)
        deleteOption = OptionsHelper.deleteButton.waitUntil(.visible)
        XCTAssertTrue(replyOption.isVisible)
        XCTAssertTrue(replyAllOption.isVisible)
        XCTAssertTrue(forwardOption.isVisible)
        XCTAssertTrue(deleteOption.isVisible)

        // On iPhone: There is a cancel button to hit
        // On iPad: No cancel button, need to tap somewhere outside the box
        cancelOption.waitUntil(.visible, timeout: 5)
        if cancelOption.isVisible {
            cancelOption.hit()
        } else {
            optionsButton.forceTap()
        }

        XCTAssertTrue(deleteOption.waitUntil(.vanish).isVanished)
    }
}
