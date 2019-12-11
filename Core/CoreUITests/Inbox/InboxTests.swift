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
    override var abstractTestClass: CoreUITestCase.Type { return InboxTests.self }

    func testCannotMessageEntireClassWhenDisabled() {
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tapUntil {
            NewMessage.selectCourseButton.exists
        }

        // Course Selection
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "263").tap()
        NewMessage.addRecipientButton.tap()

        // Recipients Selection
        MessageRecipientsSelection.studentsInCourse(courseID: "263").waitToExist()
        XCTAssertFalse(MessageRecipientsSelection.messageAllInCourse(courseID: "263").isVisible)
        MessageRecipientsSelection.studentsInCourse(courseID: "263").tap()
        XCTAssertFalse(MessageRecipientsSelection.messageAllStudents(courseID: "263").isVisible)
    }

    func testCannotMessageIndividialsWhenDisabled() {
        TabBar.inboxTab.tap()
        Inbox.newMessageButton.tapUntil {
            NewMessage.selectCourseButton.exists
        }

        // Course Selection
        NewMessage.selectCourseButton.tap()
        MessageCourseSelection.course(id: "263").tap()
        NewMessage.addRecipientButton.tap()

        // Recipients Selection
        MessageRecipientsSelection.studentsInCourse(courseID: "263").waitToExist()
        MessageRecipientsSelection.studentsInCourse(courseID: "263").tap()
        MessageRecipientsSelection.student(studentID: "613").waitToExist()
        XCTAssertFalse(MessageRecipientsSelection.student(studentID: "651").exists)
    }

    func testCanFilterMessagesAndShowsUnread() {
        XCTAssert(TabBar.inboxTab.value() == "2 items")
        TabBar.inboxTab.tap()

        Inbox.message(id: "47").waitToExist()
        Inbox.filterButton.tap()
        Inbox.filterOption("Assignment").waitToExist()
        Inbox.filterOption("Assignment").tap()
        Inbox.message(id: "47").waitToVanish()
        XCTAssert(Inbox.message(id: "48").isVisible)
    }
}

class MockedInboxTests: CoreUITestCase {
    override var user: UITestUser? { nil }
    let avatarURL = URL(string: "https://canvas.instructure.com/avatar/1")!

    override func setUp() {
        super.setUp()
        useMocksOnly()
        mockBaseRequests()
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 50), value: [
            .make(id: "1", subject: "Subject One", avatar_url: avatarURL),
        ])
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
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: .sent), value: [after])
        mockData(PutConversationRequest(id: "1", workflowState: .read), value: before)
        mockData(PostAddMessageRequest(id: "1", message: .init(
            recipients: ["1"],
            body: "This is a reply",
            subject: "Subject One",
            attachment_ids: nil,
            media_comment_id: nil,
            media_comment_type: nil,
            context_code: nil,
            sendIndividually: false)
        ), value: after)
        logIn()
        TabBar.inboxTab.tap()
        app.find(id: "inbox.conversation-1").tap()
        NewMessage.replyButton.tap()
        NewMessage.bodyTextView.typeText("This is a reply")
        mockData(GetConversationRequest(id: "1", include: [.participant_avatars]), value: after)
        NewMessage.sendButton.tap()
        TabBar.inboxTab.waitToExist()
        app.find(labelContaining: "This is a reply").waitToExist()
    }
}
