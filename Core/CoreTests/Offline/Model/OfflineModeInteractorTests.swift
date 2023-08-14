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
import TestsFoundation
import XCTest

class OfflineModeInteractorLiveTests: CoreTestCase {

    func testObservesOfflineModeFlagInCoreData() throws {
        let testee = OfflineModeInteractorLive(context: databaseClient)
        let flag = injectFeatureFlagObject()

        flag.enabled = true
        waitUntil(1, shouldFail: true) {
            testee.isFeatureFlagEnabled() == true
        }

        flag.enabled = false
        waitUntil(1, shouldFail: true) {
            testee.isFeatureFlagEnabled() == false
        }
    }

    func testPublishesOfflineModeFlagChangesFromCoreData() {
        let flag = injectFeatureFlagObject()
        let testee = OfflineModeInteractorLive(context: databaseClient)
        let expectation = expectation(description: "Received flag events")
        let subscription = testee
            .observeIsFeatureFlagEnabled()
            .collect(3)
            .sink {
                XCTAssertEqual($0, [
                    false, // initial value from DB
                    true, // flag to true
                    false, // flag to false
                ])
                expectation.fulfill()
            }

        flag.enabled = true
        waitUntil { testee.isFeatureFlagEnabled() }
        flag.enabled = false
        waitUntil { !testee.isFeatureFlagEnabled() }

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }

    private func injectFeatureFlagObject() -> FeatureFlag {
        let flag: FeatureFlag = databaseClient.insert()
        flag.name = EnvironmentFeatureFlags.mobile_offline_mode.rawValue
        flag.isEnvironmentFlag = true
        flag.enabled = false
        flag.context = .currentUser
        return flag
    }
}
