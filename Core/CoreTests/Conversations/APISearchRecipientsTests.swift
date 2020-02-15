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
        let context = ContextModel(.course, id: "2")
        XCTAssertEqual(GetSearchRecipientsRequest(context: context).path, "search/recipients")
        XCTAssertEqual(GetSearchRecipientsRequest(context: context).query, [
            .value("per_page", "50"),
            .value("context", "course_2"),
            .value("search", ""),
            .value("synthetic_contexts", "1"),
            .value("type", "user"),
        ])
        XCTAssertEqual(GetSearchRecipientsRequest(context: context, qualifier: .teachers, search: "q", userID: "5", skipVisibilityChecks: true, includeContexts: true, perPage: 10).query, [
            .value("per_page", "10"),
            .value("context", "course_2_teachers"),
            .value("search", "q"),
            .value("synthetic_contexts", "1"),
            .value("user_id", "5"),
            .value("skip_visibility_checks", "1"),
        ])
    }
}
