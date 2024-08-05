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

class InboxMessageListItemTests: CoreTestCase {

    func testState() {
        let testee: InboxMessageListItem = databaseClient.insert()

        testee.stateRaw = "read"
        XCTAssertEqual(testee.state, .read)

        testee.stateRaw = "unread"
        XCTAssertEqual(testee.state, .unread)

        testee.stateRaw = "archived"
        XCTAssertEqual(testee.state, .archived)

        testee.stateRaw = "randomjunk"
        XCTAssertEqual(testee.state, .unread)
    }

    func testIsMarkAsReadActionAvaiable() {
        let testee: InboxMessageListItem = databaseClient.insert()

        testee.stateRaw = "read"
        XCTAssertEqual(testee.isMarkAsReadActionAvailable, false)

        testee.stateRaw = "unread"
        XCTAssertEqual(testee.isMarkAsReadActionAvailable, true)

        testee.stateRaw = "archived"
        XCTAssertEqual(testee.isMarkAsReadActionAvailable, true)
    }

    func testIsArchiveActionAvailable() {
        let testee: InboxMessageListItem = databaseClient.insert()

        testee.stateRaw = "read"
        XCTAssertEqual(testee.isArchiveActionAvailable, true)

        testee.stateRaw = "unread"
        XCTAssertEqual(testee.isArchiveActionAvailable, true)

        testee.stateRaw = "archived"
        XCTAssertEqual(testee.isArchiveActionAvailable, false)
    }

    func testDate() {
        let testee: InboxMessageListItem = databaseClient.insert()
        testee.dateRaw = Date(timeIntervalSince1970: 42)
        XCTAssertEqual(testee.date, Date(timeIntervalSince1970: 42).relativeDateOnlyString)
    }

    func testAvatar() {
        let testee: InboxMessageListItem = databaseClient.insert()

        testee.avatarNameRaw = nil
        testee.avatarURLRaw = nil
        XCTAssertEqual(testee.avatar, .group)

        testee.avatarNameRaw = nil
        testee.avatarURLRaw = .make()
        XCTAssertEqual(testee.avatar, .group)

        testee.avatarNameRaw = "testName"
        testee.avatarURLRaw = nil
        XCTAssertEqual(testee.avatar, .individual(name: "testName",
                                                  profileImageURL: nil))

        testee.avatarNameRaw = "testName"
        testee.avatarURLRaw = .make()
        XCTAssertEqual(testee.avatar, .individual(name: "testName",
                                                  profileImageURL: .make()))
    }
}
