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
    struct Body: Codable {
        let client_id: String
        let client_secret: String
        let grant_type: String
        let code: String?
        let refresh_token: String?

        init(client: APIVerifyClient, grantType: GrantType) {
            self.client_id = client.client_id ?? ""
            self.client_secret = client.client_secret ?? ""

            switch grantType {
            case .code(let code):
                self.grant_type = "authorization_code"
                self.code = code
                self.refresh_token = nil
            case .refreshToken(let token):
                self.grant_type = "refresh_token"
                self.refresh_token = token
                self.code = nil
            }
        }
    }

    enum GrantType {
        case code(String)
        case refreshToken(String)
    }

    let client: APIVerifyClient

    init(client: APIVerifyClient, code: String) {
        self.client = client
        self.body = Body(client: client, grantType: .code(code))
    }

    init(client: APIVerifyClient, refreshToken: String) {
        self.client = client
        self.body = Body(client: client, grantType: .refreshToken(refreshToken))
    }

    let body: Body?
    let method = APIMethod.post
    var path: String {
        return URL(string: "login/oauth2/token", relativeTo: client.base_url)?.absoluteString ?? "login/oauth2/token"
    }

    let headers: [String: String?] = [
        HttpHeader.authorization: nil,
    ]
}

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#delete-login-oauth2-token
public struct DeleteLoginOAuthRequest: APIRequestable {
    public typealias Response = APINoContent

    public init() {}

    public var method: APIMethod { .delete }
    public var path: String { "/login/oauth2/token" }
}

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#get-login-session-token
public struct GetWebSessionRequest: APIRequestable {
    public struct Response: Codable {
        public let session_url: URL
        public let requires_terms_acceptance: Bool
    }

    public let to: URL?
    /** Required by `APIRequestable` protocol. */
    public let path: String

    public var query: [APIQueryItem] {
        // Inline data content URLs need no extra query params
        if let to = to, to.scheme == "data" {
            return [ .value("return_to", to.absoluteString) ]
        }

        if let returnTo = to?.appendingQueryItems(URLQueryItem(name: "display", value: "borderless")) {
            return [ .value("return_to", returnTo.absoluteString) ]
        }
        return []
    }

    public init(to: URL?, path: String = "/login/session_token") {
        self.to = to
        self.path = path
    }
}
