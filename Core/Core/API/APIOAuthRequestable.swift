//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

    let client: APIVerifyClient
    let code: String

    let method = APIMethod.post
    var path: String {
        return URL(string: "login/oauth2/token", relativeTo: client.base_url)?.absoluteString ?? "login/oauth2/token"
    }
    var query: [APIQueryItem] {
        return [
            .value("client_id", client.client_id ?? ""),
            .value("client_secret", client.client_secret ?? ""),
            .value("code", code),
        ]
    }
    let headers: [String: String?] = [
        HttpHeader.authorization: nil,
    ]
}

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#get-login-session-token
struct GetWebSessionRequest: APIRequestable {
    struct Response: Codable {
        let session_url: URL
    }

    let to: URL?

    let path = "/login/session_token"
    var query: [APIQueryItem] {
        if let returnTo = to?.appendingQueryItems(URLQueryItem(name: "display", value: "borderless")) {
            return [ .value("return_to", returnTo.absoluteString) ]
        }
        return []
    }
}
