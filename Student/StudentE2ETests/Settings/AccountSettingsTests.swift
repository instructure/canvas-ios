//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class AccountSettingsTests: E2ETestCase {
    typealias Helper = SettingsHelper
    typealias SubSettingsHelper = Helper.SubSettings

    override func setUp() {
        super.setUp()

        seeder.setSelfRegistrationForCanvas(selfRegistration: .none)
    }

    override func tearDown() {
        seeder.setSelfRegistrationForCanvas(selfRegistration: .all)

        super.tearDown()
    }

    func testPairWithObserverDisabled() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Check if "Pair with Observer" is not available
        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitUntil(.visible, timeout: 5)
        XCTAssertTrue(pairWithObserver.isVanished)
    }
}
