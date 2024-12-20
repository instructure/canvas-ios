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
@testable import Core
import TestsFoundation

class ConversationTests: CoreTestCase {
    func testProperties() {
        XCTAssertEqual(Conversation.make().messages.count, 0)
        let conversation = Conversation.make(from: .make(audience: [ "1" ], messages: [.make()]))
        XCTAssertEqual(conversation.messages.count, 1)

        XCTAssertEqual(conversation.audience.first?.id, conversation.participants.first?.id)
        conversation.audienceIDs = []
        XCTAssertEqual(conversation.audienceIDsRaw, "")
        conversation.audienceIDsRaw = "1,2,3"
        XCTAssertEqual(conversation.audienceIDs, [ "1", "2", "3" ])

        conversation.workflowState = .archived
        XCTAssertEqual(conversation.workflowStateRaw, ConversationWorkflowState.archived.rawValue)
        conversation.workflowStateRaw = "bogus"
        XCTAssertEqual(conversation.workflowState, .read)
    }

    func testUsesLastAuthoredIfLastIsNull() {
        let apiConversation = APIConversation.make(
            last_message: nil,
            last_message_at: nil,
            last_authored_message: "message",
            last_authored_message_at: Date()
        )
        let conversation = Conversation.save(apiConversation, in: databaseClient)
        XCTAssertEqual(conversation.lastMessage, apiConversation.last_authored_message)
        XCTAssertEqual(conversation.lastMessageAt, apiConversation.last_authored_message_at)
    }
}
