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

class UpdateConversationStateTests: CoreTestCase {
    func testPostRequest() {
        let conversationId = "testId"
        let newState = ConversationWorkflowState.read
        let useCase = UpdateConversationState(id: conversationId, state: newState)
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
        let newState = ConversationWorkflowState.read
        let useCase = UpdateConversationState(id: conversationId, state: newState)
        api.mock(useCase.request, error: NSError.instructureError("Error"))

        let expectation = XCTestExpectation(description: "make request")
        useCase.makeRequest(environment: environment) { (_, _, error) in
            expectation.fulfill()
            XCTAssertNotNil(error)
        }
        wait(for: [expectation], timeout: 0.1)
    }
}
