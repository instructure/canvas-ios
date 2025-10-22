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

final class CDHSkillTests: CoreTestCase {
    func testSave() {
        // Given
        let apiEntity = SkillStubs.skillsResponse
        // When
        let savedEntity = CDHSkill.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, SkillStubs.skillsResponse.id)
        XCTAssertEqual(savedEntity.name, SkillStubs.skillsResponse.name)
        XCTAssertEqual(savedEntity.proficiencyLevel, SkillStubs.skillsResponse.proficiencyLevel)
    }

    func testSaveWithNilValues() {
        // Given
        let apiEntity = SkillStubs.skillsResponseWithNilValues
        // When
        let savedEntity = CDHSkill.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, SkillStubs.skillsResponseWithNilValues.id)
        XCTAssertEqual(savedEntity.name, "")
        XCTAssertEqual(savedEntity.proficiencyLevel, "")
    }
}
