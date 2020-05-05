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

class APIAccountTermsOfServiceTests: CoreTestCase {
    func testGetAccountTermsOfService() {
        let r = GetAccountTermsOfServiceRequest()
        XCTAssertEqual(r.path, "accounts/self/terms_of_service")
        XCTAssertEqual(r.method, .get)
    }

    func testObject() {
        let model = APIAccountTermsOfService.make()
        XCTAssertEqual(model.account_id, "1")
    }
}

class PostAccountUserRequestTests: CoreTestCase {
    func testPostAccountUserRequest() {
        let accountID = "1"
        let email = "john@doe.com"
        let password = "password"
        let name = "john doe"
        let code = "123"
        let r = PostAccountUserRequest(accountID: accountID, pairingCode: code, name: name, email: email, password: password)
        XCTAssertEqual(r.path, "accounts/\(accountID)/users")
        XCTAssertEqual(r.method, .post)
        let body = PostAccountUserRequest.Body(
            pseudonym: PostAccountUserRequest.Body.Pseudonym(unique_id: email, password: password),
            pairing_code: PostAccountUserRequest.Body.PairingCode(code: code),
            user: PostAccountUserRequest.Body.User(name: name, initial_enrollment_type: "observer")
        )

        XCTAssertEqual(r.body, body)
    }
}
