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
        XCTAssertEqual(defaults.offlineSyncFrequency, .weekly)
    }

    func testReadsValuesFromStorage() {
        defaults.isOfflineAutoSyncEnabled = true
        defaults.isOfflineWifiOnlySyncEnabled = false
        defaults.offlineSyncFrequency = .weekly

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

    func testSetsNextSyncDateWhenSyncTurnedOn() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        let now = Date()
        Clock.mockNow(now)
        XCTAssertNil(defaults.offlineSyncNextDate)

        // WHEN
        XCTAssertFinish(testee.setAutoSyncEnabled(true))

        // THEN
        let expectedNextSyncDate = now.addingTimeInterval(24 * 60 * 60) // daily sync is the default
        XCTAssertEqual(defaults.offlineSyncNextDate, expectedNextSyncDate)

        Clock.reset()
    }

    func testRemovesNextSyncDateWhenSyncTurnedOff() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        XCTAssertFinish(testee.setAutoSyncEnabled(true))
        XCTAssertNotNil(defaults.offlineSyncNextDate)

        // WHEN
        XCTAssertFinish(testee.setAutoSyncEnabled(false))

        // THEN
        XCTAssertNil(defaults.offlineSyncNextDate)
    }

    func testUpdatesNextSyncDateWhenFrequencyChangedIfSyncTurnedOn() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        Clock.mockNow(Date())
        let tomorrow = Clock.now.addingTimeInterval(24 * 60 * 60)
        let nextWeek = Clock.now.addingTimeInterval(7 * 24 * 60 * 60)
        XCTAssertFinish(testee.setAutoSyncEnabled(true))

        // WHEN
        XCTAssertFinish(testee.setSyncFrequency(.weekly))

        // THEN
        XCTAssertEqual(defaults.offlineSyncNextDate, nextWeek)

        // WHEN
        XCTAssertFinish(testee.setSyncFrequency(.daily))

        // THEN
        XCTAssertEqual(defaults.offlineSyncNextDate, tomorrow)

        Clock.reset()
    }

    func testNotUpdatesNextSyncDateWhenFrequencyChangedIfSyncTurnedOff() {
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)
        XCTAssertFinish(testee.setAutoSyncEnabled(false))

        // WHEN
        XCTAssertFinish(testee.setSyncFrequency(.weekly))

        // THEN
        XCTAssertNil(defaults.offlineSyncNextDate)

        // WHEN
        XCTAssertFinish(testee.setSyncFrequency(.daily))

        // THEN
        XCTAssertNil(defaults.offlineSyncNextDate)
    }

    func testLogsAutoSyncAutoSyncToggle() {
        let mockAnalytics = MockAnalyticsHandler()
        Analytics.shared.handler = mockAnalytics
        let testee = CourseSyncSettingsInteractorLive(storage: defaults)

        // WHEN
        XCTAssertFinish(testee.setAutoSyncEnabled(true))

        // THEN
        XCTAssertEqual(mockAnalytics.lastEvent, "offline_auto_sync_turned_on")
        XCTAssertEqual(mockAnalytics.totalEventCount, 1)

        // WHEN
        XCTAssertFinish(testee.setAutoSyncEnabled(false))

        // THEN
        XCTAssertEqual(mockAnalytics.lastEvent, "offline_auto_sync_turned_off")
        XCTAssertEqual(mockAnalytics.totalEventCount, 2)
    }
}
