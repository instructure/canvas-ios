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

@testable import Horizon
import XCTest

final class NotificationFormatterTests: HorizonTestCase {

    func testFormatNotifications() {
        // Given
        let notifications: [HActivity] = HActivityStub.activities
        let courses: [HCourse] = HCourseStubs.courses
        let testee = NotificationFormatterLive()
        // When
       let result = testee.formatNotifications(notifications, courses: courses)
        // Then
        XCTAssertEqual(result.count, 5)
        XCTAssertEqual(result[0].type, NotificationType.announcement)
        XCTAssertEqual(result[1].type, NotificationType.scoreChanged)
        XCTAssertEqual(result[2].type, NotificationType.score)
        XCTAssertEqual(result[3].type, NotificationType.score)
        XCTAssertEqual(result[4].type, NotificationType.dueDate)

        XCTAssertEqual(result[0].dateFormatted, "Yesterday")
        XCTAssertEqual(result[1].dateFormatted, "Today")
        XCTAssertEqual(result[2].dateFormatted, "Sep 24, 2025")
        XCTAssertEqual(result[3].dateFormatted, "Jul 24, 2025")
    }
}
