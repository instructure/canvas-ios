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

import TestsFoundation
import XCTest
@testable import Core

final class CDUnreadCourseAnnouncementCountTests: CoreTestCase {

    // MARK: - removeAnnouncementId

    func test_removeAnnouncementId_shouldRemoveIdFromUnreadAnnouncementIds() {
        CDUnreadCourseAnnouncementCount.save(courseId: "c1", unreadAnnouncementIds: ["a1", "a2", "a3"], in: databaseClient)
        try? databaseClient.save()

        CDUnreadCourseAnnouncementCount.removeAnnouncementId("a1", courseId: "c1", database: environment.database)

        waitUntil(shouldFail: true) {
            let entity: CDUnreadCourseAnnouncementCount? = databaseClient.fetch(scope: .all).first { $0.courseId == "c1" }
            return entity?.unreadCount == 2
        }
    }

    func test_removeAnnouncementId_whenIdNotPresent_shouldBeIdempotent() {
        CDUnreadCourseAnnouncementCount.save(courseId: "c1", unreadAnnouncementIds: ["a1", "a2"], in: databaseClient)
        try? databaseClient.save()

        CDUnreadCourseAnnouncementCount.removeAnnouncementId("a3", courseId: "c1", database: environment.database)

        waitUntil(shouldFail: true) {
            let entity: CDUnreadCourseAnnouncementCount? = databaseClient.fetch(scope: .all).first { $0.courseId == "c1" }
            return entity?.unreadCount == 2
        }
    }

    func test_removeAnnouncementId_whenOnlyOneId_shouldClearSingleUnreadAnnouncementId() {
        CDUnreadCourseAnnouncementCount.save(courseId: "c1", unreadAnnouncementIds: ["a1"], in: databaseClient)
        try? databaseClient.save()

        CDUnreadCourseAnnouncementCount.removeAnnouncementId("a1", courseId: "c1", database: environment.database)

        waitUntil(shouldFail: true) {
            let entity: CDUnreadCourseAnnouncementCount? = databaseClient.fetch(scope: .all).first { $0.courseId == "c1" }
            return entity?.singleUnreadAnnouncementId == nil
        }
    }

    func test_removeAnnouncementId_whenEntityDoesNotExist_shouldDoNothing() {
        CDUnreadCourseAnnouncementCount.removeAnnouncementId("a1", courseId: "c1", database: environment.database)

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        let entities: [CDUnreadCourseAnnouncementCount] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(entities.count, 0)
    }
}
