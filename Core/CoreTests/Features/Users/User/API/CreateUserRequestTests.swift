//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

class CreateUserRequestTests: XCTestCase {
    func testCreateUserRequest() {
        let user = CreateUserRequest.Body.User(name: "name")
        let pseudonym = CreateUserRequest.Body.Pseudonym(unique_id: "user@gmail.com", password: "password")
        let body = CreateUserRequest.Body(user: user, pseudonym: pseudonym)
        let request = CreateUserRequest(accountID: "1", body: body)

        XCTAssertEqual(request.path, "accounts/1/users")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }
}
