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

class CDCustomGradebookColumnTests: CoreTestCase {

    private static let testData = (
        courseId: "some courseId",
        columnId: "some columnId",
        title: "some title",
        position: 7
    )
    private lazy var testData = Self.testData

    func test_save_shouldReturnModel() {
        let result = CDCustomGradebookColumn.save(
            .make(
                id: testData.columnId,
                title: testData.title,
                position: testData.position,
                hidden: true,
                read_only: true,
                teacher_notes: true
            ),
            courseId: testData.courseId,
            in: databaseClient
        )

        XCTAssertEqual(result.courseId, testData.courseId)
        XCTAssertEqual(result.id, testData.columnId)
        XCTAssertEqual(result.title, testData.title)
        XCTAssertEqual(result.position, testData.position)
        XCTAssertEqual(result.isHidden, true)
        XCTAssertEqual(result.isReadOnly, true)
        XCTAssertEqual(result.isTeacherNotes, true)
    }

    func test_save_shouldSetDefaultValues() {
        let result = CDCustomGradebookColumn.save(.make(), courseId: "", in: databaseClient)

        XCTAssertEqual(result.position, -1)
        XCTAssertEqual(result.isHidden, false)
        XCTAssertEqual(result.isReadOnly, false)
        XCTAssertEqual(result.isTeacherNotes, false)
    }

    func test_save_shouldStoreModel() {
        CDCustomGradebookColumn.save(
            .make(
                id: testData.columnId,
                title: testData.title,
                position: testData.position,
                hidden: true,
                read_only: true,
                teacher_notes: true
            ),
            courseId: testData.courseId,
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        let fetched: CDCustomGradebookColumn? = databaseClient.fetch().first

        XCTAssertEqual(fetched?.courseId, testData.courseId)
        XCTAssertEqual(fetched?.id, testData.columnId)
        XCTAssertEqual(fetched?.title, testData.title)
        XCTAssertEqual(fetched?.position, testData.position)
        XCTAssertEqual(fetched?.isHidden, true)
        XCTAssertEqual(fetched?.isReadOnly, true)
        XCTAssertEqual(fetched?.isTeacherNotes, true)
    }

    func test_savePredicates() {
        // GIVEN multiple objects
        CDCustomGradebookColumn.save(
            .make(id: testData.columnId, position: 1),
            courseId: testData.courseId,
            in: databaseClient
        )
        CDCustomGradebookColumn.save(
            .make(id: "another column", position: 1),
            courseId: testData.courseId,
            in: databaseClient
        )
        CDCustomGradebookColumn.save(
            .make(id: testData.columnId, position: 1),
            courseId: "another course",
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        // WHEN changing position in one object
        CDCustomGradebookColumn.save(
            .make(id: testData.columnId, position: 7),
            courseId: testData.courseId,
            in: databaseClient
        )
        XCTAssertNoThrow(try databaseClient.save())

        // THEN update only that object
        var fetched = fetch(columnId: testData.columnId, courseId: testData.courseId)
        XCTAssertEqual(fetched?.position, 7)
        fetched = fetch(columnId: "another column", courseId: testData.courseId)
        XCTAssertEqual(fetched?.position, 1)
        fetched = fetch(columnId: testData.columnId, courseId: "another course")
        XCTAssertEqual(fetched?.position, 1)
    }

    private func fetch(columnId: String, courseId: String) -> CDCustomGradebookColumn? {
        let predicate = NSPredicate(key: #keyPath(CDCustomGradebookColumn.courseId), equals: courseId)
            .and(NSPredicate(key: #keyPath(CDCustomGradebookColumn.id), equals: columnId))
        return databaseClient.fetch(predicate).first
    }
}
