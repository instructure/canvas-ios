//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData
import XCTest
@testable import Core
@testable import Student
@testable import TestsFoundation

final class GetUnreadCourseAnnouncementCountsUseCaseTests: StudentTestCase {

    private var testee: GetUnreadCourseAnnouncementCountsUseCase!

    override func setUp() {
        super.setUp()
        testee = .init()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - cacheKey

    func test_cacheKey() {
        XCTAssertEqual(testee.cacheKey, "unread-course-announcement-counts")
    }

    // MARK: - write

    func test_write_whenResponseIsNil_shouldNotSaveEntities() {
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let entities: [CDUnreadCourseAnnouncementCount] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(entities.count, 0)
    }

    func test_write_shouldSaveOneEntityPerCourse() {
        testee.write(response: .make(courses: [
            .make(id: "c1"),
            .make(id: "c2")
        ]), urlResponse: nil, to: databaseClient)

        let entities: [CDUnreadCourseAnnouncementCount] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(entities.count, 2)
    }

    func test_write_shouldSaveCorrectUnreadCount() {
        testee.write(response: .make(courses: [
            .make(id: "c1", nodes: [
                .make(id: "a1", read: false),
                .make(id: "a2", read: true),
                .make(id: "a3", read: false)
            ])
        ]), urlResponse: nil, to: databaseClient)

        let entity = fetchEntity(courseId: "c1")
        XCTAssertEqual(entity?.unreadCount, 2)
    }

    func test_write_singleUnreadAnnouncementId() {
        testee.write(response: .make(courses: [
            .make(id: "c1", nodes: [.make(id: "a1", read: false)]),
            .make(id: "c2", nodes: [.make(id: "a2", read: false), .make(id: "a3", read: false)]),
            .make(id: "c3", nodes: [.make(id: "a4", read: true)])
        ]), urlResponse: nil, to: databaseClient)

        // WHEN single unread
        // THEN id is set
        XCTAssertEqual(fetchEntity(courseId: "c1")?.singleUnreadAnnouncementId, "a1")

        // WHEN multiple unread
        // THEN id is nil
        XCTAssertEqual(fetchEntity(courseId: "c2")?.singleUnreadAnnouncementId, nil)

        // WHEN no unread
        // THEN id is nil
        XCTAssertEqual(fetchEntity(courseId: "c3")?.singleUnreadAnnouncementId, nil)
    }

    // MARK: - Private helpers

    private func fetchEntity(courseId: String) -> CDUnreadCourseAnnouncementCount? {
        let entities: [CDUnreadCourseAnnouncementCount] = databaseClient.fetch(scope: .all)
        return entities.first { $0.courseId == courseId }
    }
}
