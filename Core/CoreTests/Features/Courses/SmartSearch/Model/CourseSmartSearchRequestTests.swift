//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import TestsFoundation
@testable import Core

class CourseSmartSearchRequestTests: CoreTestCase {

    func test_request_no_filter() {
        // Given
        let courseId = "course_1234"
        let searchWord = "Example Search Word"

        // When
        let request = CourseSmartSearchRequest(courseId: courseId, searchText: searchWord, filter: nil)

        // Then
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "/api/v1/courses/course_1234/smartsearch")
        XCTAssertEqual(request.query, [.value("q", searchWord), .perPage(50)])
    }

    func test_request_with_filter() {
        // Given
        let courseId = "course_1234"
        let searchWord = "Example Search Word"
        let includedTypes: [CourseSmartSearchResultType] = [.assignment, .page]

        // When
        let filter = includedTypes.map({ $0.filterValue })
        let request = CourseSmartSearchRequest(courseId: courseId, searchText: searchWord, filter: filter)

        // Then
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "/api/v1/courses/course_1234/smartsearch")
        XCTAssertEqual(request.query, [.value("q", searchWord), .perPage(50), .array("filter", filter)])
    }
}
