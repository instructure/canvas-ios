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
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "search_term", value: "abcd")
        ])
        XCTAssertEqual(GetAccountsSearchRequest(searchTerm: "").headers, [
            HttpHeader.authorization: nil
        ])
    }

    func testAccountResultsQueryBasedSorting() {
        let results: [APIAccountResult] = [
            .make(name: "Boston University", domain: "bu.edu"),
            .make(name: "Harvard University", domain: "harvard.edu"),
            .make(name: "Boston College", domain: "bc.edu"),
            .make(name: "MIT", domain: "mit.edu"),
            .make(name: "boston medical center", domain: "bmc.org")
        ]

        let sorted = results.sortedPromotingQueryPrefixed("boston")

        XCTAssertEqual(sorted[0].name, "Boston University")
        XCTAssertEqual(sorted[1].name, "Boston College")
        XCTAssertEqual(sorted[2].name, "boston medical center")
        XCTAssertEqual(sorted[3].name, "Harvard University")
        XCTAssertEqual(sorted[4].name, "MIT")

        let sortedUppercase = results.sortedPromotingQueryPrefixed("BOSTON")
        XCTAssertEqual(sortedUppercase, sorted)

        let sortedNoMatches = results.sortedPromotingQueryPrefixed("yale")
        XCTAssertEqual(sortedNoMatches, results)

        let sortedEmpty = results.sortedPromotingQueryPrefixed("")
        XCTAssertEqual(sortedEmpty, results)
    }
}
