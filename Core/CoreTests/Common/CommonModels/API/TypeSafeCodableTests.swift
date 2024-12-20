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

class TypeSafeCodableTests: XCTestCase {
    private let type1JSON = """
        {
            "submissions": true
        }
    """
    private let type2JSON = """
        {
            "submissions": {
                "excused": "Nope"
            }
        }
    """
    private let type3JSON = """
        {
            "submissions": [
                "excused"
            ]
        }
    """

    func testType1Decode() {
        let testee = try? JSONDecoder().decode(TestDecodable.self, from: type1JSON.data(using: .utf8)!)
        XCTAssertEqual(testee?.submissions?.value1, true)
    }

    func testType2Decode() {
        let testee = try? JSONDecoder().decode(TestDecodable.self, from: type2JSON.data(using: .utf8)!)
        XCTAssertEqual(testee?.submissions?.value2?.excused, "Nope")
    }

    func testType3Decode() {
        let testee: TestDecodable?

        do {
            testee = try JSONDecoder().decode(TestDecodable.self, from: type3JSON.data(using: .utf8)!)
        } catch {
            XCTFail()
            return
        }

        XCTAssertNotNil(testee)
        XCTAssertNil(testee?.submissions?.value1)
        XCTAssertNil(testee?.submissions?.value2)
    }

    func testType1Encode() {
        let testee = TestDecodable(submissions: TypeSafeCodable<Bool, Type2Decodable>(value1: true, value2: nil))
        XCTAssertEqual(String(data: try JSONEncoder().encode(testee), encoding: .utf8), "{\"submissions\":true}")
    }

    func testType2Encode() {
        let testee = TestDecodable(submissions: TypeSafeCodable<Bool, Type2Decodable>(value1: nil, value2: Type2Decodable(excused: "yes")))
        XCTAssertEqual(String(data: try JSONEncoder().encode(testee), encoding: .utf8), "{\"submissions\":{\"excused\":\"yes\"}}")
    }

    func testNilEncode() {
        let testee = TestDecodable(submissions: TypeSafeCodable<Bool, Type2Decodable>(value1: nil, value2: nil))
        XCTAssertEqual(String(data: try JSONEncoder().encode(testee), encoding: .utf8), "{\"submissions\":null}")
    }
}

private struct TestDecodable: Codable, Equatable {
    public let submissions: TypeSafeCodable<Bool, Type2Decodable>?
}

private struct Type2Decodable: Codable, Equatable {
    public let excused: String
}
