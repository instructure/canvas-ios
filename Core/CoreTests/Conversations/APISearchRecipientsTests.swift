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

class APISearchRecipientsTests: XCTestCase {
    func testGetSearchRecipientsRequest() {
        let context = Context(.course, id: "2")
        XCTAssertEqual(GetSearchRecipientsRequest(context: context).path, "search/recipients")
        XCTAssertEqual(GetSearchRecipientsRequest(context: context).queryItems, [
            URLQueryItem(name: "per_page", value: "50"),
            URLQueryItem(name: "context", value: "course_2"),
            URLQueryItem(name: "search", value: ""),
            URLQueryItem(name: "synthetic_contexts", value: "1"),
            URLQueryItem(name: "type", value: "user")
        ])
        XCTAssertEqual(GetSearchRecipientsRequest(context: context, qualifier: .teachers, search: "q", userID: "5", skipVisibilityChecks: true, includeContexts: true, perPage: 10).queryItems, [
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "context", value: "course_2_teachers"),
            URLQueryItem(name: "search", value: "q"),
            URLQueryItem(name: "synthetic_contexts", value: "1"),
            URLQueryItem(name: "user_id", value: "5"),
            URLQueryItem(name: "skip_visibility_checks", value: "1")
        ])
    }
}
