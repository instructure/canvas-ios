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
    // MARK: - Dependencies
    private let sessionsToSync: [LoginSession]
    private let syncableAccounts: OfflineSyncAccountsCalculator
    // MARK: - Internal State
    private let lastLoggedInUser: LoginSession?
    private var isCancelled = false
    private var subscriptions = Set<AnyCancellable>()
    private var syncingInteractor: CourseSyncInteractor?

    // MARK: - Public Interface

    public init(syncableAccounts: OfflineSyncAccountsCalculator,
                sessions: Set<LoginSession>) {
        self.syncableAccounts = syncableAccounts
        self.sessionsToSync = syncableAccounts.calculate(Array(sessions),
                                                        date: Clock.now)
        self.lastLoggedInUser = LoginSession.mostRecent
    }

    public func start(completion: @escaping () -> Void) {
        syncNextAccount(in: sessionsToSync, completion: completion)
    }

    public func cancel() {
        Logger.shared.log()
        isCancelled = true
        subscriptions.removeAll()

        guard let syncingInteractor else {
            return
        }

        syncingInteractor.cancel()
        restoreLastLoggedInUser()
    }

    // MARK: - Private Methods

    private func syncNextAccount(in sessions: [LoginSession], completion: @escaping () -> Void) {
        if isCancelled {
            return
        }
        guard let session = sessions.first else {
            return handleSyncCompleted(completion: completion)
        }

        Logger.shared.log()
        AppEnvironment.shared.userDidLogin(session: session, isSilent: true)
        let sessionDefaults = SessionDefaults(sessionID: session.uniqueID)
        let selectedItemsInteractor = CourseSyncListInteractorLive(sessionDefaults: sessionDefaults)
        let courseSyncInteractor = CourseSyncDownloaderAssembly.makeInteractor()
        syncingInteractor = courseSyncInteractor

        selectedItemsInteractor
            .getCourseSyncEntries(filter: .all)
            .flatMap { courseSyncInteractor.downloadContent(for: $0).setFailureType(to: Error.self) }
            .first()
            .flatMap { _ in Self.waitForSyncFinish().setFailureType(to: Error.self) }
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] _ in
                var updatedSessions = sessions
                updatedSessions.removeFirst()
                self?.syncNextAccount(in: updatedSessions, completion: completion)
            })
            .store(in: &subscriptions)
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
    private static func waitForSyncFinish() -> AnyPublisher<Void, Never> {
        Logger.shared.log()
        let downloadFinishedPredicate = NSPredicate(key: #keyPath(CourseSyncDownloadProgress.isFinished), equals: true)
        let downloadFinishedScope = Scope(predicate: downloadFinishedPredicate, order: [])
        let useCase = LocalUseCase<CourseSyncDownloadProgress>(scope: downloadFinishedScope)
        let store = ReactiveStore(offlineModeInteractor: nil, useCase: useCase)

        return store
            .observeEntities()
            .compactMap { $0.firstItem }
            .mapToVoid()
            .first()
            .map { store.cancel() }
            .eraseToAnyPublisher()
    }
}
