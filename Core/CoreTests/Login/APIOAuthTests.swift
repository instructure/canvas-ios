//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import XCTest
@testable import Core

class APIOAuthTests: XCTestCase {
    func testGetMobileVerifyRequest() {
        XCTAssertEqual(GetMobileVerifyRequest(domain: "cgnu").path, "https://canvas.instructure.com/api/v1/mobile_verify.json")
        XCTAssertEqual(GetMobileVerifyRequest(domain: "cgnu").queryItems, [
            URLQueryItem(name: "domain", value: "cgnu"),
        ])
    }

    func testPostLoginOAuthRequestCode() {
        let client = APIVerifyClient(authorized: true, base_url: URL(string: "https://cgnuonline-eniversity.edu"), client_id: "cgnu", client_secret: "dna evidence")
        XCTAssertEqual(PostLoginOAuthRequest(client: client, code: "1234").method, .post)
        XCTAssertEqual(PostLoginOAuthRequest(client: client, code: "1234").path, "https://cgnuonline-eniversity.edu/login/oauth2/token")
        XCTAssertEqual(PostLoginOAuthRequest(client: client, code: "1234").queryItems, [
            URLQueryItem(name: "client_id", value: "cgnu"),
            URLQueryItem(name: "client_secret", value: "dna evidence"),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: "1234"),
        ])
    }

    func testPostLoginOAuthUnauthorized() {
        let client = APIVerifyClient(authorized: false, base_url: nil, client_id: nil, client_secret: nil)
        XCTAssertEqual(PostLoginOAuthRequest(client: client, code: "1234").path, "login/oauth2/token")
        XCTAssertEqual(PostLoginOAuthRequest(client: client, code: "1234").queryItems, [
            URLQueryItem(name: "client_id", value: ""),
            URLQueryItem(name: "client_secret", value: ""),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: "1234"),
        ])
    }

    func testPostLoginOAuthRequestRefreshToken() {
        let client = APIVerifyClient(authorized: true, base_url: URL(string: "https://cgnuonline-eniversity.edu"), client_id: "cgnu", client_secret: "dna evidence")
        XCTAssertEqual(PostLoginOAuthRequest(client: client, refreshToken: "1234").method, .post)
        XCTAssertEqual(PostLoginOAuthRequest(client: client, refreshToken: "1234").path, "https://cgnuonline-eniversity.edu/login/oauth2/token")
        XCTAssertEqual(PostLoginOAuthRequest(client: client, refreshToken: "1234").queryItems, [
            URLQueryItem(name: "client_id", value: "cgnu"),
            URLQueryItem(name: "client_secret", value: "dna evidence"),
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: "1234"),
        ])
    }

    func testDeleteLoginOAuthRequest() {
        let session = LoginSession.make(accessToken: "t")
        XCTAssertEqual(DeleteLoginOAuthRequest(session: session).path, "\(session.baseURL.absoluteString)/login/oauth2/token")
        XCTAssertEqual(DeleteLoginOAuthRequest(session: session).headers, [
            HttpHeader.authorization: "Bearer t",
        ])
    }

    func testGetWebSessionRequest() {
        XCTAssertEqual(GetWebSessionRequest(to: nil).path, "/login/session_token")
        XCTAssertEqual(GetWebSessionRequest(to: nil).queryItems, [])
        XCTAssertEqual(GetWebSessionRequest(to: URL(string: "/")).queryItems, [
            URLQueryItem(name: "return_to", value: "/?display=borderless"),
        ])
    }
}
