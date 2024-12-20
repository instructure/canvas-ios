//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class APIPairingCodeTests: CoreTestCase {
    func testPostObserverPairingCodes() {
        let r = PostObserverPairingCodes()
        XCTAssertEqual(r.path, "users/self/observer_pairing_codes")
        XCTAssertEqual(r.method, .post)
    }

    func testObject() {
        let model = APIPairingCode.make()
        XCTAssertEqual(model.code, "code")
    }
}

class PostAccountUserRequestTests: CoreTestCase {
    let accountID = "1"
    let email = "john@doe.com"
    let password = "password"
    let firstAndLastName = "john doe"
    let code = "123"
    let baseURL: URL = URL(string: "https://localhost")!
    let currentLoggedInBaseURL =  URL(string: "https://twilson.instructure.com")!

    func testPostAccountUserRequest() {
        let r = PostAccountUserRequest(baseURL: baseURL, accountID: accountID, pairingCode: code, name: firstAndLastName, email: email, password: password)
        guard let req = try? r.urlRequest(relativeTo: currentLoggedInBaseURL, accessToken: "token", actAsUserID: nil) else {
            XCTFail("req nil")
            return
        }
        XCTAssertEqual(req.url?.host, baseURL.host)
        let authHeader: String? = req.allHTTPHeaderFields?[HttpHeader.authorization]
        XCTAssertNil(authHeader)
        XCTAssertEqual(r.path, "https://localhost/api/v1/accounts/1/users")
        XCTAssertEqual(r.method, .post)
        let body = PostAccountUserRequest.Body(
            pseudonym: PostAccountUserRequest.Body.Pseudonym(unique_id: email, password: password),
            pairing_code: PostAccountUserRequest.Body.PairingCode(code: code),
            user: PostAccountUserRequest.Body.User(name: firstAndLastName, initial_enrollment_type: "observer")
        )

        XCTAssertEqual(r.body, body)
    }

    func testUrlRequestConstruction() {
        let r = PostAccountUserRequest(baseURL: baseURL, accountID: accountID, pairingCode: code, name: firstAndLastName, email: email, password: password)
        XCTAssertEqual(r.method, .post)
        let expectedBody = PostAccountUserRequest.Body(
            pseudonym: PostAccountUserRequest.Body.Pseudonym(unique_id: email, password: password),
            pairing_code: PostAccountUserRequest.Body.PairingCode(code: code),
            user: PostAccountUserRequest.Body.User(name: firstAndLastName, initial_enrollment_type: "observer")
        )

        let expectedURL = URL(string: "https://localhost/api/v1/accounts/1/users")!
        let dummyURL = URL(string: "https://foo.instructure.com")!
        let request = try? r.urlRequest(relativeTo: dummyURL, accessToken: nil, actAsUserID: nil)
        XCTAssertEqual(request?.url?.host, baseURL.host)
        XCTAssertEqual(request?.url, expectedURL)
        XCTAssertEqual(request?.httpMethod, APIMethod.post.rawValue.uppercased())

        let decoder = JSONDecoder()
        let body = try? decoder.decode(PostAccountUserRequest.Body.self, from: request!.httpBody!)
        XCTAssertEqual(body, expectedBody)
    }
}
