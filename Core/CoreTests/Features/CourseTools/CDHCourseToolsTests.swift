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

final class CDHCourseToolsTests: CoreTestCase {
    func testSave() {
        // Given
        let navigation = CourseNavigationTool.CourseNavigation(
            text: "",
            url: URL(string: "https://example.com"),
            label: "Basic Canvas",
            icon_url: URL(string: "https://icon.com")
        )
        let apiEntity = CourseNavigationTool(
            id: "12",
            context_name: "context_name",
            context_id: "Course_123",
            course_navigation: navigation,
            name: "Basic Canvas",
            url: URL(string: "https://example.com")
        )
        // When
        let savedEntity =  CDHCourseTools.save(apiEntity: apiEntity, courseContextsCodes: "Course_123", in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, "12")
        XCTAssertEqual(savedEntity.name, "Basic Canvas")
        XCTAssertEqual(savedEntity.url, URL(string: "https://example.com"))
        XCTAssertEqual(savedEntity.iconURL, URL(string: "https://icon.com"))
        XCTAssertEqual(savedEntity.courseContextsCodes, "Course_123")
    }
}
