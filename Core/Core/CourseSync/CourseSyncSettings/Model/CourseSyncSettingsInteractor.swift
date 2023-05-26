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

    public init(storage: SessionDefaults) {
        self.storage = storage
    }

    public func getOfflineSyncSettingsLabel() -> String {
        let settings = storedSettings

        guard settings.isAutoSyncEnabled else {
            return NSLocalizedString("Manual", comment: "")
        }

        let format = NSLocalizedString("%@ Auto",
                                       comment: "Weekly Auto / Daily Auto Synchronization Frequency")
        return String.localizedStringWithFormat(format, settings.syncFrequency.stringValue)
    }

    public func getStoredPreferences() -> AnyPublisher<CourseSyncSettings, Never> {
        Just(storedSettings).eraseToAnyPublisher()
    }

    public func setAutoSyncEnabled(_ isEnabled: Bool) -> AnyPublisher<Bool, Never> {
        Future { [unowned self] promise in
            storage.isOfflineAutoSyncEnabled = isEnabled
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
            storage.offlineSyncFrequency = syncFrequency.rawValue
            promise(.success(syncFrequency))
        }
        .eraseToAnyPublisher()
    }

    private var storedSettings: CourseSyncSettings {
        let syncFrequency: CourseSyncFrequency? = {
            guard let storedSyncFrequencyRaw = storage.offlineSyncFrequency,
                  let storedSyncFrequency = CourseSyncFrequency(rawValue: storedSyncFrequencyRaw)
            else {
                return nil
            }

            return storedSyncFrequency
        }()
        return CourseSyncSettings(isAutoSyncEnabled: storage.isOfflineAutoSyncEnabled ?? false,
                                  isWifiOnlySyncEnabled: storage.isOfflineWifiOnlySyncEnabled ?? true,
                                  syncFrequency: syncFrequency ?? .daily)
    }
}
