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

import Combine
@testable import Core
import XCTest

class MessageDetailsInteractorLiveTests: CoreTestCase {
    private var testee: MessageDetailsInteractorLive!
    private var subscriptions = Set<AnyCancellable>()
    private let conversationID = "1"

    override func setUp() {
        super.setUp()
        mockConversation()

        testee = MessageDetailsInteractorLive(env: environment, conversationID: conversationID)

        waitForState(.data)
    }

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testPopulatesListItems() {
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.subject.value, "Subject")
        XCTAssertEqual(testee.messages.value[0].body, "Body")
        XCTAssertEqual(testee.starred.value, true)
    }

    func testRefresh() {
        let getConversationRequest = GetConversationRequest(id: conversationID, include: [.participant_avatars])
        api.mock(getConversationRequest, value: nil, response: nil, error: NSError.instructureError("Failed"))
        XCTAssertFinish(testee.refresh())
        waitForState(.error)

        mockConversation()

        XCTAssertFinish(testee.refresh())
        waitForState(.data)

        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.subject.value, "Subject")
    }

    func testUpdateStarred() {
        let starred = expectation(description: "Expected state reached")
        starred.assertForOverFulfill = false
        let subscription = testee
            .starred
            .sink {
                if $0 == true {
                    starred.fulfill()
                }
            }

        _ = testee.updateStarred(starred: true)

        wait(for: [starred], timeout: 1)
        subscription.cancel()
    }

    private func mockConversation() {
        let message = APIConversationMessage.make(
            id: "1",
            body: "Body"
        )
        let conversation = APIConversation.make(id: "1", subject: "Subject", starred: true, messages: [message])
        let getConversationRequest = GetConversationRequest(id: conversationID, include: [.participant_avatars])
        api.mock(getConversationRequest, value: conversation)
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        let subscription = testee
            .state
            .sink {
                if $0 == state {
                    stateUpdate.fulfill()
                }
            }
        wait(for: [stateUpdate], timeout: 1)
        subscription.cancel()
    }
}
