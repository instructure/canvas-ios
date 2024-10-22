//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class TabBarBadgeCountsTests: CoreTestCase {
    let messageItem = UITabBarItem()
    let todoItem = UITabBarItem()

    func testUpdatesExistingNotificationCountWhenNotificationCenterUpdated() {
        // GIVEN
        TabBarBadgeCounts.messageItem = messageItem
        TabBarBadgeCounts.todoItem = todoItem
        TabBarBadgeCounts.unreadMessageCount = 7
        TabBarBadgeCounts.todoListCount = 2

        // WHEN
        TabBarBadgeCounts.notificationCenter = notificationCenter

        // THEN
        XCTAssertEqual(notificationCenter.badgeCount, 9)
        XCTAssertEqual(messageItem.badgeValue, "7")
        XCTAssertEqual(todoItem.badgeValue, "2")
    }

    func testUpdatesNotificationCountOnExistingNotificationCenter() {
        // GIVEN
        TabBarBadgeCounts.notificationCenter = notificationCenter
        TabBarBadgeCounts.messageItem = messageItem
        TabBarBadgeCounts.todoItem = todoItem

        // WHEN
        TabBarBadgeCounts.unreadMessageCount = 7
        TabBarBadgeCounts.todoListCount = 2

        // THEN
        XCTAssertEqual(notificationCenter.badgeCount, 9)
        XCTAssertEqual(messageItem.badgeValue, "7")
        XCTAssertEqual(todoItem.badgeValue, "2")
    }

    func testResetsNotificationCounts() {
        // GIVEN
        TabBarBadgeCounts.notificationCenter = notificationCenter
        TabBarBadgeCounts.messageItem = messageItem
        TabBarBadgeCounts.todoItem = todoItem
        TabBarBadgeCounts.unreadMessageCount = 7
        TabBarBadgeCounts.todoListCount = 2

        // WHEN
        TabBarBadgeCounts.unreadMessageCount = 0
        TabBarBadgeCounts.todoListCount = 0

        // THEN
        XCTAssertEqual(notificationCenter.badgeCount, 0)
        XCTAssertEqual(messageItem.badgeValue, nil)
        XCTAssertEqual(todoItem.badgeValue, nil)
    }
}
