//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Core
import XCTest

final class CourseToolsUseCaseTest: CoreTestCase {
    func testCacheKey() {
        // Given
        let context = ["Course_12"]
        // When
        let testee = CourseToolsUseCase(courseContextsCodes: context)
        // Then
        XCTAssertEqual(testee.cacheKey, "Course-Navigation-Tools-Course_12")
    }

    func testRequest() {
        // Given
        let context = ["Course_12"]
        // When
        let testee = CourseToolsUseCase(courseContextsCodes: context)
        // Then
        XCTAssertEqual(testee.request.query, GetCourseNavigationToolsRequest(courseContextsCodes: context).query)
    }

    func testWriteResponse() {
        // Given
        let context = ["Course_123"]
        let navigation = CourseNavigationTool.CourseNavigation(
            text: "",
            url: URL(string: "https://example.com"),
            label: "Basic Canvas",
            icon_url: URL(string: "https://icon.com")
        )
        let response = CourseNavigationTool(
            id: "12",
            context_name: "context_name",
            context_id: "Course_123",
            course_navigation: navigation,
            name: "Basic Canvas",
            url: URL(string: "https://example.com")
        )
        let testee = CourseToolsUseCase(courseContextsCodes: context)

        // When
        testee.write(response: [response], urlResponse: nil, to: databaseClient)
        let savedData: [CDHCourseTools] = databaseClient.fetch()
        // Then
        XCTAssertEqual(savedData.count, 1)
        XCTAssertEqual(savedData.first?.id, "12")
        XCTAssertEqual(savedData.first?.name, "Basic Canvas")
        XCTAssertEqual(savedData.first?.url, URL(string: "https://example.com"))
        XCTAssertEqual(savedData.first?.iconURL, URL(string: "https://icon.com"))
        XCTAssertEqual(savedData.first?.courseContextsCodes, "Course_123")
    }

    func testScope() {
        // Given
        let context = ["Course_123"]
        let testee = CourseToolsUseCase(courseContextsCodes: context)
        // When
        let predicate =  NSPredicate(format: "%K == %@", #keyPath(CDHCourseTools.courseContextsCodes), "Course_123")
        let expectedScope = Scope(predicate: predicate, order: [])
        // Then
        XCTAssertEqual(expectedScope, testee.scope)
    }
}
