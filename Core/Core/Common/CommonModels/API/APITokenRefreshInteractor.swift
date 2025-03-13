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

import UIKit

class APITokenRefreshInteractor {
    private unowned var api: API
    private let waitingRequestsQueue = OperationQueue()

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
        api.makeRequest(request, refreshToken: false) { [weak self] response, _, error in
            guard let self else { return }

            if let response, error == nil {
                handleAccessTokenReceived(response, oldLoginSession: oldLoginSession)
                isTokenRefreshInProgress = false
                releaseWaitingRequests()
            } else if isRefreshTokenInvalid(error) {
                DispatchQueue.main.async {
                    self.showLoginDialog()
                }
            } else {
                isTokenRefreshInProgress = false
                releaseWaitingRequests()
            }
        }
        isTokenRefreshInProgress = true
    }

    // MARK: - Private Methods

    private func showLoginDialog() {
        let message = String(
            localized: "You'll need to log in again due to your institute's security policy. Once logged in, you can continue working seamlessly.",
            bundle: .core
        )
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(AlertAction(String(localized: "OK", bundle: .core), style: .default) { [weak self] _ in
            self?.showLoginWebViewController()
        })
        AppEnvironment.shared.window?.rootViewController?.present(alert, animated: true)
    }

    private func showLoginWebViewController() {
        guard
            let host = api.loginSession?.baseURL.host(percentEncoded: false),
            let rootViewContoller = AppEnvironment.shared.window?.rootViewController
        else {
            return
        }
        let controller = LoginWebViewController.create(host: host, loginDelegate: nil, method: .normalLogin)
        controller.loginCompletion = { [weak self] newSession in
            controller.dismiss(animated: true) {
                self?.handleNewLoginSessionReceived(newSession)
            }
        }
        controller.navigationItem.rightBarButtonItem = UIBarButtonItemWithCompletion(title: String(localized: "Cancel", bundle: .core), actionHandler: { [weak controller] in
            controller?.dismiss(animated: true)
        })

        let navController = CoreNavigationController(rootViewController: controller)
        AppEnvironment.shared.router.show(navController, from: rootViewContoller, analyticsRoute: "/login/weblogin")
    }

    private func isRefreshTokenInvalid(_ error: Error?) -> Bool {
        if let apiError = error as? APIError, case APIError.invalidGrant = apiError {
            return true
        }
        return false
    }

    private func handleNewLoginSessionReceived(_ newSession: LoginSession) {
        // TODO: check if session matches the currently active
        api.loginSession = newSession
        LoginSession.add(newSession)
        if newSession == AppEnvironment.shared.currentSession {
            AppEnvironment.shared.currentSession = newSession
        }
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
}
