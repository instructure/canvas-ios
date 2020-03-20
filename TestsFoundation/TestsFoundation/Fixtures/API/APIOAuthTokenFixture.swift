//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core

extension APIOAuthToken {
    public static func make(
        accessToken: String = "access-token",
        refreshToken: String? = nil,
        tokenType: String = "token-type",
        user: APIOAuthUser = .make(),
        realUser: APIOAuthToken.RealUser? = nil,
        expiresIn: TimeInterval? = nil
    ) -> APIOAuthToken {
        return APIOAuthToken(
            access_token: accessToken,
            refresh_token: refreshToken,
            token_type: tokenType,
            user: user,
            real_user: realUser,
            expires_in: expiresIn
        )
    }
}

extension APIOAuthUser {
    public static func make(
        id: String = "1",
        name: String = "User 1",
        effectiveLocale: String = "en",
        email: String? = nil
    ) -> APIOAuthUser {
        return APIOAuthUser(
            id: ID(id),
            name: name,
            effective_locale: effectiveLocale,
            email: email
        )
    }

    public static func from(user: APIUser) -> APIOAuthUser {
        make(
            id: user.id.value,
            name: user.name,
            effectiveLocale: user.effective_locale ?? "en",
            email: user.email
        )
    }
}

extension APIVerifyClient {
    public static func make(
        authorized: Bool = true,
        base_url: URL? = URL(string: "https://canvas.instructure.com/")!,
        client_id: String? = "fred",
        client_secret: String? = "swordfish"
    ) -> APIVerifyClient {
        APIVerifyClient(
            authorized: authorized,
            base_url: base_url,
            client_id: client_id,
            client_secret: client_secret
        )
    }
}
