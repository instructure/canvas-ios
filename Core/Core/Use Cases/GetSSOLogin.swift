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

public class GetSSOLogin {
    let domain: String
    let code: String

    public init?(url: URL) {
        let components = URLComponents.parse(url)
        guard
            let host = components.host, [ "sso.canvaslms.com", "sso.beta.canvaslms.com", "sso.test.canvaslms.com" ].contains(host),
            components.path == "/canvas/login",
            let domain = components.queryItems?.first(where: { $0.name == "domain" })?.value, !domain.isEmpty,
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value, !code.isEmpty
        else {
            return nil
        }
        self.code = code
        self.domain = domain
    }

    public func fetch(environment: AppEnvironment = .shared, _ callback: @escaping (LoginSession?, Error?) -> Void) {
        let api = environment.api
        let code = self.code
        let done = { (session: LoginSession?, error: Error?) in
            DispatchQueue.main.async { callback(session, error) }
        }
        api.makeRequest(GetMobileVerifyRequest(domain: domain)) { (response, _, error) in
            guard let client = response, let baseURL = client.base_url, error == nil else { return done(nil, error) }
            api.makeRequest(PostLoginOAuthRequest(client: client, code: code)) { (response, _, error) in
                guard let model = response, error == nil else { return done(nil, error) }
                done(LoginSession(
                    accessToken: model.access_token,
                    baseURL: baseURL,
                    expiresAt: model.expires_in.flatMap { Date().addingTimeInterval($0) },
                    locale: model.user.effective_locale,
                    refreshToken: model.refresh_token,
                    userID: model.user.id.value,
                    userName: model.user.name,
                    userEmail: model.user.email
                ), nil)
            }
        }
    }
}
