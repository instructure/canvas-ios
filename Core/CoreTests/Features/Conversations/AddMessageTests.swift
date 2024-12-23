//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class AddMessageTests: CoreTestCase {

    override func setUp() {
        super.setUp()
        Clock.mockNow(Date())
    }

    override func tearDown() {
        Clock.reset()
        super.tearDown()
    }

    func testWrite() {
        let conversation = Conversation.make(from: .make(
            message_count: 1,
            messages: [ .make() ]
        ))
        let useCase = AddMessage(conversationID: "1", body: "See-Gee-IN-YOU!")
        api.mock(useCase, value: .make(
            workflow_state: .read,
            last_message: "See-Gee-IN-YOU!",
            last_message_at: Clock.now,
            participants: [ .make(), .make(id: "2", name: "two") ],
            message_count: 2,
            audience: [ "1", "2" ],
            messages: [ .make(
                id: "2",
                body: "See-Gee-IN-YOU!",
                author_id: "2",
                participating_user_ids: [ "1", "2" ]
            ) ]
        ))

        useCase.fetch()
        XCTAssertEqual(conversation.workflowState, .read)
        XCTAssertEqual(conversation.lastMessage, "See-Gee-IN-YOU!")
        XCTAssertEqual(conversation.lastMessageAt?.isoString(), Clock.now.isoString())
        XCTAssertEqual(conversation.participants.count, 2)
        XCTAssertEqual(conversation.audience.count, 2)
        XCTAssertEqual(conversation.messages.count, 2)
        XCTAssertEqual(conversation.messageCount, 2)
    }

    func testUsesLastAuthoredIfLastIsNull() {
        let conversation = Conversation.make()

        let useCase = AddMessage(conversationID: "1", body: "See-Gee-IN-YOU")
        api.mock(useCase, value: APIConversation.make(
            last_message: nil,
            last_message_at: nil,
            last_authored_message: "See-Gee-IN-YOU",
            last_authored_message_at: Clock.now
        ))

        useCase.fetch()
        XCTAssertEqual(conversation.lastMessage, "See-Gee-IN-YOU")
        XCTAssertEqual(conversation.lastMessageAt?.isoString(), Clock.now.isoString())
    }
}
