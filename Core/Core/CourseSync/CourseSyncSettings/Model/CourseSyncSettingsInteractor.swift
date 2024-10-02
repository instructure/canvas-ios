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

import Combine
import CombineExt

protocol CourseSyncSettingsInteractor {
    func getOfflineSyncSettingsLabel() -> String
    func getStoredPreferences() -> AnyPublisher<CourseSyncSettings, Never>

    func setAutoSyncEnabled(_ isEnabled: Bool) -> AnyPublisher<Bool, Never>
    func setWifiOnlySyncEnabled(_ isEnabled: Bool) -> AnyPublisher<Bool, Never>
    func setSyncFrequency(_ syncFrequency: CourseSyncFrequency) -> AnyPublisher<CourseSyncFrequency, Never>
}

class CourseSyncSettingsInteractorLive: CourseSyncSettingsInteractor {
    private var storage: SessionDefaults
    private let analytics: Analytics

    public init(
        storage: SessionDefaults,
        analytics: Analytics = .shared
    ) {
        self.storage = storage
        self.analytics = analytics
    }

    public func getOfflineSyncSettingsLabel() -> String {
        let settings = storedSettings

        guard settings.isAutoSyncEnabled else {
            return String(localized: "Manual", bundle: .core)
        }

        let format = String(localized: "%@ Auto", bundle: .core, comment: "Weekly Auto / Daily Auto Synchronization Frequency")
        return String.localizedStringWithFormat(format, settings.syncFrequency.stringValue)
    }

    public func getStoredPreferences() -> AnyPublisher<CourseSyncSettings, Never> {
        Just(storedSettings).eraseToAnyPublisher()
    }

    public func setAutoSyncEnabled(_ isEnabled: Bool) -> AnyPublisher<Bool, Never> {
        Future { [unowned self] promise in
            storage.isOfflineAutoSyncEnabled = isEnabled

            let nextSync = isEnabled ? storedSettings.syncFrequency.nextSyncDate(from: Clock.now)
                                     : nil
            storage.offlineSyncNextDate = nextSync

            analytics.logEvent(isEnabled ? "offline_auto_sync_turned_on" : "offline_auto_sync_turned_off")
            promise(.success(isEnabled))
        }
        .eraseToAnyPublisher()
    }

    public func setWifiOnlySyncEnabled(_ isEnabled: Bool) -> AnyPublisher<Bool, Never> {
        Future { [unowned self] promise in
            storage.isOfflineWifiOnlySyncEnabled = isEnabled
            promise(.success(isEnabled))
        }
        .eraseToAnyPublisher()
    }

    public func setSyncFrequency(_ syncFrequency: CourseSyncFrequency) -> AnyPublisher<CourseSyncFrequency, Never> {
        Future { [unowned self] promise in
            storage.offlineSyncFrequency = syncFrequency

            if storedSettings.isAutoSyncEnabled {
                storage.offlineSyncNextDate = storedSettings.syncFrequency.nextSyncDate(from: Clock.now)
            }

            promise(.success(syncFrequency))
        }
        .eraseToAnyPublisher()
    }

    private var storedSettings: CourseSyncSettings {
        let syncFrequency = storage.offlineSyncFrequency
        return CourseSyncSettings(isAutoSyncEnabled: storage.isOfflineAutoSyncEnabled ?? false,
                                  isWifiOnlySyncEnabled: storage.isOfflineWifiOnlySyncEnabled ?? true,
                                  syncFrequency: syncFrequency ?? .daily)
    }
}
