//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class IDTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    func testStringLiteral() {
        let two: ID = "2"
        XCTAssertEqual(two, "2")
        XCTAssertEqual(two.description, two.value)
    }

    func testOtherStringLiterals() {
        XCTAssertEqual(ID(extendedGraphemeClusterLiteral: "❄︎"), "❄︎")
        XCTAssertEqual(ID(unicodeScalarLiteral: "ñ"), "ñ")
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
                        "global_id": "1",
                        "effective_locale": "en",
                        "email": "email@email.com"
                    },
                    "refresh_token": "refresh"
            }
            """.data(using: String.Encoding.utf8)!

        let token = try? JSONDecoder().decode(APIOAuthToken.self, from: data)
        XCTAssertEqual(token?.user.id, "3")
        XCTAssertEqual(token?.user.id, 3)
    }

    func testEncodeAndDecodeTogether() {
        let object = APIAssignment.make(id: "2")
        let encoded = try! JSONEncoder().encode(object)
        let decoded = try! JSONDecoder().decode(APIAssignment.self, from: encoded)
        XCTAssertEqual(decoded.id, "2")
        XCTAssertEqual(decoded.id.value, "2")
    }

    func testEncodeAndDecodeEmpty() {
        let object = APIAssignment.make(id: "")
        let encoded = try! JSONEncoder().encode(object)
        let decoded = try! JSONDecoder().decode(APIAssignment.self, from: encoded)
        XCTAssertEqual(decoded.id, "")
    }

    func testExpandTildeID() {
        XCTAssertEqual(ID.expandTildeID("1~1"), "10000000000001")
        XCTAssertEqual(ID.expandTildeID("123456789~123456789"), "1234567890000123456789")
        XCTAssertEqual(ID.expandTildeID("1~z"), "1~z")
        XCTAssertEqual(ID.expandTildeID("1~1~"), "1~1~")
        XCTAssertEqual(ID.expandTildeID("12"), "12")
        XCTAssertEqual(ID.expandTildeID("self"), "self")
        XCTAssertEqual(ID("1~1"), "10000000000001")
        XCTAssertEqual(ID("123456789~123456789"), "1234567890000123456789")
        XCTAssertEqual(ID("1~z"), "1~z")
        XCTAssertEqual(ID("1~1~"), "1~1~")
        XCTAssertEqual(ID("12"), "12")
        XCTAssertEqual(ID("self"), "self")
    }

    func testShardID() {
        XCTAssertEqual("70530000000002499".shardID, "7053")
        XCTAssertEqual("7053~1340206".shardID, "7053")
        XCTAssertNil("1340206".shardID)
    }

    func testHasShardID() {
        XCTAssertTrue("70530000000002499".hasShardID)
        XCTAssertTrue("7053~1340206".hasShardID)
        XCTAssertFalse("1340206".hasShardID)
    }

    func testLocalID() {
        XCTAssertEqual("70530000000002499".localID, "2499")
        XCTAssertEqual("7053~1340206".localID, "1340206")
        XCTAssertEqual("1340206".localID, "1340206")
    }
}
