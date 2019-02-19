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

class ConstructLoginRequestTests: XCTestCase {

    var params = LoginParams(host: "https://localhost", authenticationProvider: "", method: .normalLogin)
    var mobileVerify: APIVerifyClient = mobileVerifyDefault()
    var op: ConstructLoginRequest!
    var session = URLSession.mockSession()
    var host = "https://localhost"

    override func setUp() {
        super.setUp()
        session = URLSession.mockSession()
        MockURLProtocolSupport.responses.removeAll()
    }

    func testDefualtAuthenticationRequest() {
        params = LoginParams(host: host, authenticationProvider: "", method: .normalLogin)
        op = ConstructLoginRequest(params: params, urlSession: session)
        let responseData = try? JSONEncoder().encode(mobileVerify)
        let expectedRequest = try? LoginWebRequest(clientID: mobileVerify.client_id!, params: params).urlRequest(relativeTo: mobileVerify.base_url!, accessToken: nil, actAsUserID: nil)

        MockURLProtocolSupport.responses.append(MockURLProtocolSupport.responseWithStatusCode(200, responseData: responseData))

        let expectation = XCTestExpectation(description: "expectation")
        op.completionBlock = { [weak op] in
            XCTAssertNotNil(op?.request)
            XCTAssertEqual(op?.request, expectedRequest)
            expectation.fulfill()
        }
        op.start()
        wait(for: [expectation], timeout: 0.1)
    }
}

func mobileVerifyDefault(clientID: String = "1", url: String = "https://localhost") -> APIVerifyClient {
    return APIVerifyClient(authorized: true, base_url: URL(string: url)!, client_id: clientID, client_secret: nil)
}
