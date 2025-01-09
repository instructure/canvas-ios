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
import SwiftUI
@testable import Core

class CourseSmartSearchTests: CoreTestCase {

    func test_coloring() throws {
        let context = Context(.course, id: "124234")
        let attributes = CourseSmartSearchViewAttributes(context: context, color: .red)

        XCTAssertEqual(attributes.accentColor, .red)
    }

    func test_search_result_dots() {
        // Given
        var result: CourseSmartSearchResult = .make(distance: 0)

        // Then
        XCTAssertEqual(result.distanceDots, 4)
        XCTAssertEqual(result.strengthColor, Color.borderSuccess)

        // When
        result = .make(distance: 1)

        // Then
        XCTAssertEqual(result.distanceDots, 0)
        XCTAssertEqual(result.strengthColor, Color.borderWarning)

        // When
        result = .make(distance: 0.25)

        // Then
        XCTAssertEqual(result.distanceDots, 3)
        XCTAssertEqual(result.strengthColor, Color.borderSuccess)

        // When
        result = .make(distance: 0.60)

        // Then
        XCTAssertEqual(result.distanceDots, 2)
        XCTAssertEqual(result.strengthColor, Color.borderWarning)
    }
}

// MARK: Utils

extension CourseSmartSearchResult {

    static func make(distance: Double) -> CourseSmartSearchResult {
        return CourseSmartSearchResult(
            content_id: 32453,
            content_type: .page,
            readable_type: "Page",
            title: "Page Title",
            body: ".. Page Content ..",
            html_url: URL(string: "https://www.instructure.com/canvas"),
            distance: distance,
            relevance: 40
        )
    }
}
