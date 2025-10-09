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

import XCTest
@testable import Core
import TestsFoundation

final class AssignmentListSectionTests: CoreTestCase {

    private static let testData = (
        sectionId: "some sectionId",
        row1Id: "some row1Id",
        row2Id: "some row2Id",
        row3Id: "some row3Id"
    )
    private lazy var testData = Self.testData

    func test_rowId() throws {
        let section = AssignmentListSection(id: testData.sectionId, title: "", rows: [
            .student(.make(id: testData.row1Id)),
            .teacher(.make(id: testData.row2Id)),
            .gradeListRow(.make(id: testData.row3Id))
        ])

        guard section.rows.count == 3 else { throw InvalidCountError() }
        XCTAssertEqual(section.rows[0].id, testData.row1Id)
        XCTAssertEqual(section.rows[1].id, testData.row2Id)
        XCTAssertEqual(section.rows[2].id, testData.row3Id)
    }
}
