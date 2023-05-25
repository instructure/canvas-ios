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

class CourseSyncSettingsViewModelTests: XCTestCase {

    func testPresentsSyncFrequencyPicker() {
        let testee = CourseSyncSettingsViewModel(interactor: makeInteractor())
        let presenter = UIViewController()
        let navigation = UINavigationController(rootViewController: presenter)

        testee.syncFrequencyDidTap.accept(WeakViewController(presenter))

        drainMainQueue()
        XCTAssertEqual(navigation.children.count, 2)
        XCTAssertTrue(navigation.children.last is ItemPickerViewController)
    }

    func testTogglesAllSettingsVisibility() {
        let testee = CourseSyncSettingsViewModel(interactor: makeInteractor())

        testee.isAutoContentSyncEnabled.accept(true)
        XCTAssertTrue(testee.isAllSettingsVisible)

        testee.isAutoContentSyncEnabled.accept(false)
        XCTAssertFalse(testee.isAllSettingsVisible)
    }

    func testAlertWhenWifiSyncTurnedOff() {
        let testee = CourseSyncSettingsViewModel(interactor: makeInteractor())
        XCTAssertFalse(testee.isShowingConfirmationDialog)

        testee.isWifiOnlySyncEnabled.accept(false)
        XCTAssertTrue(testee.isShowingConfirmationDialog)
    }

    func testUpdatesSyncFrequencyLabel() {
        let interactor = makeInteractor()
        let testee = CourseSyncSettingsViewModel(interactor: interactor)

        interactor.syncFrequency.accept(.weekly)
        XCTAssertEqual(testee.syncFrequencyLabel, "Weekly")

        interactor.syncFrequency.accept(.daily)
        XCTAssertEqual(testee.syncFrequencyLabel, "Daily")
    }

    func testForwardsSwitchStateChangesToInteractor() {
        let interactor = makeInteractor()
        let testee = CourseSyncSettingsViewModel(interactor: interactor)

        testee.isAutoContentSyncEnabled.accept(false)
        XCTAssertFalse(interactor.isAutoSyncEnabled.value)
        testee.isAutoContentSyncEnabled.accept(true)
        XCTAssertTrue(interactor.isAutoSyncEnabled.value)

        testee.isWifiOnlySyncEnabled.accept(false)
        XCTAssertFalse(interactor.isWifiOnlySyncEnabled.value)
        testee.isWifiOnlySyncEnabled.accept(true)
        XCTAssertTrue(interactor.isWifiOnlySyncEnabled.value)
    }

    func testReadsSwitchValuesFromInteractor() {
        let interactor = makeInteractor()
        var testee: CourseSyncSettingsViewModel!

        interactor.isAutoSyncEnabled.accept(true)
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertTrue(testee.isAutoContentSyncEnabled.value)

        interactor.isAutoSyncEnabled.accept(false)
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertFalse(testee.isAutoContentSyncEnabled.value)

        interactor.isWifiOnlySyncEnabled.accept(true)
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertTrue(testee.isWifiOnlySyncEnabled.value)

        interactor.isWifiOnlySyncEnabled.accept(false)
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertFalse(testee.isWifiOnlySyncEnabled.value)
    }

    private func makeInteractor() -> CourseSyncSettingsInteractor {
        let session = SessionDefaults(sessionID: "test")
        return CourseSyncSettingsInteractor(storage: session)
    }
}
