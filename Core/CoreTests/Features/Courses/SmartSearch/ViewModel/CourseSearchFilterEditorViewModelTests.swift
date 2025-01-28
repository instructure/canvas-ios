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

import XCTest
import TestsFoundation
import SwiftUI
@testable import Core

final class CourseSearchFilterEditorViewModelTests: CoreTestCase {

    private var selectedFilter: CourseSmartSearchFilter?

    override func setUp() {
        super.setUp()
        selectedFilter = nil
    }

    func selectionBinding() -> Binding<CourseSmartSearchFilter?> {
        return Binding<CourseSmartSearchFilter?>(
            get: { [weak self] in
                self?.selectedFilter
            },
            set: { [weak self] newFilter in
                self?.selectedFilter = newFilter
            }
        )
    }

    func test_filter_submission() throws {
        // Given
        let model = CourseSearchFilterEditorViewModel(selection: selectionBinding(), accentColor: nil)

        // When - selecting only sort
        model.sortModeOptions.selected.send(.make(id: "type"))
        waitForMainAsync()

        // Then
        var selected = try XCTUnwrap(selectedFilter)
        XCTAssertEqual(selected.sortMode, .type)
        XCTAssertEqual(Set(selected.includedTypes), Set(CourseSmartSearchResultType.filterableTypes))

        // When - some filters
        model.sortModeOptions.selected.send(.make(id: "relevance"))
        model.resultTypeOptions.selected.send([.make(id: "Assignment"), .make(id: "Announcement")])
        waitForMainAsync()

        // Then
        selected = try XCTUnwrap(selectedFilter)
        let expected: [CourseSmartSearchResult.ContentType] = [.assignment, .announcement]
        XCTAssertEqual(selected.sortMode, .relevance)
        XCTAssertEqual(Set(selected.includedTypes), Set(expected))
    }
}
