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

public class OfflineSyncScheduleInteractor {

    public init() {
    }

    public func scheduleNextSync() {
        guard let offlineSyncTask = CourseSyncBackgroundUpdatesAssembly.makeTaskRequest() else {
            Logger.shared.log("Offline: Skipping background sync schedule: no accounts to sync.")
            return
        }

        BackgroundProcessingAssembly
            .resolveInteractor()
            .schedule(task: offlineSyncTask)
        Logger.shared.log("Offline: Scheduled background offline sync.")
    }

    public func updateNextSyncDate(sessionUniqueID: String) {
        var defaults = SessionDefaults(sessionID: sessionUniqueID)
        guard let syncFrequency = defaults.offlineSyncFrequency else {
            return
        }

        defaults.offlineSyncNextDate = syncFrequency.nextSyncDate(from: Clock.now)
    }
}
