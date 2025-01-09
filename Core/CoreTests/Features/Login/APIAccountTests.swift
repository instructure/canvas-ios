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

import XCTest
@testable import Core

class APIAccountResultTests: XCTestCase {
    let decoder = JSONDecoder()

    func testInitFromDecoder() throws {
        var json: [String: Any?] = [
            "domain": "scoe.instructure.com",
            "name": "SCOE",
            "authentication_provider": "saml"
        ]
        var data = try JSONSerialization.data(withJSONObject: json, options: [])
        var result = try decoder.decode(APIAccountResult.self, from: data)
        XCTAssertEqual("scoe.instructure.com", result.domain)
        XCTAssertEqual("SCOE", result.name)
        XCTAssertEqual("saml", result.authentication_provider)

        json["authentication_provider"] = ""
        data = try JSONSerialization.data(withJSONObject: json, options: [])
        result = try decoder.decode(APIAccountResult.self, from: data)
        XCTAssertNil(result.authentication_provider)

        json["authentication_provider"] = "Null"
        data = try JSONSerialization.data(withJSONObject: json, options: [])
        result = try decoder.decode(APIAccountResult.self, from: data)
        XCTAssertNil(result.authentication_provider)

        json["authentication_provider"] = nil
        data = try JSONSerialization.data(withJSONObject: json, options: [])
        result = try decoder.decode(APIAccountResult.self, from: data)
        XCTAssertNil(result.authentication_provider)

        json["name"] = "   so much whitespace\n  "
        data = try JSONSerialization.data(withJSONObject: json, options: [])
        result = try decoder.decode(APIAccountResult.self, from: data)
        XCTAssertEqual("so much whitespace", result.name)
    }

    func testGetAccountsSearchRequest() {
        XCTAssertEqual(GetAccountsSearchRequest(searchTerm: "").path, "https://canvas.instructure.com/api/v1/accounts/search")
        XCTAssertEqual(GetAccountsSearchRequest(searchTerm: "abcd").queryItems, [
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "search_term", value: "abcd")
        ])
        XCTAssertEqual(GetAccountsSearchRequest(searchTerm: "").headers, [
            HttpHeader.authorization: nil
        ])
    }
}
