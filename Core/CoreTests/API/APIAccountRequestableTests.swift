//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

class APIAccountRequestableTests: XCTestCase {
    func testGetAccountsSearchRequest() {
        XCTAssertEqual(GetAccountsSearchRequest(searchTerm: "").path, "https://canvas.instructure.com/api/v1/accounts/search")
        XCTAssertEqual(GetAccountsSearchRequest(searchTerm: "abcd").query, [
            APIQueryItem.value("per_page", "50"),
            APIQueryItem.value("search_term", "abcd"),
        ])
        XCTAssertEqual(GetAccountsSearchRequest(searchTerm: "").headers, [
            HttpHeader.authorization: nil,
        ])
    }
}
