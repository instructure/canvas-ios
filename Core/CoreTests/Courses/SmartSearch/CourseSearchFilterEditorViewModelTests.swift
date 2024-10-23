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
@testable import Core

final class CourseSearchFilterEditorViewModelTests: CoreTestCase {

    func test_all_selection_tapped() throws {
        // Given
        let model = CourseSearchFilterEditorViewModel(filter: nil) { _ in }

        // Initially all should be selected
        XCTAssertTrue(model.resultTypes.allSatisfy({ $0.checked }))
        XCTAssertEqual(model.allSelectionMode, .deselect)

        // When - unchecking few of them
        model.resultTypes[0].checked = false
        model.resultTypes[2].checked = false

        // Then
        XCTAssertEqual(model.allSelectionMode, .select)

        // When
        model.allSelectionButtonTapped()

        // Then - select all
        XCTAssertTrue(model.resultTypes.allSatisfy({ $0.checked }))
        XCTAssertEqual(model.allSelectionMode, .deselect)

        // When
        model.allSelectionButtonTapped()

        // Then - unselect all
        XCTAssertTrue(model.resultTypes.allSatisfy({ $0.checked == false }))
        XCTAssertEqual(model.allSelectionMode, .select)
    }

    func test_filter_submission() throws {
        // Given
        var submitted: CourseSmartSearchFilter?
        let model = CourseSearchFilterEditorViewModel(filter: nil) {
            submitted = $0
        }

        // When - selecting only sort
        model.sortMode = .type
        model.submit()

        // Then
        var selected = try XCTUnwrap(submitted)
        XCTAssertEqual(selected.sortMode, .type)
        XCTAssertEqual(selected.includedTypes, CourseSmartSearchResultType.filterableTypes)

        // When - some filters
        model.allSelectionButtonTapped() // Uncheck all
        model.sortMode = .relevance
        model.resultTypes[0].checked = true
        model.resultTypes[1].checked = true
        model.submit()

        // Then
        selected = try XCTUnwrap(submitted)
        let expected = model.resultTypes.prefix(2).map({ $0.type })
        XCTAssertEqual(selected.sortMode, .relevance)
        XCTAssertEqual(selected.includedTypes, expected)
    }
}
