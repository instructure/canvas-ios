//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class ProfileTests: E2ETestCase {
    func testProfile() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        // MARK: Get the user logged in, check Profile
        logInDSUser(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let userAvatar = ProfileHelper.avatar.waitUntil(.visible)
        let userNameLabel = ProfileHelper.userNameLabel.waitUntil(.visible)
        let inboxButton = ProfileHelper.inboxButton.waitUntil(.visible)
        let manageStudentsButton = ProfileHelper.manageStudentsButton.waitUntil(.visible)
        let darkModeToggle = ProfileHelper.darkModeToggle.waitUntil(.visible)
        let helpButton = ProfileHelper.helpButton.waitUntil(.visible)
        let changeUserButton = ProfileHelper.changeUserButton.waitUntil(.visible)
        let logOutButton = ProfileHelper.logOutButton.waitUntil(.visible)
        XCTAssertTrue(userAvatar.isVisible)
        XCTAssertTrue(userNameLabel.isVisible)
        XCTAssertEqual(userNameLabel.label, parent.name)
        XCTAssertTrue(inboxButton.isVisible)
        XCTAssertTrue(manageStudentsButton.isVisible)
        XCTAssertTrue(darkModeToggle.isVisible)
        XCTAssertEqual(darkModeToggle.stringValue, "off")
        XCTAssertTrue(helpButton.isVisible)
        XCTAssertTrue(changeUserButton.isVisible)
        XCTAssertTrue(logOutButton.isVisible)
    }
}
