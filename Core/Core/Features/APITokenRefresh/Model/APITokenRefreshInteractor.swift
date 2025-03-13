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

import Foundation

class APITokenRefreshInteractor {
    private unowned var api: API
    private let waitingRequestsQueue = OperationQueue()
    private let viewModel = APITokenRefreshViewModel()

    // MARK: - Public Interface

    public private(set) var isTokenRefreshInProgress = false

    init(api: API) {
        self.api = api
        waitingRequestsQueue.isSuspended = true
    }

    func addRequestWaitingForToken(_ request: @escaping () -> Void) {
        waitingRequestsQueue.addOperation(request)
    }

    func refreshToken() {
        guard
            let oldLoginSession = api.loginSession,
            let refreshToken = oldLoginSession.refreshToken,
            let clientID = oldLoginSession.clientID,
            let clientSecret = oldLoginSession.clientSecret
        else {
            RemoteLogger.shared.logError(name: "Failed to refresh access token.", reason: "No old login session found.")
            return releaseWaitingRequests()
        }
        let client = APIVerifyClient(authorized: true, base_url: api.baseURL, client_id: clientID, client_secret: clientSecret)
        let request = PostLoginOAuthRequest(client: client, refreshToken: refreshToken)
        api.makeRequest(request, refreshToken: false) { response, _, error in performUIUpdate { [weak self] in
            guard let self else { return }

            if let response, error == nil {
                handleAccessTokenReceived(response, oldLoginSession: oldLoginSession)
                isTokenRefreshInProgress = false
                releaseWaitingRequests()
            } else if isRefreshTokenInvalid(error),
                   let host = api.loginSession?.baseURL.host(percentEncoded: false),
                   let rootViewController = AppEnvironment.shared.window?.rootViewController {
                viewModel.reLoginUser(
                    host: host,
                    rootViewController: rootViewController,
                    router: AppEnvironment.shared.router
                ) { [weak self] in
                    self?.handleNewLoginSessionReceived($0, oldSession: oldLoginSession)
                }
            } else {
                isTokenRefreshInProgress = false
                releaseWaitingRequests()
            }
        }}
        isTokenRefreshInProgress = true
    }

    // MARK: - Private Methods

    private func isRefreshTokenInvalid(_ error: Error?) -> Bool {
        if let apiError = error as? APIError, case APIError.invalidGrant = apiError {
            return true
        }
        return false
    }

    private func handleNewLoginSessionReceived(
        _ newSession: LoginSession?,
        oldSession: LoginSession
    ) {
        guard
            let newSession,
            newSession == AppEnvironment.shared.currentSession
        else {
            // Login failed or logged in with a different user
            cancelWaitingRequests()
            performUIUpdate {
                AppEnvironment.shared.loginDelegate?.userDidLogout(session: oldSession)
            }
            return
        }

        api.loginSession = newSession
        LoginSession.add(newSession)
        AppEnvironment.shared.currentSession = newSession
        isTokenRefreshInProgress = false
        releaseWaitingRequests()
    }

    private func handleAccessTokenReceived(
        _ response: APIOAuthToken,
        oldLoginSession: LoginSession
    ) {
        let newSession = oldLoginSession.refresh(
            accessToken: response.access_token,
            expiresAt: response.expires_in.flatMap { Clock.now + $0 }
        )
        LoginSession.add(newSession)
        if newSession == AppEnvironment.shared.currentSession {
            AppEnvironment.shared.currentSession = newSession
        }
        api.loginSession = newSession
    }

    private func releaseWaitingRequests() {
        waitingRequestsQueue.isSuspended = false
        waitingRequestsQueue.addOperation { [weak waitingRequestsQueue] in
            waitingRequestsQueue?.isSuspended = true
        }
    }

    private func cancelWaitingRequests() {
        waitingRequestsQueue.cancelAllOperations()
        waitingRequestsQueue.isSuspended = false
    }
}
