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

class GetAuthTokenTests: XCTestCase {
    var session = URLSessionAPI(urlSession: URLSession.mockSession())
    var api: GetAuthToken!
    var code = "code"
    let clientID = "client_id"
    let clientSecret = "secret"
    let mobileVerify = APIVerifyClient(authorized: true, base_url: nil, client_id: "client_id", client_secret: "secret")
    let token = "token"

    override func setUp() {
        super.setUp()
        session = URLSessionAPI(urlSession: URLSession.mockSession())
        api = GetAuthToken(api: session, mobileVerify: mobileVerify, code: code)
    }

    func testGetMobileVerify() {
        let user = APIOAuthUser(id: "1", name: "john", effective_locale: "en", email: "email@email.com")
        let expected = APIOAuthToken(access_token: token, refresh_token: nil, token_type: "Bearer", user: user, expires_in: 10)
        let responseData: [String: Any] = [
            "access_token": token,
            "token_type": "Bearer",
            "user": [ "name": "john", "id": "1", "effective_locale": "en", "email": "email@email.com" ],
            "expires_in": 10,
        ]

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))

        let expectation = XCTestExpectation(description: "expectation")
        var result: APIOAuthToken?
        api.completionBlock = { [weak self] in
            result = self?.api.response
            XCTAssertNil(self?.api.errors.first)
            expectation.fulfill()
        }
        api.start()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(result, expected)
    }

    func testGetMobileVerifyError() {
        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithFailure())

        let expectation = XCTestExpectation(description: "expectation")
        api.completionBlock = { [weak self] in
            XCTAssertNil(self?.api.response)
            XCTAssertNotNil(self?.api.errors.first)
            expectation.fulfill()
        }
        api.start()
        wait(for: [expectation], timeout: 0.1)
    }
}
