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

final class CDHProgramTests: CoreTestCase {
    func testSave() {
        // Given
        let apiEntity = ProgramStubs.programsResponse
        // When
        let savedEntity = CDHProgram.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, ProgramStubs.programsResponse.id)
        XCTAssertEqual(savedEntity.name, ProgramStubs.programsResponse.name)
        XCTAssertEqual(savedEntity.programDescription, ProgramStubs.programsResponse.description)
        XCTAssertEqual(savedEntity.variant, ProgramStubs.programsResponse.variant)
        XCTAssertEqual(savedEntity.variant, ProgramStubs.programsResponse.variant)
        XCTAssertEqual(Int(truncating: savedEntity.courseCompletionCount ?? 0), ProgramStubs.programsResponse.courseCompletionCount)
        XCTAssertEqual(savedEntity.startDate, ProgramStubs.programsResponse.startDate)
        XCTAssertEqual(savedEntity.endDate, ProgramStubs.programsResponse.endDate)
        XCTAssertEqual(savedEntity.porgresses.count, 1)
        XCTAssertEqual(savedEntity.porgresses.count, 1)

    }

    func testSaveWithNilValues() {
        // Given
        let apiEntity = ProgramStubs.programsResponseWithNilValues
        // When
        let savedEntity = CDHProgram.save(apiEntity, in: databaseClient)
        // Then
        XCTAssertEqual(savedEntity.id, ProgramStubs.programsResponse.id)
        XCTAssertEqual(savedEntity.name, ProgramStubs.programsResponse.name)
        XCTAssertEqual(savedEntity.porgresses.count, 0)
        XCTAssertEqual(savedEntity.requirements.count, 0)
    }
}
