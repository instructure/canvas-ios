//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class APIUserTests: XCTestCase {

    func testDecoding() {
        let json = """
        {
            "id": "8765",
            "name": "Test Json",
            "sortable_name": "Json, Test",
            "short_name": "TJ",
            "login_id": "jstest01",
            "avatar_url": "https://instructure.com",
            "email": "testemail@test.com",
            "locale": "en-US",
            "effective_locale": "en-GB",
            "bio": "Short test description",
            "pronouns": "mr",
            "permissions": {
                "can_update_name": true,
                "can_update_avatar": true,
                "limit_parent_app_web_access": true
            },
            "enrollments": [
                {
                    "enrollment_state": "active",
                    "type": "test",
                    "user_id": "8765",
                    "role": "student",
                    "role_id": "1"
                }
            ]
        }
        """

        guard let testee = decode(json) else { return }
        XCTAssertEqual(testee.id, ID("8765"))
        XCTAssertEqual(testee.name, "Test Json")
        XCTAssertEqual(testee.sortable_name, "Json, Test")
        XCTAssertEqual(testee.short_name, "TJ")
        XCTAssertEqual(testee.login_id, "jstest01")
        XCTAssertEqual(testee.avatar_url, APIURL(rawValue: URL(string: "https://instructure.com")!))
        XCTAssertEqual(testee.email, "testemail@test.com")
        XCTAssertEqual(testee.locale, "en-US")
        XCTAssertEqual(testee.effective_locale, "en-GB")
        XCTAssertEqual(testee.bio, "Short test description")
        XCTAssertEqual(testee.pronouns, "mr")
        XCTAssertNotNil(testee.permissions)
        XCTAssertEqual(testee.enrollments?.count, 1)
    }

    func testMinimalJSONDecoding() {
        let json = """
        {
            "id": "8765",
            "name": "Test Json",
            "sortable_name": "Json, Test",
            "short_name": "TJ"
        }
        """

        XCTAssertNotNil(decode(json))
    }

    func testDecodingOnEmptyAvatarUrl() {
        let json = """
        {
            "id": "1234",
            "name": "Test Json",
            "sortable_name": "Json, Test",
            "short_name": "TJ",
            "avatar_url": ""
        }
        """

        guard let testee = decode(json) else { return }
        XCTAssertNil(testee.avatar_url)
    }

    private func decode(_ json: String) -> APIUser? {
        do {
            return try JSONDecoder().decode(APIUser.self, from: json.data(using: .utf8)!)
        } catch {
            XCTFail("APIUser decoding shouldn't raise an exception.")
        }

        return nil
    }
}
