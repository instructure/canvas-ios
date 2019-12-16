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
        XCTAssertEqual(GetConversationsRequest().path, "conversations")
        XCTAssertEqual(GetConversationsRequest().queryItems, [])
        XCTAssertEqual(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: .sent).queryItems, [
            URLQueryItem(name: "include[]", value: "participant_avatars"),
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "scope", value: "sent"),
        ])
    }

    func testGetConversationRequest() {
        XCTAssertEqual(GetConversationRequest(id: "1").path, "conversations/1")
        XCTAssertEqual(GetConversationRequest(id: "1").queryItems, [])
        XCTAssertEqual(GetConversationRequest(id: "2", include: [.participant_avatars]).queryItems, [
            URLQueryItem(name: "include[]", value: "participant_avatars"),
        ])
    }

    func testPutConversationRequest() {
        let request = PutConversationRequest(id: "1", workflowState: .read)
        XCTAssertEqual(request.path, "conversations/1")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body?.id, "1")
        XCTAssertEqual(request.body?.workflow_state, .read)
    }

    func testPostAddMessageRequest() throws {
        let request = PostAddMessageRequest(id: "1", message: .init(
            recipients: ["1"],
            body: "This is a reply",
            subject: "Subject One",
            attachment_ids: nil,
            media_comment_id: nil,
            media_comment_type: nil,
            context_code: nil,
            bulk_message: nil)
        )
        XCTAssertEqual(request.path, "conversations/1/add_message")
        XCTAssertEqual(request.method, .post)
    }
}
