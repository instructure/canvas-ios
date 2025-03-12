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
import XCTest

class InboxTests: E2ETestCase {
    typealias Helper = InboxHelper
    typealias ComposeHelper = Helper.Composer
    typealias DetailsHelper = Helper.Details
    typealias FilterHelper = Helper.Filter
    typealias ParentCoursePicker = InboxHelperParent.CoursePicker

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
        let studentContextButton = ParentCoursePicker.studentContext(courseName: course.name, studentDisplayName: student.name)
        studentContextButton.hit()

        // MARK: Check visibility of elements
        let cancelButton = ComposeHelper.cancelButton.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)

        let attachButton = ComposeHelper.addAttachmentButton.waitUntil(.visible)
        XCTAssertTrue(attachButton.isVisible)

        var sendButton = ComposeHelper.sendButton.waitUntil(.visible)
        XCTAssertTrue(sendButton.isVisible)

        let selectedRecipient = ComposeHelper.recipientPillById(recipient: teacher).waitUntil(.visible)
        XCTAssertTrue(selectedRecipient.isVisible)

        let recipientsButton = ComposeHelper.addRecipientButton.waitUntil(.visible)
        XCTAssertTrue(recipientsButton.isVisible)

        let subjectInput = ComposeHelper.subjectInput.waitUntil(.visible)
        XCTAssertTrue(subjectInput.isVisible)

        let messageInput = ComposeHelper.bodyInput.waitUntil(.visible)
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

        // MARK: Check message in "Sent" filter tab
        let filterByTypeButton = Helper.filterByTypeButton.waitUntil(.visible)
        XCTAssertTrue(filterByTypeButton.isVisible)

        filterByTypeButton.hit()
        let filterBySentButton = FilterHelper.sent.waitUntil(.visible)
        XCTAssertTrue(filterBySentButton.isVisible)

        filterBySentButton.hit()

        let conversation = Helper.conversationBySubject(subject: subject).waitUntil(.visible)
        XCTAssertTrue(conversation.isVisible)
    }

    func testMessageDetails() {
        // MARK: Seed the usual stuff with a conversation
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        let conversation = InboxHelper.createConversation(course: course, recipients: [parent.id])

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
        let subjectLabel = DetailsHelper.subjectLabel.waitUntil(.visible)
        XCTAssertTrue(subjectLabel.isVisible)

        let messageLabel = DetailsHelper.bodyLabel.waitUntil(.visible)
        XCTAssertTrue(messageLabel.isVisible)
    }
}
