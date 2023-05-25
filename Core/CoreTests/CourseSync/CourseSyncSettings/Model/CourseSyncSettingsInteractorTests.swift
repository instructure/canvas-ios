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
import XCTest

class CourseSyncSettingsInteractorTests: XCTestCase {
    private var defaults = SessionDefaults(sessionID: "test")

    override func tearDown() {
        defaults.reset()
        super.tearDown()
    }

    func testSyncFrequencyNames() {
        XCTAssertEqual(CourseSyncSettingsInteractor.SyncFrequency.weekly.stringValue, "Weekly")
        XCTAssertEqual(CourseSyncSettingsInteractor.SyncFrequency.daily.stringValue, "Daily")
    }

    func testDefaultValues() {
        let testee = CourseSyncSettingsInteractor(storage: defaults)
        XCTAssertFalse(testee.isAutoSyncEnabled.value)
        XCTAssertTrue(testee.isWifiOnlySyncEnabled.value)
        XCTAssertEqual(testee.syncFrequency.value, .daily)
    }

    func testPropertyChangesAreWrittenToStorage() {
        let testee = CourseSyncSettingsInteractor(storage: defaults)

        XCTAssertNil(defaults.isOfflineAutoSyncEnabled)
        testee.isAutoSyncEnabled.accept(true)
        XCTAssertEqual(defaults.isOfflineAutoSyncEnabled, true)

        XCTAssertNil(defaults.isOfflineWifiOnlySyncEnabled)
        testee.isWifiOnlySyncEnabled.accept(true)
        XCTAssertEqual(defaults.isOfflineWifiOnlySyncEnabled, true)

        XCTAssertNil(defaults.offlineSyncFrequency)
        testee.syncFrequency.accept(.weekly)
        XCTAssertEqual(defaults.offlineSyncFrequency, CourseSyncSettingsInteractor.SyncFrequency.weekly.rawValue)
    }

    func testReadsValuesFromStorage() {
        defaults.isOfflineAutoSyncEnabled = true
        defaults.isOfflineWifiOnlySyncEnabled = false
        defaults.offlineSyncFrequency = CourseSyncSettingsInteractor.SyncFrequency.weekly.rawValue

        let testee = CourseSyncSettingsInteractor(storage: defaults)
        XCTAssertTrue(testee.isAutoSyncEnabled.value)
        XCTAssertFalse(testee.isWifiOnlySyncEnabled.value)
        XCTAssertEqual(testee.syncFrequency.value, .weekly)
    }
}
