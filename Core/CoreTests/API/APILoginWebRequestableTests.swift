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

import XCTest
@testable import Core

class APILoginWebRequestableTests: XCTestCase {

    var mobileVerify: APIVerifyClient!
    var params: LoginParams!
    var host = "https://localhost"
    var url: URL!
    override func setUp() {
        super.setUp()
        url = URL(string: host)!
        mobileVerify = APIVerifyClient(authorized: true, base_url: url, client_id: "1", client_secret: "secret")
        params = LoginParams(host: host, authenticationProvider: "", method: .normalLogin)
    }

    func testPath() {
        let req = LoginWebRequest(clientID: mobileVerify.client_id!, params: params)
        let urlRequest = try? req.urlRequest(relativeTo: url, accessToken: "", actAsUserID: nil)
        let expected = "https://localhost/login/oauth2/auth?client_id=1&response_type=code&redirect_uri=https://canvas/login&mobile=1"
        XCTAssertEqual(urlRequest?.url?.absoluteString, expected)
    }

    func testHeaders() {
        let req = LoginWebRequest(clientID: mobileVerify.client_id!, params: params)
        let urlRequest = try? req.urlRequest(relativeTo: url, accessToken: nil, actAsUserID: nil)
        let expected = [HttpHeader.accept: "application/json+canvas-string-ids", HttpHeader.userAgent: UserAgent.safari.description]
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expected)
    }

    func testSiteAdminHeaders() {
        params = LoginParams(host: host, authenticationProvider: "", method: .siteAdminLogin)
        let req = LoginWebRequest(clientID: mobileVerify.client_id!, params: params)
        let urlRequest = try? req.urlRequest(relativeTo: url, accessToken: nil, actAsUserID: nil)
        let expected = [
            HttpHeader.accept: "application/json+canvas-string-ids",
            HttpHeader.userAgent: UserAgent.safari.description,
            HttpHeader.cookie: "canvas_sa_delegated=1",
        ]
        XCTAssertEqual(urlRequest?.allHTTPHeaderFields, expected)
    }

    func testQueryItems() {
        let req = LoginWebRequest(clientID: mobileVerify.client_id!, params: params)
        let urlRequest = try? req.urlRequest(relativeTo: url, accessToken: "", actAsUserID: nil)
        let expected = "client_id=1&response_type=code&redirect_uri=https://canvas/login&mobile=1"
        XCTAssertEqual(urlRequest?.url?.query, expected)
    }

    func testQueryItemsWithForceLogin() {
        params.method = .canvasLogin
        let req = LoginWebRequest(clientID: mobileVerify.client_id!, params: params)
        let urlRequest = try? req.urlRequest(relativeTo: url, accessToken: "", actAsUserID: nil)
        let expected = "client_id=1&response_type=code&redirect_uri=https://canvas/login&mobile=1&canvas_login=1"
        XCTAssertEqual(urlRequest?.url?.query, expected)
    }

    func testQueryItemsWithAuthenticationProvider() {
        params.authenticationProvider = "foo"
        let req = LoginWebRequest(clientID: mobileVerify.client_id!, params: params)
        let urlRequest = try? req.urlRequest(relativeTo: url, accessToken: "", actAsUserID: nil)
        let expected = "client_id=1&response_type=code&redirect_uri=https://canvas/login&mobile=1&authentication_provider=foo"
        XCTAssertEqual(urlRequest?.url?.query, expected)
    }
}
