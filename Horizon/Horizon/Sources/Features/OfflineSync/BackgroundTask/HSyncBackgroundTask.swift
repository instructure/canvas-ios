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

public final class HSyncBackgroundTask: BackgroundTask {
    private let sessions: [LoginSession]
    private let lastLoggedInSession: LoginSession?
    private let scheduleInteractor: any HSyncScheduleInteractor
    private var isCancelled = false
    private var subscriptions = Set<AnyCancellable>()

    public init(
        syncableAccounts: OfflineSyncAccountsInteractor,
        sessions: Set<LoginSession>,
        scheduleInteractor: any HSyncScheduleInteractor = HSyncScheduleInteractorLive()
    ) {
        self.sessions = syncableAccounts.calculate(Array(sessions), date: Clock.now)
        self.lastLoggedInSession = LoginSession.mostRecent
        self.scheduleInteractor = scheduleInteractor
    }

    public func start(completion: @escaping () -> Void) {
        Logger.shared.log("Horizon: Background sync started with \(sessions.count) session(s).")
        syncNextSession(in: sessions, completion: completion)
    }

    public func cancel() {
        Logger.shared.log("Horizon: Background sync cancelled.")
        isCancelled = true
        subscriptions.removeAll()
        restoreLastLoggedInSession()
        scheduleInteractor.scheduleNextSync()
    }

    // MARK: - Private

    private func syncNextSession(in sessions: [LoginSession], completion: @escaping () -> Void) {
        guard !isCancelled else { return }

        guard let session = sessions.first else {
            return handleSyncCompleted(completion: completion)
        }

        Logger.shared.log("Horizon: Syncing session \(session.uniqueID).")
        AppEnvironment.shared.userDidLogin(session: session, isSilent: true)

        GetCoursesInteractorLive(userId: session.userID)
            .getCoursesWithoutModules(ignoreCache: true)
            .first()
            .sink(
                receiveCompletion: { [weak self] _ in
                    self?.scheduleInteractor.updateNextSyncDate(sessionUniqueID: session.uniqueID)
                    var remaining = sessions
                    remaining.removeFirst()
                    self?.syncNextSession(in: remaining, completion: completion)
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)
    }

    private func handleSyncCompleted(completion: () -> Void) {
        Logger.shared.log("Horizon: Background sync completed.")
        restoreLastLoggedInSession()
        scheduleInteractor.scheduleNextSync()
        completion()
    }

    private func restoreLastLoggedInSession() {
        if let session = lastLoggedInSession {
            AppEnvironment.shared.userDidLogin(session: session)
        }
    }
}
