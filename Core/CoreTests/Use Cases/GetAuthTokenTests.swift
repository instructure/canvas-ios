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
        let expected = APIOAuthToken(access_token: token, token_type: "Bearer", user: APIOAuthToken.User(id: "1", name: "john"), expires_in: 10)
        let responseData: [String: Any] = [
            "access_token": token,
            "token_type": "Bearer",
            "user": ["name": "john", "id": "1" ],
            "expires_in": 10,
            ]

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))

        let expectation = XCTestExpectation(description: "expectation")
        var result: APIOAuthToken?
        api.completionBlock = { [weak self] in
            result = self?.api.response
            XCTAssertNil(self?.api.error)
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
            XCTAssertNotNil(self?.api.error)
            expectation.fulfill()
        }
        api.start()
        wait(for: [expectation], timeout: 0.1)
    }
}
