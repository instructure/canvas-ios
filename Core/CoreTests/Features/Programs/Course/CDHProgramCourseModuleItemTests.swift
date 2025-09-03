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

final class CDHProgramCourseModuleItemTests: CoreTestCase {
    func testSave() {
        // Given
        let courseID = "477"
        let programID = "programID-10"
        let apiEntity = GetHProgramCourseResponse.ModuleItem(
            published: true,
            id: "ID-1",
            estimatedDuration: "20PT"
        )
        // When
        let savedEntity = CDHProgramCourseModuleItem.save(
                apiEntity,
                courseID: courseID,
                programID: programID,
                in: databaseClient
            )
        // Then
        XCTAssertEqual(savedEntity.courseID, courseID)
        XCTAssertEqual(savedEntity.programID, programID)
        XCTAssertEqual(savedEntity.estimatedDuration, "20PT")
        XCTAssertEqual(savedEntity.id, "ID-1")
    }

    func testSaveWithUnPublishedItem() {
        // Given
        let courseID = "477"
        let programID = "programID-10"
        let apiEntity = GetHProgramCourseResponse.ModuleItem(
            published: false,
            id: "ID-1",
            estimatedDuration: "20PT"
        )
        // When
        let savedEntity = CDHProgramCourseModuleItem.save(
                apiEntity,
                courseID: courseID,
                programID: programID,
                in: databaseClient
            )
        // Then
        XCTAssertNil(savedEntity.estimatedDuration)
    }
}
