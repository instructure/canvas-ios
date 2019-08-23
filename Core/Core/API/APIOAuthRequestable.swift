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

// Not documented in canvas rest api
struct GetMobileVerifyRequest: APIRequestable {
    typealias Response = APIVerifyClient

    let domain: String

    let path = "https://canvas.instructure.com/api/v1/mobile_verify.json"
    var query: [APIQueryItem] {
        return [.value("domain", domain)]
    }
    var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }
    let headers: [String: String?] = [
        HttpHeader.accept: "application/json",
        HttpHeader.authorization: nil,
    ]
}

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#post-login-oauth2-token
struct PostLoginOAuthRequest: APIRequestable {
    typealias Response = APIOAuthToken

    enum GrantType {
        case code(String)
        case refreshToken(String)
    }

    let client: APIVerifyClient
    let grantType: GrantType

    init(client: APIVerifyClient, code: String) {
        self.client = client
        self.grantType = .code(code)
    }

    init(client: APIVerifyClient, refreshToken: String) {
        self.client = client
        self.grantType = .refreshToken(refreshToken)
    }

    let method = APIMethod.post
    var path: String {
        return URL(string: "login/oauth2/token", relativeTo: client.base_url)?.absoluteString ?? "login/oauth2/token"
    }
    var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .value("client_id", client.client_id ?? ""),
            .value("client_secret", client.client_secret ?? ""),
        ]

        switch grantType {
        case .code(let code):
            query.append(.value("grant_type", "authorization_code"))
            query.append(.value("code", code))
        case .refreshToken(let token):
            query.append(.value("grant_type", "refresh_token"))
            query.append(.value("refresh_token", token))
        }

        return query
    }
    let headers: [String: String?] = [
        HttpHeader.authorization: nil,
    ]
}

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#get-login-session-token
public struct GetWebSessionRequest: APIRequestable {
    public struct Response: Codable {
        public let session_url: URL
    }

    public let to: URL?

    public let path = "/login/session_token"
    public var query: [APIQueryItem] {
        if let returnTo = to?.appendingQueryItems(URLQueryItem(name: "display", value: "borderless")) {
            return [ .value("return_to", returnTo.absoluteString) ]
        }
        return []
    }

    public init(to: URL?) {
        self.to = to
    }
}
