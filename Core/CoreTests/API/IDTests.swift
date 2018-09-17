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

class IDTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testStringLiteral() {
        let foo: ID = "2"
        XCTAssertEqual(foo, "2")
    }

    func testIntLiteral() {
        let foo: ID = 2
        XCTAssertEqual(foo, "2")
        XCTAssertEqual(foo, 2)
    }

    func testDecodeFromInt() {
        let data = """
                    {
                    "access_token": "token",
                    "token_type": "Bearer",
                    "user": {
                        "id": 3,
                        "name": "student",
                        "global_id": "1"
                    },
                    "refresh_token": "refresh"
            }
            """.data(using: String.Encoding.utf8)!

        let token = try? JSONDecoder().decode(APIOAuthToken.self, from: data)
        XCTAssertEqual(token?.user.id, "3")
        XCTAssertEqual(token?.user.id, 3)
    }

    func testEncodeAndDecodeTogether() {
        let group = APIGroup.make(["id": "2"])
        let encoded = try! JSONEncoder().encode(group)
        let decoded = try! JSONDecoder().decode(APIGroup.self, from: encoded)
        XCTAssertEqual(decoded.id, "2")
        XCTAssertEqual(decoded.id.value, "2")
    }
}
