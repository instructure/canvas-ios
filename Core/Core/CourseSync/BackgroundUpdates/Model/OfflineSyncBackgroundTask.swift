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

public struct OfflineSyncBackgroundTask: BackgroundTask {
    public let request: BGTaskRequest
    private let sessions: Set<LoginSession>
    private let syncableAccounts: OfflineSyncAccounts

    public init(nextSyncDate: OfflineSyncNextDate,
                syncableAccounts: OfflineSyncAccounts,
                sessions: Set<LoginSession>) {
        let request = BGProcessingTaskRequest(identifier: "com.instructure.icanvas.offline-sync")
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = nextSyncDate.calculate(sessionUniqueIDs: sessions.map { $0.uniqueID })
        self.request = request
        self.sessions = sessions
        self.syncableAccounts = syncableAccounts
    }

    public func start(completion: @escaping () -> Void) {
        let sessionsToSync = syncableAccounts.calculate(Array(sessions),
                                                        date: Clock.now)
        let lastLoggedInUser = LoginSession.mostRecent

        sessionsToSync.forEach { session in
            AppEnvironment.shared.userDidLogin(session: session)
            Logger.shared.log("Offline sync triggered!")
        }

        if let lastLoggedInUser {
            AppEnvironment.shared.userDidLogin(session: lastLoggedInUser)
        }

        completion()
    }

    public func cancel() {
    }
}
