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

final class CDHProgramRequirementTests: CoreTestCase {
    func testSave() {
        // Given
        let dependenModel = ProgramStubs.dependen
        let dependencyModel = ProgramStubs.dependency
        let courseEnrollmentID = "courseEnrollment-ID"

        let apiEntity = GetHProgramsResponse.Requirement(
            id: "Requirement-ID",
            isCompletionRequired: true,
            courseEnrollment: courseEnrollmentID,
            position: 10,
            dependency: dependencyModel,
            dependent: dependenModel
        )
        // When
        let savedEntity = CDHProgramRequirement.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, "Requirement-ID")
        XCTAssertEqual(savedEntity.courseEnrollment, courseEnrollmentID)
        XCTAssertEqual(savedEntity.isCompletionRequired, true)
        XCTAssertEqual(savedEntity.position, 10)
        XCTAssertEqual(savedEntity.dependent?.id, "Dependen-ID")
        XCTAssertEqual(savedEntity.dependency?.id, "Dependency-ID")
    }

    func testSaveWithNilValues() {
        // Given
        let courseEnrollmentID = "courseEnrollment-ID"
        let apiEntity = GetHProgramsResponse.Requirement(
            id: "Requirement-ID",
            isCompletionRequired: true,
            courseEnrollment: courseEnrollmentID,
            dependency: nil,
            dependent: nil
        )
        // When
        let savedEntity = CDHProgramRequirement.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertNil(savedEntity.dependent)
        XCTAssertNil(savedEntity.dependency)
        XCTAssertEqual(savedEntity.position, 0)
    }
}
