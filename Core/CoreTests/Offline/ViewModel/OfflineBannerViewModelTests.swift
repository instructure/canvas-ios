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
import CombineSchedulers
import XCTest

class OfflineBannerViewModelTests: XCTestCase {

    public func testBannerBecomesVisibleWhenAppGoesOffline() {
        // GIVEN
        let mockInteractor = MockOfflineModeInteractor()
        let hostingView = UIViewController()
        let scheduler = DispatchQueue.test.eraseToAnyScheduler()
        let testee = OfflineBannerViewModel(interactor: mockInteractor,
                                            parent: hostingView,
                                            scheduler: scheduler)
        XCTAssertFalse(testee.isOffline)
        XCTAssertFalse(testee.isVisible)

        // WHEN
        mockInteractor.offlineMode.accept(true)

        // THEN
        XCTAssertTrue(testee.isOffline)
        XCTAssertTrue(testee.isVisible)
        XCTAssertNotEqual(hostingView.additionalSafeAreaInsets.bottom, 0)
    }

    public func testBannerStaysVisibleAndShowsBackOnlineStateWhenAppGoesOnline() {
        // GIVEN
        let mockInteractor = MockOfflineModeInteractor()
        let hostingView = UIViewController()
        let scheduler = DispatchQueue.test
        let testee = OfflineBannerViewModel(interactor: mockInteractor,
                                            parent: hostingView,
                                            scheduler: scheduler.eraseToAnyScheduler())
        mockInteractor.offlineMode.accept(true)

        // WHEN
        mockInteractor.offlineMode.accept(false)

        // THEN
        XCTAssertFalse(testee.isOffline)
        XCTAssertTrue(testee.isVisible)
        scheduler.advance(by: .seconds(2.9))
        XCTAssertTrue(testee.isVisible)
        scheduler.advance(by: .seconds(0.1))
        XCTAssertFalse(testee.isVisible)
        XCTAssertEqual(hostingView.additionalSafeAreaInsets.bottom, 0)
    }

    public func testBannerNotGettingHiddenWhenOfflineModeTriggeredWhileShowingBackOnlineState() {
        // GIVEN
        let mockInteractor = MockOfflineModeInteractor()
        let hostingView = UIViewController()
        let scheduler = DispatchQueue.test
        let testee = OfflineBannerViewModel(interactor: mockInteractor,
                                            parent: hostingView,
                                            scheduler: scheduler.eraseToAnyScheduler())
        mockInteractor.offlineMode.accept(true)
        mockInteractor.offlineMode.accept(false)

        // WHEN
        scheduler.advance(by: .seconds(1))
        mockInteractor.offlineMode.accept(true)
        scheduler.advance(by: .seconds(2))

        // THEN
        XCTAssertTrue(testee.isOffline)
        XCTAssertTrue(testee.isVisible)
    }
}

private class MockOfflineModeInteractor: OfflineModeInteractor {
    let offlineMode = CurrentValueRelay<Bool>(false)

    func isFeatureFlagEnabled() -> Bool {
        true
    }

    func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func isOfflineModeEnabled() -> Bool {
        offlineMode.value
    }

    func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        offlineMode
            .eraseToAnyPublisher()
    }

    func observeNetworkStatus() -> AnyPublisher<Core.NetworkAvailabilityStatus, Never> {
        offlineMode
            .map { $0 ? NetworkAvailabilityStatus.disconnected : .connected(.wifi)}
            .eraseToAnyPublisher()
    }
}
