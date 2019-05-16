//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
