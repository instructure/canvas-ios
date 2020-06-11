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
struct APIVerifyClient: Codable, Equatable {
    let authorized: Bool
    let base_url: URL?
    let client_id: String?
    let client_secret: String?
}

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#post-login-oauth2-token
public struct APIOAuthToken: Codable, Equatable {
    public struct RealUser: Codable, Equatable {
        let id: ID
        let name: String
    }

    let access_token: String
    let refresh_token: String?
    let token_type: String
    let user: APIOAuthUser
    let real_user: RealUser?
    let expires_in: TimeInterval?
}

public struct APIOAuthUser: Codable, Equatable {
    let id: ID
    let name: String
    let effective_locale: String
    let email: String?
}

#if DEBUG
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
#endif

// Not documented in canvas rest api
struct GetMobileVerifyRequest: APIRequestable {
    typealias Response = APIVerifyClient

    let domain: String

    var path: String {
        if let overrideUrl = ProcessInfo.processInfo.environment["OVERRIDE_MOBILE_VERIFY_URL"] {
            return overrideUrl
        }
        return "https://canvas.instructure.com/api/v1/mobile_verify.json"
    }

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

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#delete-login-oauth2-token
public struct DeleteLoginOAuthRequest: APIRequestable {
    public typealias Response = APINoContent

    let session: LoginSession
    public init(session: LoginSession) {
        self.session = session
    }

    public let method = APIMethod.delete
    public var path: String {
        return session.baseURL.appendingPathComponent("login/oauth2/token").absoluteString
    }

    public var headers: [String: String?] {
        return [
            HttpHeader.authorization: session.accessToken.flatMap { "Bearer \($0)" },
        ]
    }
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
