//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Core
@testable import Student
import TestsFoundation

class UserPreferencesTests: XCTestCase {
    func testLandingPageDescription() {
        XCTAssertEqual(UserPreferences.LandingPage.dashboard.description, "Dashboard")
        XCTAssertEqual(UserPreferences.LandingPage.calendar.description, "Calendar")
        XCTAssertEqual(UserPreferences.LandingPage.todo.description, "To Do")
        XCTAssertEqual(UserPreferences.LandingPage.notifications.description, "Notifications")
        XCTAssertEqual(UserPreferences.LandingPage.inbox.description, "Inbox")
    }

    func testLandingPageTabIndex() {
        XCTAssertEqual(UserPreferences.LandingPage.dashboard.tabIndex, 0)
        XCTAssertEqual(UserPreferences.LandingPage.calendar.tabIndex, 1)
        XCTAssertEqual(UserPreferences.LandingPage.todo.tabIndex, 2)
        XCTAssertEqual(UserPreferences.LandingPage.notifications.tabIndex, 3)
        XCTAssertEqual(UserPreferences.LandingPage.inbox.tabIndex, 4)
    }

    func testGetSetLandingPage() {
        UserPreferences.setLandingPage("test", page: UserPreferences.LandingPage.calendar)
        XCTAssertEqual(UserPreferences.landingPage("test"), UserPreferences.LandingPage.calendar)
        XCTAssertEqual(UserPreferences.landingPage(UUID.string), UserPreferences.LandingPage.dashboard)
    }
}
