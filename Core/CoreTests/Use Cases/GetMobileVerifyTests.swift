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
            XCTAssertNotNil(self?.api.errors.first)
            expectation.fulfill()
        }
        api.start()
        wait(for: [expectation], timeout: 0.1)
    }
}
