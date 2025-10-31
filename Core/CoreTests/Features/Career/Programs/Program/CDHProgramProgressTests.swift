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

final class CDHProgramProgressTests: CoreTestCase {
    func testSave() {
        // Given
        let id = "123"
        let status = "Blocked"
        let requirementModel = ProgramStubs.progressRequirement
        let apiEntity = GetHProgramsResponse.Progress(
            id: id,
            completionPercentage: 0.6,
            courseEnrollmentStatus: status,
            requirement: requirementModel
        )
        // When
        let savedEntity = CDHProgramProgress.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, id)
        XCTAssertEqual(savedEntity.completionPercentage, 0.6)
        XCTAssertEqual(savedEntity.courseEnrollmentStatus, status)
        XCTAssertEqual(savedEntity.canvasCourseId, "477")
    }

    func testSaveWithExistingEntity() {
        // Given
        let initialEntity: CDHProgramProgress = databaseClient.insert()
        initialEntity.id = "123"
        initialEntity.completionPercentage = 0.0
        initialEntity.courseEnrollmentStatus = "Blocked"
        initialEntity.canvasCourseId = "477"
        try! databaseClient.save()

        let id = "123"
        let status = "Enrolled"
        let progressID = "Progress-ID"
        let dependenModel = GetHProgramsResponse.Dependen(id: "Dependen-ID", canvasCourseID: "477", canvasURL: nil)
        let requirementModel = GetHProgramsResponse.ProgressRequirement(id: progressID, dependent: dependenModel)
        let apiEntity = GetHProgramsResponse.Progress(
            id: id,
            completionPercentage: 0.9,
            courseEnrollmentStatus: status,
            requirement: requirementModel
        )

        // When
        let savedEntity = CDHProgramProgress.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, id)
        XCTAssertEqual(savedEntity.completionPercentage, 0.9)
        XCTAssertEqual(savedEntity.courseEnrollmentStatus, status)
        XCTAssertEqual(savedEntity.canvasCourseId, "477")
    }
}
