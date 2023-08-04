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

class DSLoginE2ETests: E2ETestCase {
    // Follow-up of MBL-14653
    func testLoginWithLastUser() {
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)
        logInDSUser(parent, lastLogin: false)
        logOut()
        let lastLoginBtn = LoginHelper.Start.lastLoginButton.waitUntil(.visible)
        XCTAssertEqual(lastLoginBtn.label, user.host)

        lastLoginBtn.hit()
        loginAfterSchoolFound(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)
    }
}
