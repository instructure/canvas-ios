//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Horizon
import XCTest

final class OfflineSyncSettingsViewModelTests: HorizonTestCase {

    private var testee: OfflineSyncSettingsViewModel!
    private var storage: SessionDefaults!

    override func setUp() {
        super.setUp()
        storage = SessionDefaults(sessionID: environment.currentSession!.uniqueID)
    }

    override func tearDown() {
        testee = nil
        storage.reset()
        storage = nil
        Clock.reset()
        super.tearDown()
    }

    // MARK: - wifiOnlySyncToggled

    func test_wifiOnlySyncToggled_whenToggledOff_shouldShowConfirmationWithPendingFalse() {
        testee = makeViewModel()

        testee.wifiOnlySyncToggled(newValue: false)

        XCTAssertEqual(testee.isShowingWifiConfirmation, true)
        XCTAssertEqual(testee.pendingWifiSyncValue, false)
        XCTAssertEqual(testee.isWifiOnlySyncEnabled, true)
    }

    func test_wifiOnlySyncToggled_whenToggledOn_shouldShowConfirmationWithPendingTrue() {
        storage.isOfflineWifiOnlySyncEnabled = false
        testee = makeViewModel()

        testee.wifiOnlySyncToggled(newValue: true)

        XCTAssertEqual(testee.isShowingWifiConfirmation, true)
        XCTAssertEqual(testee.pendingWifiSyncValue, true)
        XCTAssertEqual(testee.isWifiOnlySyncEnabled, false)
    }

    // MARK: - confirmWifiSyncChange

    func test_confirmWifiSyncChange_whenPendingFalse_shouldDisableWifiSyncAndUpdateStorage() {
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: false)

        testee.confirmWifiSyncChange()

        XCTAssertEqual(testee.isWifiOnlySyncEnabled, false)
        XCTAssertEqual(storage.isOfflineWifiOnlySyncEnabled, false)
    }

    func test_confirmWifiSyncChange_whenPendingTrue_shouldEnableWifiSyncAndUpdateStorage() {
        storage.isOfflineWifiOnlySyncEnabled = false
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: true)

        testee.confirmWifiSyncChange()

        XCTAssertEqual(testee.isWifiOnlySyncEnabled, true)
        XCTAssertEqual(storage.isOfflineWifiOnlySyncEnabled, true)
    }
    // MARK: - wifiConfirmationTitle

    func test_wifiConfirmationTitle_whenPendingTrue_shouldReturnTurnOnTitle() {
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: true)

        XCTAssertEqual(testee.wifiConfirmationTitle, "Turn On Wi-Fi Only Sync?")
    }

    func test_wifiConfirmationTitle_whenPendingFalse_shouldReturnTurnOffTitle() {
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: false)

        XCTAssertEqual(testee.wifiConfirmationTitle, "Turn Off Wi-Fi Only Sync?")
    }

    // MARK: - wifiConfirmationMessage

    func test_wifiConfirmationMessage_whenPendingTrue_shouldReturnWifiOnlyMessage() {
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: true)

        XCTAssertEqual(testee.wifiConfirmationMessage, "Content will only synchronize when connected to a Wi-Fi network.")
    }

    func test_wifiConfirmationMessage_whenPendingFalse_shouldReturnCellularDataMessage() {
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: false)

        XCTAssertEqual(testee.wifiConfirmationMessage, "Content sync might use cellular data which may result in extra fees from your data provider.")
    }

    // MARK: - wifiConfirmationButtonTitle

    func test_wifiConfirmationButtonTitle_whenPendingTrue_shouldReturnTurnOn() {
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: true)

        XCTAssertEqual(testee.wifiConfirmationButtonTitle, "Turn On")
    }

    func test_wifiConfirmationButtonTitle_whenPendingFalse_shouldReturnTurnOff() {
        testee = makeViewModel()
        testee.wifiOnlySyncToggled(newValue: false)

        XCTAssertEqual(testee.wifiConfirmationButtonTitle, "Turn Off")
    }

    // MARK: - saveAutoSync

    func test_saveAutoSync_whenEnabled_shouldPersistEnabledAndScheduleNextDate() {
        let now = Date.make(year: 2026, month: 4, day: 6)
        Clock.mockNow(now)
        testee = makeViewModel()

        testee.isAutoSyncEnabled = true

        XCTAssertEqual(storage.isOfflineAutoSyncEnabled, true)
        XCTAssertEqual(storage.offlineSyncNextDate, testee.syncFrequency.nextSyncDate(from: now))
    }

    func test_saveAutoSync_whenDisabled_shouldPersistDisabledAndClearNextDate() {
        storage.offlineSyncNextDate = Date.make(year: 2026, month: 4, day: 7)
        testee = makeViewModel()

        testee.isAutoSyncEnabled = false

        XCTAssertEqual(storage.isOfflineAutoSyncEnabled, false)
        XCTAssertEqual(storage.offlineSyncNextDate, nil)
    }

    // MARK: - saveFrequency

    func test_saveFrequency_shouldPersistNewFrequency() {
        testee = makeViewModel()

        testee.syncFrequency = .weekly

        XCTAssertEqual(storage.offlineSyncFrequency, .weekly)
    }

    func test_saveFrequency_whenAutoSyncEnabled_shouldUpdateNextSyncDate() {
        let now = Date.make(year: 2026, month: 4, day: 6)
        Clock.mockNow(now)
        storage.isOfflineAutoSyncEnabled = true
        testee = makeViewModel()

        testee.syncFrequency = .weekly

        XCTAssertEqual(storage.offlineSyncNextDate, CourseSyncFrequency.weekly.nextSyncDate(from: now))
    }

    func test_saveFrequency_whenAutoSyncDisabled_shouldNotUpdateNextSyncDate() {
        let existingDate = Date.make(year: 2026, month: 4, day: 7)
        storage.isOfflineAutoSyncEnabled = false
        storage.offlineSyncNextDate = existingDate
        testee = makeViewModel()

        testee.syncFrequency = .weekly

        XCTAssertEqual(storage.offlineSyncNextDate, existingDate)
    }

    // MARK: - Private helpers

    private func makeViewModel() -> OfflineSyncSettingsViewModel {
        OfflineSyncSettingsViewModel(
            router: router,
            sessionID: environment.currentSession!.uniqueID
        )
    }
}
