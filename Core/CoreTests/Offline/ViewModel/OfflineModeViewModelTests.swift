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

import Core
import Combine
import XCTest

class OfflineModeViewModelTests: XCTestCase {
    let mockInteractor = MockOfflineModeInteractor()

    func testInitialOfflineValue() {
        let testee = OfflineModeViewModel(interactor: mockInteractor)

        XCTAssertTrue(testee.isOffline)
    }

    func testOfflineValueUpdates() {
        // MARK: - GIVEN
        let testee = OfflineModeViewModel(interactor: mockInteractor)

        let willChangeExpectation = expectation(description: "objectWillChange event received")
        willChangeExpectation.expectedFulfillmentCount = 1

        let subscription = testee
            .objectWillChange
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    willChangeExpectation.fulfill()
                }
            )

        // MARK: - WHEN
        mockInteractor.offlineMode.send(false)

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        XCTAssertFalse(testee.isOffline)
        subscription.cancel()
    }
}

class MockOfflineModeInteractor: OfflineModeInteractor {
    func isFeatureFlagEnabled() -> Bool {
        false
    }

    func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }

    let offlineMode = PassthroughSubject<Bool, Never>()

    func isOfflineModeEnabled() -> Bool {
        true
    }

    func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        offlineMode
            .eraseToAnyPublisher()
    }

    func observeNetworkStatus() -> AnyPublisher<Core.NetworkAvailabilityStatus, Never> {
        Just(.disconnected)
            .eraseToAnyPublisher()
    }
}
