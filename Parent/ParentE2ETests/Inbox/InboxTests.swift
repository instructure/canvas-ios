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
    typealias Helper = InboxHelperParent
    typealias ComposeHelper = Helper.Compose
    typealias DetailsHelper = Helper.Details
    typealias ReplyHelper = Helper.Reply

    func testSendMessage() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let teacher = seeder.createUser()
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        let subject = "Sample Subject of \(parent.name)"
        let message = "Sample Message of \(parent.name)"
        seeder.enrollStudent(student, in: course)
        seeder.enrollParent(parent, in: course)
        seeder.enrollTeacher(teacher, in: course)
        seeder.addObservee(parent: parent, student: student)

        // MARK: Get the user logged in, navigate to Inbox
        logInDSUser(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let inboxButton = ProfileHelper.inboxButton.waitUntil(.visible)
        XCTAssertTrue(inboxButton.isVisible)

        inboxButton.hit()

        // MARK: Tap on the "New Message" button
        let newMessageButton = Helper.newMessageButton.waitUntil(.visible)
        XCTAssertTrue(newMessageButton.isVisible)

        newMessageButton.hit()
        let courseButton = Helper.courseButton(course: course).waitUntil(.visible)
        XCTAssertTrue(courseButton.isVisible)

        courseButton.hit()

        // MARK: Check visibility of elements
        let cancelButton = ComposeHelper.cancelButton.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)

        let attachButton = ComposeHelper.addAttachmentButton.waitUntil(.visible)
        XCTAssertTrue(attachButton.isVisible)

        var sendButton = ComposeHelper.sendButton.waitUntil(.visible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(sendButton.isDisabled)

        var recipientsButton = ComposeHelper.recipientsButton.waitUntil(.visible)
        XCTAssertTrue(recipientsButton.isVisible)

        let subjectInput = ComposeHelper.subjectInput.waitUntil(.visible)
        XCTAssertTrue(subjectInput.isVisible)

        let messageInput = ComposeHelper.messageInput.waitUntil(.visible)
        XCTAssertTrue(messageInput.isVisible)

        // MARK: Fill "Subject" and "Message" inputs
        subjectInput.hit()
        subjectInput.cutText()
        subjectInput.pasteText(text: subject)
        messageInput.hit()
        messageInput.pasteText(text: message)

        // MARK: Tap "Send" button
        sendButton = sendButton.waitUntil(.visible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(sendButton.isEnabled)

        sendButton.hit()
        let conversation = Helper.conversationBySubject(subject: subject).waitUntil(.visible)
        XCTAssertTrue(conversation.isVisible)
    }

    func testMessageDetails() {
        // MARK: Seed the usual stuff with a conversation
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        let conversation = InboxHelper.createConversation(course: course, recipients: [parent.id])
        let replyMessage = "This is my reply for \(conversation.id)"

        // MARK: Get the user logged in, navigate to Inbox
        logInDSUser(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let inboxButton = ProfileHelper.inboxButton.waitUntil(.visible)
        XCTAssertTrue(inboxButton.isVisible)

        inboxButton.hit()

        // MARK: Check message item
        let messageButton = Helper.conversation(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageButton.isVisible)
        XCTAssertTrue(messageButton.hasLabel(label: conversation.subject, strict: false))

        messageButton.hit()

        // MARK: Check message details
        let subjectLabel = DetailsHelper.subjectLabel(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(subjectLabel.isVisible)

        let messageLabel = DetailsHelper.messageLabel(conversation: conversation).waitUntil(.visible)
        XCTAssertTrue(messageLabel.isVisible)

        let replyButton = DetailsHelper.replyButton.waitUntil(.visible)
        XCTAssertTrue(replyButton.isVisible)
    }
}
