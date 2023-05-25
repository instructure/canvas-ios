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

class CourseSyncSettingsInteractor {
    public let isAutoSyncEnabled = CurrentValueRelay<Bool>(false)
    public let isWifiOnlySyncEnabled = CurrentValueRelay<Bool>(true)
    public let syncFrequency = CurrentValueRelay<CourseSyncFrequency>(.daily)

    private var storage: SessionDefaults
    private var subscriptions = Set<AnyCancellable>()

    init(storage: SessionDefaults) {
        self.storage = storage
        readValuesFromStorage()
        writePropertiesToStorageOnChange()
    }

    private func readValuesFromStorage() {
        if let storedAutoSync = storage.isOfflineAutoSyncEnabled {
            isAutoSyncEnabled.accept(storedAutoSync)
        }

        if let storedWifiSync = storage.isOfflineWifiOnlySyncEnabled {
            isWifiOnlySyncEnabled.accept(storedWifiSync)
        }

        if let storedSyncFrequencyRaw = storage.offlineSyncFrequency,
           let storedSyncFrequency = CourseSyncFrequency(rawValue: storedSyncFrequencyRaw) {
            syncFrequency.accept(storedSyncFrequency)
        }
    }

    private func writePropertiesToStorageOnChange() {
        unowned let unownedSelf = self

        isAutoSyncEnabled
            .dropFirst()
            .sink { newValue in
                unownedSelf.storage.isOfflineAutoSyncEnabled = newValue
            }
            .store(in: &subscriptions)

        isWifiOnlySyncEnabled
            .dropFirst()
            .sink { newValue in
                unownedSelf.storage.isOfflineWifiOnlySyncEnabled = newValue
            }
            .store(in: &subscriptions)

        syncFrequency
            .dropFirst()
            .map { $0.rawValue }
            .sink { newValue in
                unownedSelf.storage.offlineSyncFrequency = newValue
            }
            .store(in: &subscriptions)
    }
}
