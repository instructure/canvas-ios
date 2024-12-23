//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
@testable import Core
import XCTest

private let encoder = JSONEncoder()
private let decoder = JSONDecoder()

class APIURLTests: CoreTestCase {
    func testCodableValid() throws {
        XCTAssertEqual(
            try decoder.decode(APIURL.self, from: try encoder.encode("s://a.co")),
            .make(rawValue: URL(string: "s://a.co")!)
        )
        XCTAssertEqual(
            try decoder.decode(APIURL.self, from: try encoder.encode("s://a.co/foo{ }`|\\^")),
            .make(rawValue: URL(string: "s://a.co/foo%7B%20%7D%60%7C%5C%5E")!)
        )
        XCTAssertEqual(
            try decoder.decode(APIURL.self, from: try encoder.encode("s://a.co/~")),
            .make(rawValue: URL(string: "s://a.co/~")!)
        )
        XCTAssertEqual(
            try decoder.decode(APIURL.self, from: try encoder.encode("/relative/url")),
            APIURL(rawValue: URL(string: "/relative/url", relativeTo: currentSession.baseURL))
        )
        XCTAssertThrowsError(try decoder.decode(APIURL.self, from: try encoder.encode("")))
        XCTAssertThrowsError(try decoder.decode(APIURL.self, from: try encoder.encode(1)))
        XCTAssertThrowsError(try decoder.decode(APIURL.self, from: try encoder.encode(true)))
    }

    func testDecodeURLIfPresent() throws {
        var json: [String: Any?] = ["maybeURL": ""]
        var data = try JSONSerialization.data(withJSONObject: json, options: [])
        var model = try decoder.decode(TestCodable.self, from: data)
        XCTAssertNil(model.maybeURL)

        json["maybeURL"] = "https://canvas.instructure.com"
        data = try JSONSerialization.data(withJSONObject: json, options: [])
        model = try decoder.decode(TestCodable.self, from: data)
        XCTAssertEqual(model.maybeURL?.rawValue, URL(string: "https://canvas.instructure.com")!)

        json["maybeURL"] = nil
        data = try JSONSerialization.data(withJSONObject: json, options: [])
        model = try decoder.decode(TestCodable.self, from: data)
        XCTAssertNil(model.maybeURL)
    }

    func testDecodeWithXMLEscapedString() throws {
        let json: [String: Any?] = ["maybeURL": "https://learningmate.com/api/ltilaunch?custom_productId=bc1bc5be&amp;custom_resourceid=a6936184&amp;type=a5a3abc0"]
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let model = try decoder.decode(TestCodable.self, from: data)
        XCTAssertEqual(model.maybeURL?.rawValue, URL(string: "https://learningmate.com/api/ltilaunch?custom_productId=bc1bc5be&custom_resourceid=a6936184&type=a5a3abc0")!)
    }
}

private class TestCodable: Codable {
    let maybeURL: APIURL?

    enum CodingKeys: String, CodingKey {
        case maybeURL
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maybeURL = try container.decodeURLIfPresent(forKey: .maybeURL)
    }
}
