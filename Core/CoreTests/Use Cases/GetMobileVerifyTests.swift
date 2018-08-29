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

class GetMobileVerifyTests: XCTestCase {
    var session = URLSessionAPI(urlSession: URLSession.mockSession())
    var api: GetMobileVerify!
    var host = "https://localhost"
    var url = URL(string: "https://localhost")!

    override func setUp() {
        super.setUp()
        session = URLSessionAPI(urlSession: URLSession.mockSession())
        api = GetMobileVerify(api: session, host: "twilson.instructure.com")
    }

    func testGetMobileVerify() {
        let expectedClientID = "100"
        let responseData: [String: Any] = [
            "authorized": true,
            "result": 0,
            "client_id": expectedClientID,
            "api_key": "key",
            "client_secret": "secret",
            "base_url": host,
            ]

        let expected = APIVerifyClient(authorized: true, base_url: url, client_id: expectedClientID, client_secret: "secret")

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))

        let expectation = XCTestExpectation(description: "expectation")
        var result: APIVerifyClient?
        api.completionBlock = { [weak self] in
            result = self?.api.response
            expectation.fulfill()
        }
        api.start()

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(result, expected)
    }

    func skip_testGetMobileVerifyWhileProtectionInJson() {
        let expectedClientID = "100"
        let jsonData = """
        while(1);{"authorized": true,
        "result": 0,
        "client_id": "\(expectedClientID)",
        "api_key": "key",
        "client_secret": "secret",
        "base_url": \(host)
        }
        """
        let responseData = jsonData.data(using: .utf8)

        let expected = APIVerifyClient(authorized: true, base_url: url, client_id: expectedClientID, client_secret: "secret")

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))

        let expectation = XCTestExpectation(description: "expectation")
        var result: APIVerifyClient?
        api.completionBlock = { [weak self] in
            result = self?.api.response
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
