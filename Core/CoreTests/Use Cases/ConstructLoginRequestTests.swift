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

class ConstructLoginRequestTests: XCTestCase {

    var params = LoginParams(host: "https://localhost", authenticationProvider: "", method: AuthenticationMethod.defaultMethod)
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
        params = LoginParams(host: host, authenticationProvider: "", method: AuthenticationMethod.defaultMethod)
        op = ConstructLoginRequest(params: params, urlSession: session)
        let responseData = try? JSONEncoder().encode(mobileVerify)
        let expectedRequest = try? LoginWebRequest(clientID: mobileVerify.client_id, params: params).urlRequest(relativeTo: URL(string: host)!, accessToken: "")

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
