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

class APIExternalToolTests: XCTestCase {
    func testGetSessionlessLaunchURL() {
        let request = GetSessionlessLaunchURLRequest(
            context: .course("1"),
            id: "2",
            url: URL(string: "https://google.com")!,
            assignmentID: "3",
            moduleItemID: "4",
            launchType: .module_item,
            resourceLinkLookupUUID: "5"
        )

        XCTAssertEqual(request.path, "courses/1/external_tools/sessionless_launch")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "id", value: "2"),
            URLQueryItem(name: "launch_type", value: "module_item"),
            URLQueryItem(name: "url", value: "https://google.com"),
            URLQueryItem(name: "assignment_id", value: "3"),
            URLQueryItem(name: "module_item_id", value: "4"),
            URLQueryItem(name: "resource_link_lookup_uuid", value: "5"),
        ])
    }

    func testGetExternalToolsRequest() {
        let request = GetExternalToolsRequest(context: .course("1"), includeParents: true, perPage: 100)
        XCTAssertEqual(request.path, "courses/1/external_tools")
        XCTAssertEqual(request.cacheKey, "course_1_external_tools")
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "include_parents", value: "true"),
        ])
    }
}
