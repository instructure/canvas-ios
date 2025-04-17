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

final class GradeFilterInteractorLiveTests: CoreTestCase {

    // MARK: - Properties
    private var testee: GradeFilterInteractorLive!
    private let courseId = "10"

    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
        testee = GradeFilterInteractorLive(
            appEnvironment: environment,
            courseId: courseId
        )
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func test_gradingShowAllId() {
        XCTAssertEqual(testee.gradingShowAllId, "-1")
    }

    func test_saveSortByOptionForFirstTime() {
        // Given
        environment.userDefaults?.selectedSortByOptionIDs = nil
        // When
        testee.saveSortByOption(type: .groupName)
        // Then
        XCTAssertEqual(testee.selectedSortById, "groupName")
    }

    func test_saveSortByOptionChangeValue() {
        // Given
        let oldId = "groupName"
        let newId = "dueDate"
        environment.userDefaults?.selectedSortByOptionIDs = [courseId: oldId]
        // When
        testee.saveSortByOption(type: .dueDate)
        // Then
        XCTAssertEqual(testee.selectedSortById, newId)
    }

    func test_isParentApp() {
        // Given
        environment.app = .parent
        // Then
        XCTAssertTrue(testee.isParentApp)
    }
}
