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

class GetDiscussionTopicsRequestTests: XCTestCase {
    func testPath() {
        let request = GetDiscussionTopicsRequest(context: .course("1"))
        XCTAssertEqual(request.path, "courses/1/discussion_topics")
    }

    func testQuery() {
        let request = GetDiscussionTopicsRequest(context: .course("1"), perPage: 25, include: [.allDates, .overrides, .sections, .sectionsUserCount])
        XCTAssertEqual(request.queryItems, [
            URLQueryItem(name: "per_page", value: "25"),
            URLQueryItem(name: "include[]", value: "all_dates"),
            URLQueryItem(name: "include[]", value: "overrides"),
            URLQueryItem(name: "include[]", value: "sections"),
            URLQueryItem(name: "include[]", value: "section_user_count")
        ])
    }
}
