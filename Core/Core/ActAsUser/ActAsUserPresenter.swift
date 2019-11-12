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

public class ActAsUserPresenter {
    let env: AppEnvironment
    weak var loginDelegate: LoginDelegate?

    init(env: AppEnvironment = .shared, loginDelegate: LoginDelegate) {
        self.env = env
        self.loginDelegate = loginDelegate
    }

    func didSubmit(domain: String, userID: String, callback: @escaping (Error?) -> Void) {
        var host = domain
        if !host.contains(".") {
            host = "\(host).instructure.com"
        }
        if URLComponents.parse(host).scheme == nil {
            host = "https://\(host)"
        }
        guard let baseURL = URL(string: host), let session = env.currentSession else {
            return callback(NSError.internalError())
        }
        let api = URLSessionAPI(loginSession: session, baseURL: baseURL)
        api.makeRequest(GetUserRequest(userID: userID)) { (user, _, error) in DispatchQueue.main.async {
            guard let user = user, error == nil else {
                return callback(error ?? NSError.internalError())
            }
            let entry = LoginSession(
                accessToken: session.accessToken,
                baseURL: baseURL,
                expiresAt: session.expiresAt,
                lastUsedAt: Date(),
                locale: user.locale ?? user.effective_locale,
                masquerader: (session.originalBaseURL ?? session.baseURL)
                    .appendingPathComponent("users")
                    .appendingPathComponent(session.originalUserID ?? session.userID),
                refreshToken: session.refreshToken,
                userAvatarURL: user.avatar_url?.rawValue,
                userID: user.id.value,
                userName: user.short_name,
                userEmail: user.email,
                clientID: session.clientID,
                clientSecret: session.clientSecret
            )
            callback(nil)
            self.loginDelegate?.startActing(as: entry)
        } }
    }
}
