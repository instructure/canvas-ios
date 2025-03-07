//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Combine
import Core
@testable import Parent
import XCTest

class ProfileSettingsViewModelTests: ParentTestCase {
    private let inboxSettingsInteractor = InboxSettingsInteractorMock()
    private let offlineInteractor = OfflineInteractorMock()
    private let options = [
        ItemPickerItem(title: String(localized: "System Settings", bundle: .core)),
        ItemPickerItem(title: String(localized: "Light Theme", bundle: .core)),
        ItemPickerItem(title: String(localized: "Dark Theme", bundle: .core))
    ]

    private var testee: ProfileSettingsViewModel!

    override func setUp() {
        super.setUp()

        testee = ProfileSettingsViewModel(
            inboxSettingsInteractor: inboxSettingsInteractor,
            offlineInteractor: offlineInteractor,
            environment: env
        )
    }

    func testAllGroupsAreDisplayed() {
        XCTAssertEqual(testee.settingsGroups.count, 3)
        XCTAssertEqual(testee.settingsGroups[0].viewModel.title, "Preferences")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.title, "Inbox")
        XCTAssertEqual(testee.settingsGroups[2].viewModel.title, "Legal")
    }

    func testAllGroupItemsAreDisplayed() {
        XCTAssertEqual(testee.settingsGroups[0].viewModel.itemViews.count, 2)
        XCTAssertEqual(testee.settingsGroups[0].viewModel.itemViews[0].viewModel.title, "Appearance")
        let expectedAppearanceValue = options[env.userDefaults?.interfaceStyle?.rawValue ?? 0].title
        XCTAssertEqual(testee.settingsGroups[0].viewModel.itemViews[0].viewModel.valueLabel, expectedAppearanceValue)
        XCTAssertEqual(testee.settingsGroups[0].viewModel.itemViews[1].viewModel.title, "About")
        XCTAssertEqual(testee.settingsGroups[0].viewModel.itemViews[1].viewModel.valueLabel, nil)

        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews.count, 1)
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.title, "Inbox Signature")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.valueLabel, "Enabled")

        XCTAssertEqual(testee.settingsGroups[2].viewModel.itemViews.count, 3)
        XCTAssertEqual(testee.settingsGroups[2].viewModel.itemViews[0].viewModel.title, "Privacy Policy")
        XCTAssertEqual(testee.settingsGroups[2].viewModel.itemViews[0].viewModel.valueLabel, nil)
        XCTAssertEqual(testee.settingsGroups[2].viewModel.itemViews[1].viewModel.title, "Terms of Use")
        XCTAssertEqual(testee.settingsGroups[2].viewModel.itemViews[1].viewModel.valueLabel, nil)
        XCTAssertEqual(testee.settingsGroups[2].viewModel.itemViews[2].viewModel.title, "Canvas on Github")
        XCTAssertEqual(testee.settingsGroups[2].viewModel.itemViews[2].viewModel.valueLabel, nil)
    }

    func testInboxStates() {
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews.count, 1)
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.title, "Inbox Signature")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.valueLabel, "Enabled")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.isHidden, false)

        inboxSettingsInteractor.modifySignature(useSignature: false, signature: "")

        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.title, "Inbox Signature")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.valueLabel, "Not set")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.isHidden, false)

        inboxSettingsInteractor.modifyIsFeatureEnabled(isEnabled: false)

        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.title, "Inbox Signature")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.valueLabel, "Not set")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.isHidden, true)
    }

    func testDisabledInbox() {
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews.count, 1)
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.title, "Inbox Signature")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.valueLabel, "Enabled")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.disabled, false)

        offlineInteractor.updateIsOfflineMode(isOffline: true)

        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.title, "Inbox Signature")
        XCTAssertEqual(testee.settingsGroups[1].viewModel.itemViews[0].viewModel.disabled, true)
    }
}

private class InboxSettingsInteractorMock: InboxSettingsInteractor {
    var state = CurrentValueSubject<Core.StoreState, Never>(.data)

    var signature = CurrentValueSubject<(useSignature: Bool, String?), Never>((true, "Signature"))

    var settings = CurrentValueSubject<Core.CDInboxSettings?, Never>(nil)

    var environmentSettings = CurrentValueSubject<Core.CDEnvironmentSettings?, Never>(nil)

    var isFeatureEnabled = CurrentValueSubject<Bool, Never>(true)

    func updateInboxSettings(inboxSettings: Core.CDInboxSettings) -> AnyPublisher<Void, any Error> {
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func modifySignature(useSignature: Bool, signature: String) {
        self.signature.send((useSignature: useSignature, signature))
    }

    func modifyIsFeatureEnabled(isEnabled: Bool) {
        self.isFeatureEnabled.send(isEnabled)
    }
}

private class OfflineInteractorMock: OfflineModeInteractor {
    private let isOfflineMode = CurrentValueSubject<Bool, Never>(false)

    func isFeatureFlagEnabled() -> Bool {
        return false
    }

    func isOfflineModeEnabled() -> Bool {
        return false
    }

    func isNetworkOffline() -> Bool {
        return false
    }

    func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        return Just(false).eraseToAnyPublisher()
    }

    func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        return isOfflineMode.eraseToAnyPublisher()
    }

    func observeNetworkStatus() -> AnyPublisher<Core.NetworkAvailabilityStatus, Never> {
        return Just(NetworkAvailabilityStatus.connected(.wifi)).eraseToAnyPublisher()
    }

    func updateIsOfflineMode(isOffline: Bool) {
        self.isOfflineMode.send(isOffline)
    }
}
