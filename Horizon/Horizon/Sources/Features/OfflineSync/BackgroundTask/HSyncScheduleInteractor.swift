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

public struct HSyncScheduleInteractor {

    public init() {}

    public func scheduleNextSync() {
        guard let task = HBackgroundUpdatesAssembly.makeTaskRequest() else {
            Logger.shared.log("Horizon: Skipping background sync schedule: no sessions to sync.")
            return
        }
        BackgroundProcessingAssembly.resolveInteractor().schedule(task: task)
        Logger.shared.log("Horizon: Scheduled background course sync.")
    }

    public func updateNextSyncDate(sessionUniqueID: String) {
        var defaults = SessionDefaults(sessionID: sessionUniqueID)
        let frequency = defaults.horizonSyncFrequency ?? .daily
        defaults.horizonSyncNextDate = frequency.nextSyncDate(from: Clock.now)
    }
}
