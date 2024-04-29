//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

@testable import Core

extension LoginSession {
    public static func make(
        accessToken: String? = "token",
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        expiresAt: Date? = nil,
        lastUsedAt: Date = Date(),
        locale: String? = "en",
        masquerader: URL? = nil,
        refreshToken: String? = nil,
        userAvatarURL: URL? = nil,
        userID: String = "1",
        userName: String = "Eve",
        userEmail: String? = nil,
        clientID: String? = nil,
        clientSecret: String? = nil
    ) -> LoginSession {
        return LoginSession(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: expiresAt,
            lastUsedAt: lastUsedAt,
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName,
            userEmail: userEmail,
            clientID: clientID,
            clientSecret: clientSecret
        )
    }
}
