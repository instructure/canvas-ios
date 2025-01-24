//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class SafeURLTests: XCTestCase {
    private struct MockEnity: Codable, Equatable {
        @SafeURL public private(set) var url: URL?
    }

    // MARK: - Decoding

    func testDecodesMissingKey() {
        let decoded = decode("{}")
        XCTAssertNotNil(decoded)
        XCTAssertNil(decoded?.url)
    }

    func testDecodesMissingValue() {
        let decoded = decode("""
        {
            "url": null
        }
        """)
        XCTAssertNotNil(decoded)
        XCTAssertNil(decoded?.url)
    }

    func testDecodesEmptyStringValue() {
        let decoded = decode("""
        {
            "url": ""
        }
        """)
        XCTAssertNotNil(decoded)
        XCTAssertNil(decoded?.url)
    }

    func testDecodesValidURL() {
        let decoded = decode("""
        {
            "url": "https://instructure.com/courses/courseID?param=5"
        }
        """)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.url, URL(string: "https://instructure.com/courses/courseID?param=5")!)
    }

    func testDecodesInvalidURL() {
        let decoded = decode("""
        {
            "url": "https://instructure.com/courses/courseID?param={}"
        }
        """)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.url, URL(string: "https://instructure.com/courses/courseID?param=%7B%7D")!)
    }

    // MARK: - Encode

    func testEncodesMissingURL() {
        let mockEntity = MockEnity(url: nil)
        let json = encode(mockEntity)
        XCTAssertEqual(json, """
        {
          \"url\" : null
        }
        """)
    }

    func testEncodesValidURL() {
        let mockEntity = MockEnity(url: URL(string: "https://instructure.com/courses/courseID?param=%7B%7D")!)
        let json = encode(mockEntity)
        XCTAssertEqual(json, """
        {
          \"url\" : \"https://instructure.com/courses/courseID?param=%7B%7D\"
        }
        """)
    }

    // MARK: - Helper Methods

    private func decode(_ json: String) -> MockEnity? {
        let jsonData = json.data(using: .utf8)!
        var decoded: MockEnity?

        do {
            decoded = try JSONDecoder().decode(MockEnity.self, from: jsonData)
        } catch(let error) {
            XCTFail("Decoding failed: \(error)")
        }

        return decoded
    }

    private func encode(_ entity: MockEnity) -> String? {
        var json: String?

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.withoutEscapingSlashes, .prettyPrinted]
            let data = try encoder.encode(entity)
            json = String(data: data, encoding: .utf8)
        } catch(let error) {
            XCTFail("Encoding failed: \(error)")
        }

        return json
    }
}
