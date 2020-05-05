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
        let r = PostAccountUserRequest(accountID: accountID, pairingCode: "123", name: "john doe", email: "john@doe.com", password: "password")
        XCTAssertEqual(r.path, "accounts/\(accountID)/users")
        XCTAssertEqual(r.method, .post)
        let url = try? r.urlRequest(relativeTo: URL(string: "https://foo.com")!, accessToken: nil, actAsUserID: nil)
        XCTAssertEqual(url?.url?.query, "user%5Binitial_enrollment_type%5D=observer&pairing_code%5Bcode%5D=123&user%5Bname%5D=john%20doe&pseudonym%5Bunique_id%5D=john@doe.com&pseudonym%5Bpassword%5D=password")
    }
}
