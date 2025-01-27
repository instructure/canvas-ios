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

final class RecipientInteractorLiveTests: CoreTestCase {

    // MARK: - Properties
    private var sut: RecipientInteractorLive!
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Life Cycle
    override func setUpWithError() throws {
        sut = RecipientInteractorLive()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    // MARK: - Tests
    func test_getRecipients_hasContext_mustHasFourItems() {
        // Given
        let context = RecipientContext(course: Course.make()).context
        api.mock(GetSearchRecipients(context: context), value: ReceiptStub.apiSearchRecipient)
        let didLoadRecipients = expectation(description: "didLoadRecipients")
        // When
        sut.getRecipients(by: context)
            .sink { result in
                // Then
                XCTAssertEqual(result.count, 5)
                didLoadRecipients.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [didLoadRecipients], timeout: 1)
    }

    func test_getRecipients_notHasContext_mustHasZeroItems() {
        // Given
        let context = RecipientContext(course: Course.make()).context
        api.mock(GetSearchRecipients(context: context), value: ReceiptStub.apiSearchRecipient)
        let didLoadRecipients = expectation(description: "didLoadRecipients")
        // When Then
        sut.getRecipients(by: nil)
            .sink { result in
                // Then
                XCTAssertEqual(result.count, 0)
                didLoadRecipients.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [didLoadRecipients], timeout: 1)
    }
}
