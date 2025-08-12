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
import Foundation
import UIKit

enum LoginError: Error {
    case loggedOut
    case unauthorized
}

final class SessionInteractor: NSObject {
    private let environment: AppEnvironment
    private var subscriptions = Set<AnyCancellable>()
    private let loginDelegate: LoginDelegate?

    init(loginDelegate: LoginDelegate? = nil, environment: AppEnvironment = .shared) {
        self.environment = environment
        self.loginDelegate = loginDelegate
    }

    func getUserID() -> AnyPublisher<String, Error> {
        guard let currentSession = environment.currentSession else {
            return Fail(error: LoginError.loggedOut).eraseToAnyPublisher()
        }
        return Just(currentSession.userID)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func getUserID() -> String? {
        environment.currentSession?.userID
    }

    func logout() {
        guard
            let currentSession = environment.currentSession,
            let loginDelegate = environment.loginDelegate else {
            return
        }
        loginDelegate.userDidLogout(session: currentSession)
    }

    /*
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
                 PushNotificationsInteractor.shared.userDidLogin(api: unownedSelf.environment.api)

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
                     unownedSelf.loginDelegate?.userDidLogout(session: session)
                     return LoginError.unauthorized
                 } else if let apiError = error as? APIError, case .unauthorized = apiError {
                     unownedSelf.environment.loginDelegate?.userDidLogout(session: session)
                     return LoginError.unauthorized
                 } else {
                     return error
                 }
             }
             .eraseToAnyPublisher()
     }
      */
}
