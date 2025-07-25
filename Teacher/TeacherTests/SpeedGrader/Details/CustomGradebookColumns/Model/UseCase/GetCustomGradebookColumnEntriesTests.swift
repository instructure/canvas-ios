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

class GetCustomGradebookColumnEntriesTests: TeacherTestCase {

    private static let testData = (
        courseId: "some courseId",
        columnId: "some columnId"
    )
    private lazy var testData = Self.testData

    private var testee: GetCustomGradebookColumnEntries!

    override func setUp() {
        super.setUp()

        testee = .init(
            courseId: testData.courseId,
            columnId: testData.columnId
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func test_properties() {
        XCTAssertEqual(testee.cacheKey, "courses/\(testData.courseId)/custom_gradebook_columns/\(testData.columnId)/data")
        XCTAssertEqual(testee.request.courseId, testData.courseId)
        XCTAssertEqual(testee.request.columnId, testData.columnId)
    }

    func test_scope() {
        CDCustomGradebookColumnEntry.save(
            .make(user_id: "1"),
            courseId: testData.courseId,
            columnId: testData.columnId,
            in: databaseClient
        )
        CDCustomGradebookColumnEntry.save(
            .make(user_id: "2"),
            courseId: testData.courseId,
            columnId: testData.columnId,
            in: databaseClient
        )
        CDCustomGradebookColumnEntry.save(
            .make(user_id: "3"),
            courseId: testData.courseId,
            columnId: "another columnId",
            in: databaseClient
        )
        CDCustomGradebookColumnEntry.save(
            .make(user_id: "4"),
            courseId: "another courseId",
            columnId: testData.columnId,
            in: databaseClient
        )

        let entries: [CDCustomGradebookColumnEntry] = databaseClient.fetch(testee.scope.predicate)
            .sorted { $0.userId < $1.userId }

        XCTAssertEqual(entries.count, 2)
        XCTAssertEqual(entries.first?.userId, "1")
        XCTAssertEqual(entries.last?.userId, "2")
    }

    func test_write() throws {
        let entries: [APICustomGradebookColumnEntry] = [
            .make(user_id: "0"),
            .make(user_id: "1"),
            .make(user_id: "2")
        ]
        testee.write(response: entries, urlResponse: nil, to: databaseClient)

        let models: [CDCustomGradebookColumnEntry] = databaseClient.fetch()
            .sorted { $0.userId < $1.userId }

        guard models.count == 3 else { throw InvalidCountError() }
        XCTAssertEqual(models[0].userId, "0")
        XCTAssertEqual(models[1].userId, "1")
        XCTAssertEqual(models[2].userId, "2")
    }
}
