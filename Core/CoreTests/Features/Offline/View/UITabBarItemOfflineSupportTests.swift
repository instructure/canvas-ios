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

@testable import Core
import Combine
import CombineExt
import XCTest

class UITabBarItemOfflineSupportTests: XCTestCase {

    func testChangesEnabledStateBasedOnOfflineModeState() {
        let mockOfflineInteractor = OfflineModeInteractorMock()
        let testee = UITabBarItem(title: nil, image: nil, tag: 0)
        testee.makeUnavailableInOfflineMode(mockOfflineInteractor)

        // WHEN
        mockOfflineInteractor.mockedIsInOfflineMode.accept(true)

        // THEN
        XCTAssertFalse(testee.isEnabled)

        // WHEN
        mockOfflineInteractor.mockedIsInOfflineMode.accept(false)

        // THEN
        XCTAssertTrue(testee.isEnabled)
    }
}

private class OfflineModeInteractorMock: OfflineModeInteractor {
    let mockedIsInOfflineMode = CurrentValueRelay(false)

    func isFeatureFlagEnabled() -> Bool {
        true
    }

    func isOfflineModeEnabled() -> Bool {
        mockedIsInOfflineMode.value
    }

    func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        mockedIsInOfflineMode.eraseToAnyPublisher()
    }

    func observeNetworkStatus() -> AnyPublisher<NetworkAvailabilityStatus, Never> {
        Just(NetworkAvailabilityStatus.connected(.wifi)).eraseToAnyPublisher()
    }

    func isNetworkOffline() -> Bool {
        mockedIsInOfflineMode.value
    }
}
