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
import TooLegit
import SoAutomated

class SessionUserTests: XCTestCase {
    func testCreateUser() {
        let user = SessionUser(id: "2", name: "John", loginID: nil, sortableName: "john", email: nil, avatarURL: nil)

        XCTAssertEqual("2", user.id)
        XCTAssertNil(user.loginID)
        XCTAssertEqual("John", user.name)
        XCTAssertEqual("john", user.sortableName)
        XCTAssertNil(user.email)
        XCTAssertNil(user.avatarURL)
    }

    func testCreateUserWithAvatarLoginIDAndEmail() {
        let avatarURL = URL(string: "http://ibm.com")!
        let user = SessionUser(id: "2", name: "Jane", loginID: "user", sortableName: "jane", email: "jane@user.com", avatarURL: avatarURL)

        XCTAssertEqual("2", user.id)
        XCTAssertEqual("user", user.loginID)
        XCTAssertEqual("Jane", user.name)
        XCTAssertEqual("jane", user.sortableName)
        XCTAssertEqual("jane@user.com", user.email)
        XCTAssertEqual("http://ibm.com", user.avatarURL?.absoluteString)
    }

    func testFromJSONSucceeds() {
        let json = [
            "id": "2",
            "name": "Anakin Skywalker",
            "sortable_name": "ani",
        ]
        let user = SessionUser.fromJSON(json)

        XCTAssertNotNil(user)
        XCTAssertEqual("2", user?.id)
        XCTAssertEqual("Anakin Skywalker", user?.name)
        XCTAssertEqual("ani", user?.sortableName)
    }

    func testJSONDictionary() {
        let user = SessionUser(id: "2", name: "Anakin Skywalker", loginID: "askywalker", sortableName: "ani", email: "vader@gmail.com", avatarURL: nil)
        let json = user.JSONDictionary()

        if let
            id = json["id"] as? String,
            let loginID = json["login_id"] as? String,
            let name = json["name"] as? String,
            let sortableName = json["sortable_name"] as? String,
            let email = json["primary_email"] as? String
        {
            XCTAssertEqual("2", id)
            XCTAssertEqual("askywalker", loginID)
            XCTAssertEqual("Anakin Skywalker", name)
            XCTAssertEqual("ani", sortableName)
            XCTAssertEqual("vader@gmail.com", email)
        } else {
            XCTFail("dictionary is incorrect")
            return
        }
    }

    func testSessionUser_getAvatarImage_whenAvatarURLIsNil_completesWithError() {
        let user = SessionUser(id: "1", name: "John", loginID: nil, sortableName: nil, email: nil, avatarURL: nil)
        let expectation = self.expectation(description: "get avatar image")
        user.getAvatarImage { image, error in
            XCTAssertNil(image)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSessionUser_getAvatarImage_whenAvatarURLIsNotNil_completesWithImage() {
        let user = SessionUser(id: "1", name: "John", loginID: nil, sortableName: nil, email: nil, avatarURL: URL.image)
        let expectation = self.expectation(description: "get avatar image")
        user.getAvatarImage { image, error in
            XCTAssertNotNil(image)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

}
