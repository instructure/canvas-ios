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

import CombineSchedulers
@testable import Core
@testable import Horizon
import XCTest

final class SkillCardsViewModelTests: HorizonTestCase {
    private var skillCardsInteractor: SkillCardsInteractorMocks!

    override func setUp() {
        super.setUp()
        skillCardsInteractor = SkillCardsInteractorMocks()
    }

    override func tearDown() {
        skillCardsInteractor = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitializationFetchesSkills() {
        // Given
        skillCardsInteractor.skillsToReturn = HSkillStubs.skills

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.skills.count, 5)
    }

    // MARK: - Success Cases

    func testFetchSkillsSuccessWithSkills() {
        // Given
        skillCardsInteractor.skillsToReturn = HSkillStubs.skills

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.skills.count, 5)
        XCTAssertEqual(testee.skills[0].id, "1")
        XCTAssertEqual(testee.skills[0].title, "Skill 1")
        XCTAssertEqual(testee.skills[0].status, "expert")
    }

    func testFetchSkillsSuccessWithEmptyResult() {
        // Given
        skillCardsInteractor.skillsToReturn = []

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .empty)
    }

    // MARK: - Error Cases

    func testFetchSkillsFailureShowsError() {
        // Given
        skillCardsInteractor.shouldFail = true

        // When
        let testee = createVM()

        // Then
        XCTAssertEqual(testee.state, .error)
    }

    // MARK: - Reload Tests

    func testGetSkillsWithIgnoreCacheTrue() {
        // Given
        let testee = createVM()

        // When
        testee.getSkills(ignoreCache: true)

        // Then
        XCTAssertEqual(skillCardsInteractor.lastIgnoreCache, true)
    }

    func testGetSkillsWithIgnoreCacheFalse() {
        // Given
        let testee = createVM()

        // When
        testee.getSkills(ignoreCache: false)

        // Then
        XCTAssertEqual(skillCardsInteractor.lastIgnoreCache, false)
    }

    // MARK: - Helper Methods

    private func createVM() -> SkillsHighlightsWidgetViewModel {
        SkillsHighlightsWidgetViewModel(
            interactor: skillCardsInteractor,
            scheduler: .immediate
        )
    }
}
