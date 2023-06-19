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

import Foundation
@testable import Core
import XCTest

class APIConversationTests: CoreTestCase {
    func testMake() {
        XCTAssertEqual(APIConversation.make(messages: [.make()]).messages?.count, 1)
    }

    func testGetConversationsUnreadCountRequest() {
        XCTAssertEqual(GetConversationsUnreadCountRequest().path, "conversations/unread_count")
        let response = try? JSONDecoder().decode(GetConversationsUnreadCountRequest.Response.self, from: """
            { "unread_count": "5" }
            """.data(using: .utf8)!)
        XCTAssertEqual(response?.unread_count, 5)
    }

    func testGetConversationsRequest() {
        XCTAssertEqual(GetConversationsRequest(include: [], perPage: nil, scope: nil, filter: nil).path, "conversations")
        XCTAssertEqual(GetConversationsRequest(include: [], perPage: nil, scope: nil, filter: nil).queryItems, [])
        XCTAssertEqual(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: .sent, filter: "course_1").queryItems, [
            URLQueryItem(name: "include[]", value: "participant_avatars"),
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "scope", value: "sent"),
            URLQueryItem(name: "filter[]", value: "course_1"),
        ])
    }

    func testGetConversationRequest() {
        XCTAssertEqual(GetConversationRequest(id: "1", include: []).path, "conversations/1")
        XCTAssertEqual(GetConversationRequest(id: "1", include: []).queryItems, [])
        XCTAssertEqual(GetConversationRequest(id: "2", include: [.participant_avatars]).queryItems, [
            URLQueryItem(name: "include[]", value: "participant_avatars"),
        ])
    }

    func testPutConversationRequest() {
        let body = PutConversationRequest.Body(
            conversation:
            PutConversationRequest.ConversationContainer(
                id: "1",
                workflow_state: .unread
            )
        )
        let request = PutConversationRequest(id: "1", workflowState: .unread)
        XCTAssertEqual(request.path, "conversations/1")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, body)
    }

    func testPostAddMessageRequest() throws {
        let request = PostAddMessageRequest(conversationID: "1", body: .init(
            attachment_ids: nil,
            body: "This is a reply",
            media_comment_id: nil,
            media_comment_type: nil,
            recipients: ["1"]
        ))
        XCTAssertEqual(request.path, "conversations/1/add_message")
        XCTAssertEqual(request.method, .post)
    }

    func testPostConversationRequest() {
        let body = PostConversationRequest.Body(
            subject: "subject",
            body: "body",
            recipients: ["1"],
            context_code: "course_5",
            media_comment_id: "1",
            media_comment_type: .audio,
            attachment_ids: ["1"]
        )
        let request = PostConversationRequest(body: body)
        XCTAssertEqual(request.path, "conversations")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }

    func testStarConversationRequest() {
        let body = StarConversationRequest.Body(
            conversation:
                StarConversationRequest.ConversationContainer(
                id: "1",
                starred: true
            )
        )

        let request = StarConversationRequest(id: "1", starred: true)
        XCTAssertEqual(request.path, "conversations/1")
        XCTAssertEqual(request.body, body)
        XCTAssertEqual(request.method, .put)
    }
}
