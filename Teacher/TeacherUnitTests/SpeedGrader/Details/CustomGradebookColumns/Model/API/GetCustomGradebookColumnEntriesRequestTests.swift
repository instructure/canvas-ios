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
@testable import Teacher

class GetCustomGradebookColumnEntriesRequestTests: XCTestCase {

    private static let testData = (
        courseId: "some courseId",
        columnId: "some columnId"
    )
    private lazy var testData = Self.testData

    func test_properties() {
        let testee = GetCustomGradebookColumnEntriesRequest(
            courseId: testData.courseId,
            columnId: testData.columnId
        )

        XCTAssertEqual(testee.method, .get)
        XCTAssertEqual(testee.path, "courses/\(testData.courseId)/custom_gradebook_columns/\(testData.columnId)/data")
        XCTAssertEqual(testee.courseId, testData.courseId)
        XCTAssertEqual(testee.columnId, testData.columnId)
    }
}
