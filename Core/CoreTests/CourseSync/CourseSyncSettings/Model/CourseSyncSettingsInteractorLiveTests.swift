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

class CourseSyncSettingsInteractorLiveTests: XCTestCase {
    private var defaults = SessionDefaults.fallback

    override func setUp() {
        super.setUp()
        defaults.reset()
    }

    func testDefaultValuesOnEmptyStorage() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        XCTAssertCompletableSingleOutputEquals(testee.getStoredPreferences(), .init(isAutoSyncEnabled: false,
                                                                      isWifiOnlySyncEnabled: true,
                                                                      syncFrequency: .daily))
    }

    func testPropertyChangesAreWrittenToStorage() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)

        XCTAssertNil(defaults.isOfflineAutoSyncEnabled)
        XCTAssertFinish(testee.setAutoSyncEnabled(true))
        XCTAssertEqual(defaults.isOfflineAutoSyncEnabled, true)

        XCTAssertNil(defaults.isOfflineWifiOnlySyncEnabled)
        XCTAssertFinish(testee.setWifiOnlySyncEnabled(true))
        XCTAssertEqual(defaults.isOfflineWifiOnlySyncEnabled, true)

        XCTAssertNil(defaults.offlineSyncFrequency)
        XCTAssertFinish(testee.setSyncFrequency(.weekly))
        XCTAssertEqual(defaults.offlineSyncFrequency, CourseSyncFrequency.weekly.rawValue)
    }

    func testReadsValuesFromStorage() {
        defaults.isOfflineAutoSyncEnabled = true
        defaults.isOfflineWifiOnlySyncEnabled = false
        defaults.offlineSyncFrequency = CourseSyncFrequency.weekly.rawValue

        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        XCTAssertCompletableSingleOutputEquals(testee.getStoredPreferences(), .init(isAutoSyncEnabled: true,
                                                                         isWifiOnlySyncEnabled: false,
                                                                         syncFrequency: .weekly))
    }

    func testManualSyncLabel() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        XCTAssertFinish(testee.setAutoSyncEnabled(false))
        XCTAssertEqual(testee.getOfflineSyncSettingsLabel(), "Manual")
    }

    func testDailySyncLabel() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        XCTAssertFinish(testee.setAutoSyncEnabled(true))
        XCTAssertFinish(testee.setSyncFrequency(.daily))
        XCTAssertEqual(testee.getOfflineSyncSettingsLabel(), "Daily Auto")
    }

    func testWeeklySyncLabel() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        XCTAssertFinish(testee.setAutoSyncEnabled(true))
        XCTAssertFinish(testee.setSyncFrequency(.weekly))
        XCTAssertEqual(testee.getOfflineSyncSettingsLabel(), "Weekly Auto")
    }
}
