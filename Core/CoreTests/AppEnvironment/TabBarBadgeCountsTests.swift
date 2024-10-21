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
    let application = UIApplication.shared
    let messageItem = UITabBarItem()
    let todoItem = UITabBarItem()

    func testUpdates() throws {
        TabBarBadgeCounts.application = application
        TabBarBadgeCounts.messageItem = messageItem
        TabBarBadgeCounts.todoItem = todoItem

        TabBarBadgeCounts.unreadMessageCount = 7
        waitUntil(shouldFail: true) {
            application.applicationIconBadgeNumber == 7
        }
        XCTAssertEqual(messageItem.badgeValue, "7")
        XCTAssertEqual(todoItem.badgeValue, nil)

        TabBarBadgeCounts.todoListCount = 2
        waitUntil(shouldFail: true) {
            application.applicationIconBadgeNumber == 9
        }
        XCTAssertEqual(messageItem.badgeValue, "7")
        XCTAssertEqual(todoItem.badgeValue, "2")

        TabBarBadgeCounts.unreadMessageCount = 0
        waitUntil(shouldFail: true) {
            application.applicationIconBadgeNumber == 2
        }
        XCTAssertEqual(messageItem.badgeValue, nil)
        XCTAssertEqual(todoItem.badgeValue, "2")

        TabBarBadgeCounts.todoListCount = 0
        waitUntil(shouldFail: true) {
            application.applicationIconBadgeNumber == 0
        }
        XCTAssertEqual(messageItem.badgeValue, nil)
        XCTAssertEqual(todoItem.badgeValue, nil)

        TabBarBadgeCounts.application = nil
        TabBarBadgeCounts.messageItem = nil
        TabBarBadgeCounts.todoItem = nil

        TabBarBadgeCounts.unreadMessageCount = 1
        TabBarBadgeCounts.todoListCount = 5
        waitUntil(shouldFail: true) {
            application.applicationIconBadgeNumber == 0
        }
        XCTAssertEqual(messageItem.badgeValue, nil)
        XCTAssertEqual(todoItem.badgeValue, nil)

        TabBarBadgeCounts.application = application
        TabBarBadgeCounts.messageItem = messageItem
        TabBarBadgeCounts.todoItem = todoItem
        waitUntil(shouldFail: true) {
            application.applicationIconBadgeNumber == 6
        }
        XCTAssertEqual(messageItem.badgeValue, "1")
        XCTAssertEqual(todoItem.badgeValue, "5")
    }
}
