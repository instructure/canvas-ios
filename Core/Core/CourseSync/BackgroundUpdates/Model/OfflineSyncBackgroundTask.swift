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
    public typealias SelectedItemsFactory = (SessionDefaults) -> CourseSyncListInteractor
    public static let DefaultSelectedItemsFactory: SelectedItemsFactory = {
        CourseSyncListInteractorLive(sessionDefaults: $0)
    }
    public typealias SyncInteractorFactory = () -> CourseSyncInteractor
    public static let DefaultSyncInteractorFactory: SyncInteractorFactory = {
        CourseSyncDownloaderAssembly.makeInteractor()
    }

    // MARK: - Dependencies
    private let sessionsToSync: [LoginSession]
    private let syncableAccounts: OfflineSyncAccountsCalculator
    private let syncScheduler: OfflineSyncScheduler
    private let selectedItemsInteractorFactory: SelectedItemsFactory
    private let syncInteractorFactory: SyncInteractorFactory
    // MARK: - Internal State
    private let lastLoggedInUser: LoginSession?
    private var isCancelled = false
    private var subscriptions = Set<AnyCancellable>()
    private var syncingInteractor: CourseSyncInteractor?

    // MARK: - Public Interface

    public init(syncableAccounts: OfflineSyncAccountsCalculator,
                sessions: Set<LoginSession>,
                syncScheduler: OfflineSyncScheduler = OfflineSyncScheduler(),
                selectedItemsInteractorFactory: @escaping SelectedItemsFactory = DefaultSelectedItemsFactory,
                syncInteractorFactory: @escaping SyncInteractorFactory = DefaultSyncInteractorFactory) {
        self.syncableAccounts = syncableAccounts
        self.sessionsToSync = syncableAccounts.calculate(Array(sessions),
                                                        date: Clock.now)
        self.lastLoggedInUser = LoginSession.mostRecent
        self.syncScheduler = syncScheduler
        self.selectedItemsInteractorFactory = selectedItemsInteractorFactory
        self.syncInteractorFactory = syncInteractorFactory
        Logger.shared.log("Offline: Task created with \(sessionsToSync.count) account(s) in the queue.")
    }

    public func start(completion: @escaping () -> Void) {
        syncNextAccount(in: sessionsToSync, completion: completion)
    }

    public func cancel() {
        Logger.shared.log("Offline: Cancel received.")
        isCancelled = true
        subscriptions.removeAll()
        syncScheduler.scheduleNextSync()

        guard let syncingInteractor else {
            return
        }

        syncingInteractor.cancel()
        restoreLastLoggedInUser()
    }

    // MARK: - Private Methods

    private func syncNextAccount(in sessions: [LoginSession], completion: @escaping () -> Void) {
        Logger.shared.log("Offline: Syncing next account.")

        if isCancelled {
            Logger.shared.log("Offline: Sync cancelled aborting next account sync.")
            return
        }

        guard let session = sessions.first else {
            Logger.shared.log("Offline: No more sessions to sync.")
            return handleSyncCompleted(completion: completion)
        }

        AppEnvironment.shared.userDidLogin(session: session, isSilent: true)
        let sessionDefaults = SessionDefaults(sessionID: session.uniqueID)
        let syncInteractor = syncInteractorFactory()
        syncingInteractor = syncInteractor

        selectedItemsInteractorFactory(sessionDefaults)
            .getCourseSyncEntries(filter: .all)
            .flatMap {
                Logger.shared.log("Offline: Downloading content.")
                return syncInteractor
                    .downloadContent(for: $0)
                    .setFailureType(to: Error.self)
            }
            .first()
            .flatMap { _ in
                Logger.shared.log("Offline: Waiting for sync to finish.")
                return OfflineSyncWaitToFinish.wait()
            }
            .sink(receiveCompletion: { [weak self] streamCompletion in
                switch streamCompletion {
                case .finished:
                    self?.syncScheduler.updateNextSyncDate(sessionUniqueID: session.uniqueID)
                    Logger.shared.log("Offline: Sync finished")
                case .failure(let error):
                    Logger.shared.log("Offline: Sync failed with error: \(error.localizedDescription)")
                }

                var updatedSessions = sessions
                updatedSessions.removeFirst()
                self?.syncNextAccount(in: updatedSessions, completion: completion)
            }, receiveValue: {})
            .store(in: &subscriptions)
    }

    private func handleSyncCompleted(completion: () -> Void) {
        Logger.shared.log("Offline: Sync completed.")
        restoreLastLoggedInUser()
        syncScheduler.scheduleNextSync()
        completion()
    }

    private func restoreLastLoggedInUser() {
        if let lastLoggedInUser {
            Logger.shared.log("Offline: Restoring last logged in user.")
            AppEnvironment.shared.userDidLogin(session: lastLoggedInUser)
        }
    }
}
