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

import Foundation
import XCTest
@testable import Core
@testable import Teacher
import TestsFoundation

class GetCustomGradebookColumnsTests: TeacherTestCase {

    private static let testData = (
        courseId: "some courseId",
        placeholder: ""
    )
    private lazy var testData = Self.testData

    private var testee: GetCustomGradebookColumns!

    override func setUp() {
        super.setUp()

        testee = .init(
            courseId: testData.courseId
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func test_properties() {
        XCTAssertEqual(testee.cacheKey, "courses/\(testData.courseId)/custom_gradebook_columns")
        XCTAssertEqual(testee.request.courseId, testData.courseId)
    }

    func test_scope() {
        CDCustomGradebookColumn.save(
            .make(id: "1"),
            courseId: testData.courseId,
            in: databaseClient
        )
        CDCustomGradebookColumn.save(
            .make(id: "2"),
            courseId: testData.courseId,
            in: databaseClient
        )
        CDCustomGradebookColumn.save(
            .make(id: "3"),
            courseId: "another courseId",
            in: databaseClient
        )

        let entries: [CDCustomGradebookColumn] = databaseClient.fetch(testee.scope.predicate)
            .sorted { $0.id < $1.id }

        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.first?.id, "1")
        XCTAssertEqual(entries.last?.id, "2")
    }

    func test_write() throws {
        let entries: [APICustomGradebookColumn] = [
            .make(id: "0"),
            .make(id: "1"),
            .make(id: "2")
        ]
        testee.write(response: entries, urlResponse: nil, to: databaseClient)

        let models: [CDCustomGradebookColumn] = databaseClient.fetch()
            .sorted { $0.id < $1.id }

        guard models.count == 3 else { throw InvalidCountError() }
        XCTAssertEqual(models[0].id, "0")
        XCTAssertEqual(models[1].id, "1")
        XCTAssertEqual(models[2].id, "2")
    }
}
