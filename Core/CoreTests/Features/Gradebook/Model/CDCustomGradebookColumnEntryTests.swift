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

import Core
import CoreData
import Foundation
import XCTest

class CDCustomGradebookColumnEntryTests: CoreTestCase {

    private static let testData = (
        courseId: "some courseId",
        columnId: "some columnId",
        userId: "some userId",
        content: "some content"
    )
    private lazy var testData = Self.testData

    func test_save_shouldReturnModel() {
        let result = CDCustomGradebookColumnEntry.save(
            .make(
                user_id: testData.userId,
                content: testData.content
            ),
            courseId: testData.courseId,
            columnId: testData.columnId,
            in: databaseClient
        )

        XCTAssertEqual(result.courseId, testData.courseId)
        XCTAssertEqual(result.columnId, testData.columnId)
        XCTAssertEqual(result.userId, testData.userId)
        XCTAssertEqual(result.content, testData.content)
    }

    func test_save_shouldSetDefaultValues() {
        let result = CDCustomGradebookColumnEntry.save(.make(), courseId: "", columnId: "", in: databaseClient)

        XCTAssertEqual(result.content, "")
    }

    func test_save_shouldStoreModel() {
        CDCustomGradebookColumnEntry.save(
            .make(
                user_id: testData.userId,
                content: testData.content
            ),
            courseId: testData.courseId,
            columnId: testData.columnId,
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        let fetched: CDCustomGradebookColumnEntry? = databaseClient.fetch().first

        XCTAssertEqual(fetched?.courseId, testData.courseId)
        XCTAssertEqual(fetched?.columnId, testData.columnId)
        XCTAssertEqual(fetched?.userId, testData.userId)
        XCTAssertEqual(fetched?.content, testData.content)
    }

    func test_savePredicates() {
        CDCustomGradebookColumnEntry.save(
            .make(user_id: testData.userId),
            courseId: testData.courseId,
            columnId: testData.columnId,
            in: databaseClient
        )
        CDCustomGradebookColumnEntry.save(
            .make(user_id: "another user"),
            courseId: testData.courseId,
            columnId: testData.columnId,
            in: databaseClient
        )
        CDCustomGradebookColumnEntry.save(
            .make(user_id: testData.userId),
            courseId: "another course",
            columnId: testData.columnId,
            in: databaseClient
        )
        CDCustomGradebookColumnEntry.save(
            .make(user_id: testData.userId),
            courseId: testData.courseId,
            columnId: "another column",
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        CDCustomGradebookColumnEntry.save(
            .make(user_id: testData.userId, content: "updated content"),
            courseId: testData.courseId,
            columnId: testData.columnId,
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        var fetched = fetch(userId: testData.userId, courseId: testData.courseId, columnId: testData.columnId)
        XCTAssertEqual(fetched?.content, "updated content")
        fetched = fetch(userId: "another user", courseId: testData.courseId, columnId: testData.columnId)
        XCTAssertEqual(fetched?.content, "")
        fetched = fetch(userId: testData.userId, courseId: "another course", columnId: testData.columnId)
        XCTAssertEqual(fetched?.content, "")
        fetched = fetch(userId: testData.userId, courseId: testData.courseId, columnId: "another column")
        XCTAssertEqual(fetched?.content, "")
    }

    private func fetch(userId: String, courseId: String, columnId: String) -> CDCustomGradebookColumnEntry? {
        let predicate = NSPredicate(key: #keyPath(CDCustomGradebookColumnEntry.courseId), equals: courseId)
            .and(NSPredicate(key: #keyPath(CDCustomGradebookColumnEntry.columnId), equals: columnId))
            .and(NSPredicate(key: #keyPath(CDCustomGradebookColumnEntry.userId), equals: userId))
        return databaseClient.fetch(predicate).first
    }
}
