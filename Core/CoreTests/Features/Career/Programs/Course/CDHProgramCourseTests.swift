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

final class CDHProgramCourseTests: CoreTestCase {
    func testSave() {
        // Given
        let programID = "123"
        let courseID = "1"
        let apiEntity = HProgramCourseStub.getProgramCourse()

        // When
        let savedEntity = CDHProgramCourse.save(
            apiEntity,
            programID: programID,
            in: databaseClient
        )
        let secondModule = savedEntity.moduleItems.first(where: { $0.id == "2" })

        // Then
        XCTAssertEqual(savedEntity.courseID, courseID)
        XCTAssertEqual(savedEntity.programID, programID)
        XCTAssertEqual(savedEntity.courseName, apiEntity.name)
        XCTAssertEqual(savedEntity.moduleItems.count, 4)
        XCTAssertNil(secondModule?.estimatedDuration)
    }
}
