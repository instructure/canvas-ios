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

class AboutTests: E2ETestCase {
    func testAbout() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        // MARK: Get the user logged in, navigate to About
        logInDSUser(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let aboutButton = ProfileHelper.aboutButton.waitUntil(.visible)
        XCTAssertTrue(aboutButton.isVisible)

        // MARK: Check elements of About
        aboutButton.hit()
        let aboutView = SettingsHelper.About.aboutView.waitUntil(.visible)
        XCTAssertTrue(aboutView.isVisible)

        let appLabel = SettingsHelper.About.appLabel.waitUntil(.visible)
        XCTAssertTrue(appLabel.isVisible)
        XCTAssertEqual(appLabel.label, "Canvas Parent")

        let domainLabel = SettingsHelper.About.domainLabel.waitUntil(.visible)
        XCTAssertTrue(domainLabel.isVisible)
        XCTAssertEqual(domainLabel.label, "https://\(user.host)")

        let loginIdLabel = SettingsHelper.About.loginIdLabel.waitUntil(.visible)
        XCTAssertTrue(loginIdLabel.isVisible)
        XCTAssertEqual(loginIdLabel.label, parent.id)

        let emailLabel = SettingsHelper.About.emailLabel.waitUntil(.visible)
        XCTAssertTrue(emailLabel.isVisible)
        XCTAssertEqual(emailLabel.label, "-")

        let versionLabel = SettingsHelper.About.versionLabel.waitUntil(.visible)
        XCTAssertTrue(versionLabel.isVisible)
    }
}
