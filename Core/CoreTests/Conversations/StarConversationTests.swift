//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class StarConversationStateTests: CoreTestCase {

    func testPostRequest() {
        let conversationId = "testId"
        let useCase = StarConversation(id: conversationId, starred: true)
        let result = APIConversation.make()
        api.mock(useCase.request, value: result)

        let expectation = XCTestExpectation(description: "make request")
        useCase.makeRequest(environment: environment) { (conversation, _, _) in
            expectation.fulfill()
            XCTAssertEqual(conversation?.id, result.id)
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testPostRequestError() {
        let conversationId = "testId"
        let useCase = StarConversation(id: conversationId, starred: true)
        api.mock(useCase.request, error: NSError.instructureError("Error"))

        let expectation = XCTestExpectation(description: "make request")
        useCase.makeRequest(environment: environment) { (_, _, error) in
            expectation.fulfill()
            XCTAssertNotNil(error)
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testScope() {
        let conversationId = "testId"
        let starred = true
        let useCase = StarConversation(id: conversationId, starred: starred)

        XCTAssertEqual(useCase.scope.predicate, NSPredicate(key: #keyPath(InboxMessageListItem.messageId), equals: conversationId))
    }

    func testWrite() {
        let conversationId = "testId"
        let useCase = StarConversation(id: conversationId, starred: true)
        let apiconversation = APIConversation.make(starred: false)
        Conversation.save(apiconversation, in: databaseClient)
        InboxMessageListItem.save(
            apiconversation,
            currentUserID: environment.currentSession?.userID ?? "",
            isSent: true,
            contextFilter: .none,
            scopeFilter: .inbox,
            in: databaseClient
        )

        XCTAssertEqual((databaseClient.fetch() as [Conversation]).count, 1)
        XCTAssertEqual((databaseClient.fetch() as [Conversation]).first?.starred, false)

        let response = APIConversation.make(starred: true)
        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        XCTAssertEqual((databaseClient.fetch() as [Conversation]).count, 1)
        XCTAssertEqual((databaseClient.fetch() as [Conversation]).first?.starred, true)
    }
}
