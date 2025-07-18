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

class CustomGradebookColumnsInteractorTests: TeacherTestCase {

    private static let testData = (
        courseId: "some courseId",
        column0: "colummn 0",
        column1: "colummn 1",
        column2: "colummn 2",
        column42: "colummn 42",
        userA: "user A",
        userB: "user B",
        userC: "user C",
        userX: "user X",
        title0: "title 0",
        title1: "title 1",
        title2: "title 2",
        content0A: "content 0A",
        content0B: "content 0B",
        content1B: "content 1B",
        content1C: "content 1C",
        content2C: "content 2C",
    )
    private lazy var testData = Self.testData

    private var testee: CustomGradebookColumnsInteractorLive!

    override func setUp() {
        super.setUp()

        setupAPIMocks()

        testee = .init(
            courseId: testData.courseId
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func test_properties() {
        XCTAssertEqual(testee.courseId, testData.courseId)
    }

    // MARK: - loadCustomColumnsData

    func test_loadCustomColumnsData_shouldLoadColumnsAndEntriesForCourseId() throws {
        XCTAssertFinish(testee.loadCustomColumnsData())

        // fetch columns
        let columns: [CDCustomGradebookColumn] = databaseClient.fetch()
            .sorted { $0.id < $1.id }

        // fetch entries
        let entries: [CDCustomGradebookColumnEntry] = databaseClient.fetch()
        let column0Entries = entries
            .filter { $0.columnId == testData.column0 }
            .sorted { $0.userId < $1.userId }
        let column1Entries = entries
            .filter { $0.columnId == testData.column1 }
            .sorted { $0.userId < $1.userId }
        let column2Entries = entries
            .filter { $0.columnId == testData.column2 }
            .sorted { $0.userId < $1.userId }

        // assert columns
        guard columns.count == 3 else { throw InvalidCountError() }
        XCTAssertEqual(columns[0].id, testData.column0)
        XCTAssertEqual(columns[1].id, testData.column1)
        XCTAssertEqual(columns[2].id, testData.column2)

        // assert entries
        XCTAssertEqual(entries.count, 5) // 2 + 2 + 1
        guard column0Entries.count == 2 else { throw InvalidCountError() }
        XCTAssertEqual(column0Entries[0].userId, testData.userA)
        XCTAssertEqual(column0Entries[1].userId, testData.userB)
        guard column1Entries.count == 2 else { throw InvalidCountError() }
        XCTAssertEqual(column1Entries[0].userId, testData.userB)
        XCTAssertEqual(column1Entries[1].userId, testData.userC)
        guard column2Entries.count == 1 else { throw InvalidCountError() }
        XCTAssertEqual(column2Entries[0].userId, testData.userC)
    }

    func test_loadCustomColumnsData_shouldIgnoreCache() throws {
        XCTAssertFinish(testee.loadCustomColumnsData())

        // reload with new responses
        api.mock(
            GetCustomGradebookColumnsRequest(courseId: testData.courseId),
            value: [
                .make(id: testData.column0),
                .make(id: testData.column42)
            ]
        )
        api.mock(
            GetCustomGradebookColumnEntriesRequest(courseId: testData.courseId, columnId: testData.column0),
            value: [.make(user_id: testData.userX)]
        )
        XCTAssertFinish(testee.loadCustomColumnsData())

        // new columns only
        let columns: [CDCustomGradebookColumn] = databaseClient.fetch()
            .sorted { $0.id < $1.id }
        guard columns.count == 2 else { throw InvalidCountError() }
        XCTAssertEqual(columns[0].id, testData.column0)
        XCTAssertEqual(columns[1].id, testData.column42)

        // new entries only in existing column
        let column0Entries: [CDCustomGradebookColumnEntry] = databaseClient.fetch()
            .filter { $0.columnId == testData.column0 }
        XCTAssertEqual(column0Entries.count, 1)
        XCTAssertEqual(column0Entries.first?.userId, testData.userX)
    }

    // MARK: - getCustomColumnEntries

    func test_getCustomColumnEntries() throws {
        XCTAssertFirstValue(testee.getCustomColumnEntries(columnId: testData.column0)) { [self] in
            let entries = $0.sorted { $0.userId < $1.userId }
            XCTAssertEqual(entries.count, 2)

            XCTAssertEqual(entries[0].courseId, testData.courseId)
            XCTAssertEqual(entries[0].columnId, testData.column0)
            XCTAssertEqual(entries[0].userId, testData.userA)

            XCTAssertEqual(entries[1].courseId, testData.courseId)
            XCTAssertEqual(entries[1].columnId, testData.column0)
            XCTAssertEqual(entries[1].userId, testData.userB)
        }
    }

    // MARK: - getStudentNotesEntries

    func test_getStudentNotesEntries() throws {
        XCTAssertFirstValue(testee.getStudentNotesEntries(userId: testData.userB)) { [self] in
            let entries = $0.sorted { $0.index < $1.index }
            XCTAssertEqual(entries.count, 1)

            XCTAssertEqual(entries[0].index, 0)
            XCTAssertEqual(entries[0].title, testData.title0)
            XCTAssertEqual(entries[0].content, testData.content0B) // not hidden AND teacher_notes
        }
    }

    // MARK: - Private helpers

    private func setupAPIMocks() {
        // columns
        api.mock(
            GetCustomGradebookColumnsRequest(courseId: testData.courseId),
            value: [
                .make(id: testData.column0, title: testData.title0, position: 0, hidden: false, teacher_notes: true),
                .make(id: testData.column1, title: testData.title1, position: 1, hidden: true, teacher_notes: true),
                .make(id: testData.column2, title: testData.title2, position: 2, hidden: false, teacher_notes: false)
            ]
        )
        api.mock(
            GetCustomGradebookColumnsRequest(courseId: "another courseId"),
            value: [.make(id: "another column")]
        )

        // column entries
        api.mock(
            GetCustomGradebookColumnEntriesRequest(courseId: testData.courseId, columnId: testData.column0),
            value: [
                .make(user_id: testData.userA, content: testData.content0A),
                .make(user_id: testData.userB, content: testData.content0B)
            ]
        )
        api.mock(
            GetCustomGradebookColumnEntriesRequest(courseId: testData.courseId, columnId: testData.column1),
            value: [
                .make(user_id: testData.userB, content: testData.content1B),
                .make(user_id: testData.userC, content: testData.content1C)
            ]
        )
        api.mock(
            GetCustomGradebookColumnEntriesRequest(courseId: testData.courseId, columnId: testData.column2),
            value: [
                .make(user_id: testData.userC, content: testData.content2C)
            ]
        )
        api.mock(
            GetCustomGradebookColumnEntriesRequest(courseId: testData.courseId, columnId: "another column"),
            value: [.make(user_id: "another user")]
        )
    }
}
