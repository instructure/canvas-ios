//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
import TestsFoundation
@testable import Core

class InboxTests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { InboxTests.self }

    let conversation1 = APIConversation.make()
    var avatarURL: URL { conversation1.avatar_url.rawValue }

    override func setUp() {
        super.setUp()
        mockBaseRequests()
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: nil, filter: nil), value: [conversation1])
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: .sent, filter: nil), value: [])
        mockURL(avatarURL)
    }

    func testReply() {
        let before = APIConversation.make(
            id: "1",
            subject: "Subject One",
            avatar_url: avatarURL,
            messages: [.make(body: "Message Body")]
        )
        let after = APIConversation.make(
            id: "1",
            subject: "Subject One",
            avatar_url: avatarURL,
            messages: [.make(body: "Message Body"), .make(body: "This is a reply")]
        )

        mockData(GetConversationRequest(id: "1", include: [.participant_avatars]), value: before)
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: .sent, filter: nil), value: [after])
        mockData(PutConversationRequest(id: "1", workflowState: .read), value: before)
        mockData(PostAddMessageRequest(conversationID: "1", body: .init(
            attachment_ids: nil,
            body: "This is a reply",
            media_comment_id: nil,
            media_comment_type: nil,
            recipients: ["1"]
        )), value: after)
        logIn()
        TabBar.inboxTab.tap()
        app.find(id: "inbox.conversation-1").tap()
        NewMessage.replyButton.tap()
        NewMessage.bodyTextView.typeText("This is a reply")
        mockData(GetConversationRequest(id: "1", include: [.participant_avatars]), value: after)
        NewMessage.sendButton.tap().waitToVanish()
        app.find(labelContaining: "This is a reply").waitToExist()
    }

    func testCanMessageEntireClass() {
        mockData(GetSearchRecipientsRequest(context: .course(baseCourse.id.value), skipVisibilityChecks: true, includeContexts: true, perPage: 10), value: [])
        mockData(GetContextPermissionsRequest(context: .course(baseCourse.id.value)),
                 value: APIPermissions.make(send_messages: true, send_messages_all: true))

        logIn()
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tap()
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "1").tap()
        NewMessage.addRecipientButton.tap()
        MessageRecipientsSelection.messageAllInCourse(courseID: "1").tap()

        XCTAssertEqual(NewMessage.recipientLabel(id: "course_1").label(), "Course One")
        XCTAssertEqual(NewMessage.recipientDeleteButton(id: "course_1").label(),
                       "Delete recipient Course One")

        NewMessage.bodyTextView.typeText("hello")

        let conversation = APIConversation.make(id: "2", subject: "Subject Two", properties: [.last_author])
        mockEncodableRequest("conversations", value: conversation)
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: .sent, filter: nil),
                 value: [conversation])

        NewMessage.sendButton.tap().waitToVanish()

        app.find(labelContaining: "Subject One").waitToExist()
        XCTAssertFalse(app.find(labelContaining: "Subject Two").exists)

        Inbox.sentButton.tap()
        app.find(labelContaining: "Subject One").waitToVanish()
        app.find(labelContaining: "Subject Two").waitToExist()
    }

    func testCanMessageMultiple() {
        mockData(GetSearchRecipientsRequest(context: .course(baseCourse.id.value), skipVisibilityChecks: true, includeContexts: true, perPage: 10), value: [
            .make(id: 1, name: "Recepient One"),
            .make(id: 2, name: "Recepient Two"),
            .make(id: 3, name: "Recepient Three"),
        ])
        mockData(GetContextPermissionsRequest(context: .course(baseCourse.id.value)),
                 value: APIPermissions.make(send_messages: true))

        logIn()
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tap()
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "1").tap()

        NewMessage.addRecipientButton.tap()
        MessageRecipientsSelection.student(studentID: "1").tap()
        NewMessage.addRecipientButton.tap()
        MessageRecipientsSelection.student(studentID: "3").tap().waitToVanish()

        app.find(labelContaining: "Recepient One").waitToExist()
        app.find(labelContaining: "Recepient Three").waitToExist()

        NewMessage.subjectTextView.typeText("Subjective\n")
        NewMessage.recipientDeleteButton(id: "1").tap()
        app.find(labelContaining: "Recepient One").waitToVanish()

        NewMessage.addRecipientButton.tap()
        MessageRecipientsSelection.student(studentID: "2").tap().waitToVanish()

        app.find(labelContaining: "Recepient One").waitToVanish()
        app.find(labelContaining: "Recepient Two").waitToExist()
        app.find(labelContaining: "Recepient Three").waitToExist()

        NewMessage.cancelButton.tap().waitToVanish()
    }

    func testCanMessageAttachment() {
        mockData(GetSearchRecipientsRequest(context: .course(baseCourse.id.value), skipVisibilityChecks: true, includeContexts: true, perPage: 10), value: [.make()])
        mockData(GetContextPermissionsRequest(context: .course(baseCourse.id.value)),
                 value: APIPermissions.make(send_messages: true))

        let targetUrl = "https://canvas.s3.bucket.com/bucket/1"
        mockEncodableRequest("users/self/files", value: FileUploadTarget.make(upload_url: URL(string: targetUrl)!))
        mockEncodableRequest(targetUrl, value: ["id": "1"])
        mockEncodableRequest("files/1", value: APIFile.make())

        logIn()
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tap()
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "1").tap()

        NewMessage.addRecipientButton.tap()
        MessageRecipientsSelection.student(studentID: "1").tap()

        NewMessage.attachButton.tap()
        Attachments.addButton.tap()

        allowAccessToPhotos {
            app.find(label: "Choose From Library").tap()
        }

        let photo = app.find(labelContaining: "Photo, ")
        app.find(label: "All Photos").tapUntil { photo.exists }
        photo.tap()

        app.find(label: "Upload complete").waitToExist()
        let img = app.find(id: "AttachmentView.image")
        app.find(label: "Upload complete").tapUntil { img.exists == true }
        NavBar.dismissButton.tap()

        Attachments.dismissButton.tap()

        NewMessage.bodyTextView.typeText("message\n")

        mockEncodableRequest("conversations", value: APIConversation.make())

        NewMessage.sendButton.tap().waitToVanish()
    }
}
