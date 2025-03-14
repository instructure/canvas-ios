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
import Foundation

class APITokenRefreshInteractor {
    enum ManualLoginError: Error {
        case canceledByUser
        case loggedInWithDifferentUser
    }
    enum AccessTokenRefreshError: Error {
        case unknownError
        case expiredRefreshToken
    }

    private unowned let api: API
    private let waitingRequestsQueue = OperationQueue()
    private let viewModel = APITokenRefreshViewModel()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public Interface

    public private(set) var isTokenRefreshInProgress = false

    init(api: API) {
        self.api = api
        self.waitingRequestsQueue.isSuspended = true
    }

    func addRequestWaitingForToken(_ request: @escaping () -> Void) {
        waitingRequestsQueue.addOperation(request)
    }

    func refreshToken() {
        guard let oldLoginSession = api.loginSession else {
            return
        }

        isTokenRefreshInProgress = true
        unowned let uself = self

        Just(())
            .flatMap { uself.refreshAccessToken() }
            .receive(on: RunLoop.main)
            .tryCatch { error in
                try uself.loginUserManuallyIfRefreshTokenIsInvalid(error)
            }
            .sink(receiveCompletion: { completion in
                defer { uself.isTokenRefreshInProgress = false }

                switch completion {
                case .finished:
                    uself.releaseWaitingRequests()
                case .failure(let error):
                    switch error {
                    case ManualLoginError.canceledByUser, ManualLoginError.loggedInWithDifferentUser:
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

    private func loginUserManuallyIfRefreshTokenIsInvalid(_ error: Error) throws -> AnyPublisher<LoginSession, ManualLoginError> {
        guard
            let host = api.loginSession?.baseURL.host(percentEncoded: false),
            let rootViewController = AppEnvironment.shared.window?.rootViewController
        else {
            throw error
        }
        return viewModel.loginUserManually(
            host: host,
            rootViewController: rootViewController,
            router: AppEnvironment.shared.router
        )
        .flatMap { newSession in
            if newSession != AppEnvironment.shared.currentSession {
                return Fail(outputType: LoginSession.self, failure: ManualLoginError.loggedInWithDifferentUser)
                    .eraseToAnyPublisher()
            }
            return Just(newSession).setFailureType(to: ManualLoginError.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func refreshAccessToken() -> AnyPublisher<LoginSession, AccessTokenRefreshError> {
        guard
            let oldLoginSession = api.loginSession,
            let refreshToken = oldLoginSession.refreshToken,
            let clientID = oldLoginSession.clientID,
            let clientSecret = oldLoginSession.clientSecret
        else {
            return Fail(
                outputType: LoginSession.self,
                failure: AccessTokenRefreshError.unknownError
            )
            .eraseToAnyPublisher()
        }

        let client = APIVerifyClient(authorized: true, base_url: api.baseURL, client_id: clientID, client_secret: clientSecret)
        let request = PostLoginOAuthRequest(client: client, refreshToken: refreshToken)

        return api.makeRequest(request, refreshToken: false)
            .map {
                oldLoginSession.refresh(
                    accessToken: $0.body.access_token,
                    expiresAt: $0.body.expires_in.flatMap { Clock.now + $0 }
                )
            }
            .mapError { error in
                if error.isRefreshTokenInvalid {
                    return .expiredRefreshToken
                } else {
                    return .unknownError
                }
            }
            .eraseToAnyPublisher()
    }

    private func handleNewLoginSessionReceived(
        _ newSession: LoginSession,
        oldSession: LoginSession
    ) {
        api.loginSession = newSession
        LoginSession.add(newSession)
        AppEnvironment.shared.currentSession = newSession
    }

    private func logoutUser(oldSession: LoginSession) {
        AppEnvironment.shared.loginDelegate?.userDidLogout(session: oldSession)
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
