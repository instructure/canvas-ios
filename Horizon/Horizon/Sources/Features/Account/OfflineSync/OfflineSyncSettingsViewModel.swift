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

import Core
import Observation

@Observable
final class OfflineSyncSettingsViewModel {

    // MARK: - Inputs / Outputs

    var isAutoSyncEnabled: Bool {
        didSet { saveAutoSync() }
    }

    var syncFrequency: CourseSyncFrequency {
        didSet { saveFrequency() }
    }

    var isWifiOnlySyncEnabled: Bool = true
    var isShowingWifiConfirmation = false
    private(set) var pendingWifiSyncValue: Bool = true

    // MARK: - Dependencies

    private var storage: SessionDefaults
    private let router: Router

    // MARK: - Init

    init(router: Router, sessionID: String) {
        self.router = router
        let defaults = SessionDefaults(sessionID: sessionID)
        self.storage = defaults
        self.syncFrequency = defaults.offlineSyncFrequency ?? .daily
        self.isAutoSyncEnabled = defaults.isOfflineAutoSyncEnabled == true
        self.isWifiOnlySyncEnabled = defaults.isOfflineWifiOnlySyncEnabled ?? true
    }

    // MARK: - Navigation

    func navigateBack(viewController: WeakViewController) {
        router.pop(from: viewController)
    }

    // MARK: - Computed alert strings

    var wifiConfirmationTitle: String {
        pendingWifiSyncValue
            ? String(localized: "Turn On Wi-Fi Only Sync?", bundle: .horizon)
            : String(localized: "Turn Off Wi-Fi Only Sync?", bundle: .horizon)
    }

    var wifiConfirmationMessage: String {
        pendingWifiSyncValue
            ? String(localized: "Content will only synchronize when connected to a Wi-Fi network.", bundle: .horizon)
            : String(localized: "Content sync might use cellular data which may result in extra fees from your data provider.", bundle: .horizon)
    }

    var wifiConfirmationButtonTitle: String {
        pendingWifiSyncValue
            ? String(localized: "Turn On", bundle: .horizon)
            : String(localized: "Turn Off", bundle: .horizon)
    }

    // MARK: - Actions

    func wifiOnlySyncToggled(newValue: Bool) {
        pendingWifiSyncValue = newValue
        isShowingWifiConfirmation = true
    }

    func confirmWifiSyncChange() {
        isWifiOnlySyncEnabled = pendingWifiSyncValue
        storage.isOfflineWifiOnlySyncEnabled = pendingWifiSyncValue
    }

    func navigateToManageOffline(viewController: WeakViewController) {
        router.show(ManageOfflineAssembly.makeView(), from: viewController)
    }

    // MARK: - Private

    private func saveAutoSync() {
        storage.isOfflineAutoSyncEnabled = isAutoSyncEnabled
        if isAutoSyncEnabled {
            storage.offlineSyncNextDate = syncFrequency.nextSyncDate(from: Clock.now)
        } else {
            storage.offlineSyncNextDate = nil
        }
    }

    private func saveFrequency() {
        storage.offlineSyncFrequency = syncFrequency
        if isAutoSyncEnabled {
            storage.offlineSyncNextDate = syncFrequency.nextSyncDate(from: Clock.now)
        }
    }
}
