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
        let conversation = Conversation.make(from: .make(messages: [.make()]))
        XCTAssertEqual(conversation.messages.count, 1)
        XCTAssertEqual(Conversation.make().messages.count, 0)

        XCTAssertEqual(conversation.participants.count, 1)
        conversation.participants = []
        XCTAssertEqual(conversation.participants.count, 0)

        conversation.workflowState = .archived
        XCTAssertEqual(conversation.workflowStateRaw, ConversationWorkflowState.archived.rawValue)
        conversation.workflowStateRaw = "bogus"
        XCTAssertEqual(conversation.workflowState, .read)
    }
}
