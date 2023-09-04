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
import Combine

/**
 This class contains the actual logic of triggering the background sync of all users
 who have this turned on.
 */
public class OfflineSyncBackgroundTask: BackgroundTask {
    private let sessionsToSync: [LoginSession]
    private let syncableAccounts: OfflineSyncAccounts
    private let lastLoggedInUser: LoginSession?
    private var isCancelled = false

    public init(syncableAccounts: OfflineSyncAccounts,
                sessions: Set<LoginSession>) {
        self.syncableAccounts = syncableAccounts
        self.sessionsToSync = syncableAccounts.calculate(Array(sessions),
                                                        date: Clock.now)
        self.lastLoggedInUser = LoginSession.mostRecent
    }

    public func start(completion: @escaping () -> Void) {
        for session in sessionsToSync {
            if isCancelled { return }

            Logger.shared.log()
            AppEnvironment.shared.userDidLogin(session: session, isSilent: true)
            let sessionDefaults = SessionDefaults(sessionID: session.uniqueID)
            let selectorInteractor = CourseSyncSelectorInteractorLive(courseID: nil,
                                                                      sessionDefaults: sessionDefaults)
            let entriesToSync = selectorInteractor.getSelectedCourseEntries()
            NotificationCenter.default.post(name: .OfflineSyncTriggered, object: entriesToSync)
            waitForSyncFinish()
        }

        handleSyncCompleted(completion: completion)
    }

    public func cancel() {
        Logger.shared.log()
        isCancelled = true
        NotificationCenter.default.post(name: .OfflineSyncCancelled, object: nil)
        waitForSyncFinish()
        restoreLastLoggedInUser()
    }

    private func handleSyncCompleted(completion: () -> Void) {
        Logger.shared.log()
        restoreLastLoggedInUser()
        completion()
    }

    private func restoreLastLoggedInUser() {
        if let lastLoggedInUser {
            Logger.shared.log()
            AppEnvironment.shared.userDidLogin(session: lastLoggedInUser)
        }
    }

    // TODO: This wont detect cancelled downloads
    private func waitForSyncFinish() {
        Logger.shared.log()
        let downloadFinishedPredicate = NSPredicate(key: #keyPath(CourseSyncDownloadProgress.isFinished), equals: true)
        let downloadFinishedScope = Scope(predicate: downloadFinishedPredicate, order: [])
        let useCase = LocalUseCase<CourseSyncDownloadProgress>(scope: downloadFinishedScope)
        let store = ReactiveStore(offlineModeInteractor: nil, useCase: useCase)

        let semaphore = DispatchSemaphore(value: 0)
        var subscription: AnyCancellable?
        subscription = store
            .observeEntities()
            .compactMap { $0.firstItem }
            .sink { _ in
                semaphore.signal()
            }

        semaphore.wait()
        subscription?.cancel()
        store.cancel()
    }
}
