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

class LoginAgainInteractor {
    enum LoginError: Error {
        case canceledByUser
        case loggedInWithDifferentUser
    }

    private let loginAgainViewModel: LoginAgainViewModel

    init(
        loginAgainViewModel: LoginAgainViewModel = LoginAgainViewModel()
    ) {
        self.loginAgainViewModel = loginAgainViewModel
    }

    func loginAgainOnExpiredRefreshToken(
        tokenRefreshError: Error,
        api: API
    ) throws -> AnyPublisher<LoginSession, LoginError> {
        guard
            let host = api.loginSession?.baseURL.host(percentEncoded: false),
            let rootViewController = AppEnvironment.shared.window?.rootViewController,
            tokenRefreshError as? AccessTokenRefreshInteractor.TokenError == .expiredRefreshToken
        else {
            throw tokenRefreshError
        }

        return loginAgainViewModel.askUserToLogin(
            host: host,
            rootViewController: rootViewController,
            router: AppEnvironment.shared.router
        )
        .flatMap { newSession in
            guard newSession == AppEnvironment.shared.currentSession else {
                return Fail(
                    outputType: LoginSession.self,
                    failure: LoginError.loggedInWithDifferentUser
                )
                .eraseToAnyPublisher()
            }
            return Just(newSession)
                .setFailureType(to: LoginError.self)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}
