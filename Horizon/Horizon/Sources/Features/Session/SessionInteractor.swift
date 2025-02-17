//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

enum LoginError: Error {
    case loggedOut
    case unauthorized
}

final class SessionInteractor: NSObject, LoginDelegate {
    private let environment: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()

    init(environment: AppEnvironment = .shared) {
        self.environment = environment
    }

    func refreshCurrentUserDetails() -> AnyPublisher<UserProfile, Error> {
        guard let currentSession = LoginSession.mostRecent else {
            return Fail(error: LoginError.loggedOut).eraseToAnyPublisher()
        }

        return updateLoginSession(session: currentSession)
    }

    private func updateLoginSession(session: LoginSession) -> AnyPublisher<UserProfile, Error> {
        LoginSession.add(session)
        environment.userDidLogin(session: session)

        unowned let unownedSelf = self

        return ReactiveStore(useCase: GetUserProfile())
            .getEntities(ignoreCache: true)
            .compactMap { $0.first }
            .flatMap { userProfile in
                CoreWebView.keepCookieAlive(for: unownedSelf.environment)
                PushNotificationsInteractor.shared.userDidLogin(loginSession: session)

                return ReactiveStore(
                    useCase: GetEnvironmentFeatureFlags(context: Context.currentUser)
                )
                .getEntities(ignoreCache: true)
                .map { _ in userProfile }
            }
            .mapError { error in
                let err = error as NSError
                if err.domain == NSError.Constants.domain,
                   err.code == HttpError.unauthorized {
                    unownedSelf.userDidLogout(session: session)
                    return LoginError.unauthorized
                } else {
                    return error
                }
            }
            .eraseToAnyPublisher()
    }

    private func initializeTracking() {}
}

extension SessionInteractor {
    func changeUser() {
        guard let window = environment.window, !(window.rootViewController is LoginNavigationController) else { return }
        LoginViewModel().showLoginView(on: window, loginDelegate: self, app: .horizon)
    }

    func stopActing() {
        if let session = environment.currentSession {
            stopActing(as: session)
        }
    }

    func logout() {
        if let session = environment.currentSession {
            userDidLogout(session: session)
        }
    }

    func openExternalURL(_ url: URL) {
        openExternalURLinSafari(url)
    }

    func openExternalURLinSafari(_ url: URL) {
        UIApplication.shared.open(url)
    }

    func userDidLogin(session: LoginSession) {
        LoginSession.add(session)
    }

    func userDidStopActing(as session: LoginSession) {
        LoginSession.remove(session)
        guard environment.currentSession == session else { return }
        PageViewEventController.instance.userDidChange()
        PushNotificationsInteractor.shared.unsubscribeFromCanvasPushNotifications()
        // TODO: Revisit when implementing notifications
        //        UIApplication.shared.applicationIconBadgeNumber = 0
        environment.userDidLogout(session: session)
        CoreWebView.stopCookieKeepAlive()
    }

    func userDidLogout(session: LoginSession) {
        let wasCurrent = environment.currentSession == session
        API(session).makeRequest(DeleteLoginOAuthRequest(), refreshToken: false) { _, _, _ in }
        userDidStopActing(as: session)
        if wasCurrent { changeUser() }
    }

    func actAsFakeStudent(withID _: String) {}
}
