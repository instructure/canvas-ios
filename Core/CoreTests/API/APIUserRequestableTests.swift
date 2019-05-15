//
// Copyright (C) 2016-present Instructure, Inc.
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

class APIUserRequestableTests: XCTestCase {
    func testGetCustomColorsRequest() {
        XCTAssertEqual(GetCustomColorsRequest().path, "users/self/colors")
    }

    func testGetUserRequest() {
        XCTAssertEqual(GetUserRequest(userID: "2").path, "users/2")
    }

    func testCreateUserRequest() {
        let user = CreateUserRequest.Body.User(name: "name")
        let pseudonym = CreateUserRequest.Body.Pseudonym(unique_id: "user@gmail.com", password: "password")
        let body = CreateUserRequest.Body(user: user, pseudonym: pseudonym)
        let request = CreateUserRequest(accountID: "1", body: body)

        XCTAssertEqual(request.path, "accounts/1/users")
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.body, body)
    }

    func testUpdateCustomColorRequest() {
        let body = UpdateCustomColorRequest.Body(hexcode: "fffeee")
        let context = ContextModel(.course, id: "1")
        let request = UpdateCustomColorRequest(userID: "1", context: context, body: body)

        XCTAssertEqual(request.path, "users/1/colors/course_1")
        XCTAssertEqual(request.method, .put)
        XCTAssertEqual(request.body, body)
    }
}
