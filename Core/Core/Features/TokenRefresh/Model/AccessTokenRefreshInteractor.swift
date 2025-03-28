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

class AccessTokenRefreshInteractor {
    enum TokenError: Error {
        case unknownError
        case expiredRefreshToken
    }

    func refreshAccessToken(api: API) -> AnyPublisher<LoginSession, TokenError> {
        guard
            let oldLoginSession = api.loginSession,
            let refreshToken = oldLoginSession.refreshToken,
            let clientID = oldLoginSession.clientID,
            let clientSecret = oldLoginSession.clientSecret
        else {
            return Fail(
                outputType: LoginSession.self,
                failure: TokenError.unknownError
            )
            .eraseToAnyPublisher()
        }

        let client = APIVerifyClient(
            authorized: true,
            base_url: api.baseURL,
            client_id: clientID,
            client_secret: clientSecret
        )
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
}

extension Error {

    var isExpiredRefreshTokenError: Bool {
        (self as? AccessTokenRefreshInteractor.TokenError) == .expiredRefreshToken
    }
}
