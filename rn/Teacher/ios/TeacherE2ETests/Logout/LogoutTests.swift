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

class LogoutTests: E2ETestCase {
    func testLogout() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)

        // MARK: Start logout process
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        // MARK: Check "Log Out" button
        profileButton.hit()
        let logoutButton = ProfileHelper.logOutButton.waitUntil(.visible)
        XCTAssertTrue(logoutButton.isVisible)

        // MARK: Check "Last Login" button after logout
        logoutButton.hit()
        let lastLoginButton = LoginHelper.Start.lastLoginButton.waitUntil(.visible)
        XCTAssertTrue(lastLoginButton.isVisible)
        XCTAssertTrue(lastLoginButton.hasLabel(label: user.host))
    }
}
