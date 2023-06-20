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

    func testReadsSyncFrequencyLabel() {
        let interactor = makeInteractor()
        var testee: CourseSyncSettingsViewModel

        XCTAssertFinish(interactor.setSyncFrequency(.weekly))
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertEqual(testee.syncFrequencyLabel, "Weekly")

        XCTAssertFinish(interactor.setSyncFrequency(.daily))
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertEqual(testee.syncFrequencyLabel, "Daily")
    }

    // MARK: - Switch States

    func testForwardsSwitchStateChangesToInteractor() {
        let interactor = makeInteractor()
        let testee = CourseSyncSettingsViewModel(interactor: interactor)

        testee.isAutoContentSyncEnabled.accept(false)
        XCTAssertCompletableSingleOutputEquals(interactor.getStoredPreferences().map { $0.isAutoSyncEnabled }, false)
        testee.isAutoContentSyncEnabled.accept(true)
        XCTAssertCompletableSingleOutputEquals(interactor.getStoredPreferences().map { $0.isAutoSyncEnabled }, true)

        testee.isWifiOnlySyncEnabled.accept(false)
        XCTAssertCompletableSingleOutputEquals(interactor.getStoredPreferences().map { $0.isWifiOnlySyncEnabled }, false)
        testee.isWifiOnlySyncEnabled.accept(true)
        XCTAssertCompletableSingleOutputEquals(interactor.getStoredPreferences().map { $0.isWifiOnlySyncEnabled }, true)
    }

    func testReadsSwitchValuesFromInteractor() {
        let interactor = makeInteractor()
        var testee: CourseSyncSettingsViewModel!

        XCTAssertFinish(interactor.setAutoSyncEnabled(true))
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertTrue(testee.isAutoContentSyncEnabled.value)

        XCTAssertFinish(interactor.setAutoSyncEnabled(false))
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertFalse(testee.isAutoContentSyncEnabled.value)

        XCTAssertFinish(interactor.setWifiOnlySyncEnabled(true))
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertTrue(testee.isWifiOnlySyncEnabled.value)

        XCTAssertFinish(interactor.setWifiOnlySyncEnabled(false))
        testee = CourseSyncSettingsViewModel(interactor: interactor)
        XCTAssertFalse(testee.isWifiOnlySyncEnabled.value)
    }

    private func makeInteractor() -> CourseSyncSettingsInteractor {
        return CourseSyncSettingsInteractorLive(storage: .fallback)
    }
}
