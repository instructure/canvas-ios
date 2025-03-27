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

import Foundation

struct LoginWebRequest: APIRequestable {
    typealias Response = String
    let authMethod: AuthenticationMethod
    let clientID: String
    let provider: String?

    let path = "/login/oauth2/auth"
    let shouldAddNoVerifierQuery = false

    var query: [APIQueryItem] {
        var items: [APIQueryItem] = [
            .value("client_id", clientID),
            .value("response_type", "code"),
            .value("redirect_uri", "https://canvas/login"),
            .value("mobile", "1")
        ]

        if (authMethod == .canvasLogin) {
            items.append(.value("canvas_login", "1"))
        }

        if let provider = provider {
            items.append(.value("authentication_provider", provider))
        }

        return items
    }

    var headers: [String: String?] {
        var headers = [
            HttpHeader.userAgent: UserAgent.safari.description
        ]
        if authMethod == .siteAdminLogin {
            headers[HttpHeader.cookie] = "canvas_sa_delegated=1"
        }
        return headers
    }
}

struct LoginWebRequestPKCE: APIRequestable {
    typealias Response = String
    let clientID: String
    let host: URL
    let challenge: PKCEChallenge.ChallengePair
    let shouldAddNoVerifierQuery = false

    var path: String {
        return "https://\(host)/login/oauth2/auth"
    }

    var query: [APIQueryItem] { [
        .value("client_id", clientID),
        .value("redirect_uri", "https://canvas/login"),
        .value("response_type", "code"),
        .value("code_challenge", challenge.codeChallenge),
        .value("code_challenge_method", "S256"),
        .value("mobile", "1")
    ]
    }

    let headers: [String: String?] = [
        HttpHeader.userAgent: UserAgent.safari.description
    ]
}
