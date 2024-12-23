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

import Foundation

/**
 This helper returns all accounts that needs offline sync at a given time.
 We use this to determine which accounts need offline sync when the app wakes up in the background.
 */
public class OfflineSyncAccountsInteractor {

    public func calculate(_ sessions: [LoginSession], date: Date) -> [LoginSession] {
        Logger.shared.log("Offline: Checking which accounts to sync")
        return sessions.reduce(into: []) { partialResult, session in
            let defaults = SessionDefaults(sessionID: session.uniqueID)
            guard defaults.isOfflineAutoSyncEnabled == true,
                  let syncDate = defaults.offlineSyncNextDate,
                  syncDate <= date
            else {
                let reason = {
                    if defaults.isOfflineAutoSyncEnabled == false {
                        return "Auto sync disabled"
                    } else if defaults.offlineSyncNextDate == nil {
                        return "No sync date set"
                    } else {
                        return "Sync date is in the future"
                    }
                }()
                Logger.shared.log("Offline: Skipping account \(session.uniqueID): \(reason)")
                return
            }
            Logger.shared.log("Offline: Adding account to sync \(session.uniqueID)")
            partialResult.append(session)
        }
    }
}
