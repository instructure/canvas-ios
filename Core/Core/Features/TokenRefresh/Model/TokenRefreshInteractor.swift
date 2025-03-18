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
import CombineSchedulers
import Foundation

class TokenRefreshInteractor {
    private unowned let api: API
    private let waitingRequestsQueue = OperationQueue()
    private let loginAgainInteractor: LoginAgainInteractor
    private let accessTokenRefreshInteractor: AccessTokenRefreshInteractor
    private let mainThread: AnySchedulerOf<DispatchQueue>
    private let synchronizer = DispatchQueue(
        label: "TokenRefreshInteractor.synchronizer",
        target: .global(qos: .userInitiated)
    )
    private var subscriptions = Set<AnyCancellable>()
    private var refreshingToken = false

    // MARK: - Public Interface

    init(
        api: API,
        accessTokenRefreshInteractor: AccessTokenRefreshInteractor = AccessTokenRefreshInteractor(),
        loginAgainInteractor: LoginAgainInteractor = LoginAgainInteractor(),
        mainThread: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.api = api
        self.accessTokenRefreshInteractor = accessTokenRefreshInteractor
        self.waitingRequestsQueue.isSuspended = true
        self.loginAgainInteractor = loginAgainInteractor
        self.mainThread = mainThread
    }

    func isTokenRefreshInProgress() -> Bool {
        synchronizer.sync { refreshingToken }
    }

    func addRequestWaitingForToken(_ request: @escaping () -> Void) {
        waitingRequestsQueue.addOperation(request)
    }

    func refreshToken() {
        guard let oldLoginSession = api.loginSession else {
            return
        }

        synchronizer.sync { refreshingToken = true }
        unowned let uself = self

        Just(())
            .flatMap { uself.accessTokenRefreshInteractor.refreshAccessToken(api: uself.api) }
            .receive(on: mainThread)
            .tryCatch { error in
                try uself.loginAgainInteractor.loginAgainOnExpiredRefreshToken(tokenRefreshError: error, api: uself.api)
            }
            .receive(on: synchronizer)
            .sink(receiveCompletion: { completion in
                defer { uself.refreshingToken = false }

                switch completion {
                case .finished:
                    uself.releaseWaitingRequests()
                case .failure(let error):
                    switch error {
                    case LoginAgainInteractor.LoginError.canceledByUser, LoginAgainInteractor.LoginError.loggedInWithDifferentUser:
                        uself.cancelWaitingRequests()
                        uself.logoutUser(oldSession: oldLoginSession)
                    default:
                        uself.releaseWaitingRequests()
                    }
                }
            }, receiveValue: { newSession in
                uself.handleNewLoginSessionReceived(newSession, oldSession: oldLoginSession)
            })
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func handleNewLoginSessionReceived(
        _ newSession: LoginSession,
        oldSession: LoginSession
    ) {
        api.loginSession = newSession
        LoginSession.add(newSession)

        if AppEnvironment.shared.currentSession == newSession {
            AppEnvironment.shared.currentSession = newSession
        }
    }

    private func logoutUser(oldSession: LoginSession) {
        mainThread.schedule {
            AppEnvironment.shared.loginDelegate?.userDidLogout(session: oldSession)
        }
    }

    private func releaseWaitingRequests() {
        waitingRequestsQueue.isSuspended = false
        waitingRequestsQueue.addOperation { [weak waitingRequestsQueue] in
            waitingRequestsQueue?.isSuspended = true
        }
    }

    private func cancelWaitingRequests() {
        waitingRequestsQueue.cancelAllOperations()
        // This is because canceled tasks are not removed from the queue.
        releaseWaitingRequests()
    }
}
