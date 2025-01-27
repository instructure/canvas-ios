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

import XCTest
@testable import Core

class GetConversationsWithSentTests: CoreTestCase {
    func testMakeRequest() {
        let useCase = GetConversationsWithSent()
        api.mock(useCase.request, value: [.make()])
        api.mock(GetConversationsRequest(include: [.participant_avatars], perPage: 100, scope: .sent, filter: nil), value: [.make()])

        let expectation = XCTestExpectation(description: "make request")
        useCase.makeRequest(environment: environment) { (conversations, _, _) in
            expectation.fulfill()
            XCTAssertEqual(conversations?.count, 2)
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testMakeRequestError() {
        let useCase = GetConversationsWithSent()
        api.mock(useCase.request, error: NSError.instructureError("Error"))

        let expectation = XCTestExpectation(description: "make request")
        useCase.makeRequest(environment: environment) { (_, _, error) in
            expectation.fulfill()
            XCTAssertNotNil(error)
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testMakeRequestErrorSent() {
        let useCase = GetConversationsWithSent()
        api.mock(useCase.request, value: [.make()])
        api.mock(GetConversationsRequest(include: [.participant_avatars], perPage: 100, scope: .sent, filter: nil), error: NSError.instructureError("error"))

        let expectation = XCTestExpectation(description: "make request")
        useCase.makeRequest(environment: environment) { (_, _, error) in
            expectation.fulfill()
            XCTAssertNotNil(error)
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testScope() {
        Conversation.make(from: .make(id: "1", last_message_at: Date(fromISOString: "2020-01-20T00:00:00.000Z")))
        Conversation.make(from: .make(id: "2", last_message_at: Date(fromISOString: "2020-01-21T16:29:57.206Z")))
        let useCase = GetConversationsWithSent()

        let conversations: [Conversation] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(conversations.count, 2)
        XCTAssertEqual(conversations.first?.id, "2")
        XCTAssertEqual(conversations.last?.id, "1")
    }
}
