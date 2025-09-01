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

final class CDHProgramDependencyTests: CoreTestCase {
    func testSave() {
        // Given
        let apiEntity = ProgramStubs.dependency
        // When
        let savedEntity = CDHProgramDependency.save(apiEntity, requirementId: "requirementId", in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, "Dependency-ID")
        XCTAssertEqual(savedEntity.canvasCourseId, "477")
        XCTAssertEqual(savedEntity.requirementId, "requirementId")
    }

    func testSaveWithExistingEntity() {
        // Given
        let requirementId = "requirementId-012"
        let id = "Dependency-ID"
        let oldApiEntity = GetHProgramsResponse.Dependen(id: id, canvasCourseID: "477", canvasURL: nil)
        let newApiEntity = GetHProgramsResponse.Dependen(id: id, canvasCourseID: "520", canvasURL: nil)

        // When
        let initialEntity: CDHProgramDependency = databaseClient.insert()
        initialEntity.id = oldApiEntity.id ?? ""
        initialEntity.requirementId = requirementId
        initialEntity.canvasCourseId = oldApiEntity.canvasCourseID ?? ""
        try! databaseClient.save()
        let updatedEntity = CDHProgramDependency.save(newApiEntity, requirementId: requirementId, in: databaseClient)

        // Then
        XCTAssertEqual(updatedEntity.id, id)
        XCTAssertEqual(updatedEntity.canvasCourseId, "520")
        XCTAssertEqual(updatedEntity.requirementId, requirementId)
    }
}
