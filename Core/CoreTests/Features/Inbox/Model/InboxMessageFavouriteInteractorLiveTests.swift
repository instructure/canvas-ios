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
import Combine
@testable import Core

final class InboxMessageFavouriteInteractorLiveTests: CoreTestCase {

    // MARK: - Properties
    private var sut: InboxMessageFavouriteInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Life Cycle
    override func setUpWithError() throws {
        sut = InboxMessageFavouriteInteractorLive()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    // MARK: - Tests Functions
    func test_updateStarred_starredIsTrue() {
        // Given
        let conversationId = "1"
        let useCase = StarConversation(id: conversationId, starred: true)
        let result = APIConversation.make()
        // When
        api.mock(useCase.request, value: result)
        let expectation = XCTestExpectation(description: "make request")
        // Then
        sut.updateStarred(to: true, messageId: conversationId)
            .sink { _ in
            } receiveValue: { _ in
                XCTAssertTrue(useCase.starred)
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [expectation], timeout: 1)
    }
}
