//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import XCTest

class TabBarMessageCountUpdaterTests: XCTestCase {
    private let testee = TabBarMessageCountUpdater()

    func testMessageStateChangeFromUnreadDecreasesBadgeCount() {
        TabBarBadgeCounts.unreadMessageCount = 1
        testee.updateBadgeCount(oldState: .unread, newState: .read)
        XCTAssertEqual(TabBarBadgeCounts.unreadMessageCount, 0)
    }

    func testMessageStateChangeFromUnreadDoesntCauseUnderflow() {
        TabBarBadgeCounts.unreadMessageCount = 0
        testee.updateBadgeCount(oldState: .unread, newState: .read)
        XCTAssertEqual(TabBarBadgeCounts.unreadMessageCount, 0)
    }

    func testMessageStateChangeToUnreadIncreasesBadgeCount() {
        TabBarBadgeCounts.unreadMessageCount = 0
        testee.updateBadgeCount(oldState: .read, newState: .unread)
        XCTAssertEqual(TabBarBadgeCounts.unreadMessageCount, 1)
    }
}
