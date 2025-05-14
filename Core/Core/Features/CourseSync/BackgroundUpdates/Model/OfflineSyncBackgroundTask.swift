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
    public typealias SelectedItemsFactory = (SessionDefaults) -> CourseSyncSelectorInteractor
    public static let DefaultSelectedItemsFactory: SelectedItemsFactory = { sessionDefaults in
        let courseSyncListInteractor = CourseSyncListInteractorLive(sessionDefaults: sessionDefaults)
        return CourseSyncSelectorInteractorLive(courseSyncListInteractor: courseSyncListInteractor,
                                         sessionDefaults: sessionDefaults)
    }
    public typealias SyncInteractorFactory = () -> CourseSyncInteractor
    public static let DefaultSyncInteractorFactory: SyncInteractorFactory = {
        CourseSyncDownloaderAssembly.makeInteractor()
    }

    // MARK: - Dependencies
    private let sessionsToSync: [LoginSession]
    private let syncableAccounts: OfflineSyncAccountsInteractor
    private let syncScheduler: OfflineSyncScheduleInteractor
    private let networkAvailabilityService: NetworkAvailabilityService
    private let selectedItemsInteractorFactory: SelectedItemsFactory
    private let syncInteractorFactory: SyncInteractorFactory
    // MARK: - Internal State
    private let lastLoggedInUser: LoginSession?
    private var isCancelled = false
    private var subscriptions = Set<AnyCancellable>()
    private var syncingInteractor: CourseSyncInteractor?

    // MARK: - Public Interface

    public init(syncableAccounts: OfflineSyncAccountsInteractor,
                sessions: Set<LoginSession>,
                syncScheduler: OfflineSyncScheduleInteractor = OfflineSyncScheduleInteractor(),
                networkAvailabilityService: NetworkAvailabilityService = NetworkAvailabilityServiceLive(),
                selectedItemsInteractorFactory: @escaping SelectedItemsFactory = DefaultSelectedItemsFactory,
                syncInteractorFactory: @escaping SyncInteractorFactory = DefaultSyncInteractorFactory) {
        self.syncableAccounts = syncableAccounts
        self.sessionsToSync = syncableAccounts.calculate(Array(sessions),
                                                        date: Clock.now)
        self.lastLoggedInUser = LoginSession.mostRecent
        self.syncScheduler = syncScheduler
        self.networkAvailabilityService = networkAvailabilityService
        self.selectedItemsInteractorFactory = selectedItemsInteractorFactory
        self.syncInteractorFactory = syncInteractorFactory
        networkAvailabilityService.startMonitoring()
        Logger.shared.log("Offline: Task created with \(sessionsToSync.count) account(s) in the queue.")
    }

    public func start(completion: @escaping () -> Void) {
        // Wait until we get back the network status
        networkAvailabilityService
            .startObservingStatus()
            .compactMap { $0 }
            .first()
            .sink { [sessionsToSync, weak self] _ in
                self?.syncNextAccount(in: sessionsToSync, completion: completion)
            } receiveValue: { _ in }
            .store(in: &subscriptions)
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
        if isCancelled {
            Logger.shared.log("Offline: Sync cancelled, aborting next account sync.")
            return
        }

        guard let session = sessions.first else {
            Logger.shared.log("Offline: No more sessions to sync.")
            return handleSyncCompleted(completion: completion)
        }

        Logger.shared.log("Offline: Syncing \(session.uniqueID).")

        AppEnvironment.shared.userDidLogin(session: session, isSilent: true)
        let sessionDefaults = SessionDefaults(sessionID: session.uniqueID)

        if sessionDefaults.isOfflineWifiOnlySyncEnabled == true, networkAvailabilityService.status == .connected(.cellular) {
            Logger.shared.log("Offline: Wifi only sync is selected but wifi not available, postponing.")
            syncScheduler.updateNextSyncDate(sessionUniqueID: session.uniqueID)
            removeCompletedSessionAndStartNextSync(sessions: sessions, completion: completion)
            return
        }

        let syncInteractor = syncInteractorFactory()
        syncingInteractor = syncInteractor

        let selectedItemsInteractor = selectedItemsInteractorFactory(sessionDefaults)

        selectedItemsInteractor
            .getSelectedCourseEntries()
            .flatMap { _ in selectedItemsInteractor.getDeselectedCourseIds()}
            .flatMap { entries in
                syncInteractor.cleanContent(for: entries)
            }
            .sink()
            .store(in: &subscriptions)

        selectedItemsInteractor
            .getCourseSyncEntries() // Build up the internal state of the interactor
            .flatMap { _ in selectedItemsInteractor.getSelectedCourseEntries() } // Actually get what is selected to sync
            .flatMap {
                Logger.shared.log("Offline: Downloading content.")
                return syncInteractor
                    .downloadContent(for: $0)
                    .setFailureType(to: Error.self)
            }
            .first()
            .flatMap { _ in
                Logger.shared.log("Offline: Waiting for sync to finish.")
                return NotificationCenter.default.publisher(for: .OfflineSyncCompleted)
                    .mapToVoid()
                    .first()
            }
            .sink(receiveCompletion: { [weak self] streamCompletion in
                switch streamCompletion {
                case .finished:
                    self?.syncScheduler.updateNextSyncDate(sessionUniqueID: session.uniqueID)
                    Logger.shared.log("Offline: Sync finished")
                case .failure(let error):
                    RemoteLogger.shared.logError(name: "Background offline sync failed", reason: error.localizedDescription)
                    Logger.shared.log("Offline: Sync failed with error: \(error.localizedDescription)")
                }

                self?.removeCompletedSessionAndStartNextSync(sessions: sessions, completion: completion)
            }, receiveValue: {})
            .store(in: &subscriptions)
    }

    private func removeCompletedSessionAndStartNextSync(sessions: [LoginSession],
                                                        completion: @escaping () -> Void) {
        var updatedSessions = sessions
        updatedSessions.removeFirst()
        syncNextAccount(in: updatedSessions, completion: completion)
    }

    private func handleSyncCompleted(completion: () -> Void) {
        Logger.shared.log("Offline: Sync completed.")
        restoreLastLoggedInUser()
        syncScheduler.scheduleNextSync()
        completion()
    }

    private func restoreLastLoggedInUser() {
        if let lastLoggedInUser {
            Logger.shared.log("Offline: Restoring last logged in user \(lastLoggedInUser.uniqueID).")
            AppEnvironment.shared.userDidLogin(session: lastLoggedInUser)
        }
    }
}
