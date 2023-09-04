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

import BackgroundTasks

public class OfflineSyncBackgroundTaskRequest: BGProcessingTaskRequest {
    public static let ID = "com.instructure.icanvas.offline-sync"

    // TODO: Return nil if there's no `earliestBeginDate`, there's no point of scheduling background work without syncable accounts
    public init(nextSyncDate: OfflineSyncNextDate, sessions: Set<LoginSession>) {
        super.init(identifier: Self.ID)
        requiresExternalPower = false
        requiresNetworkConnectivity = true
        earliestBeginDate = nextSyncDate.calculate(sessionUniqueIDs: sessions.map { $0.uniqueID })
    }
}
