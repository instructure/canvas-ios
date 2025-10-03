//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class SettingsTests: E2ETestCase {
    typealias Helper = SettingsHelper
    typealias SubSettingsHelper = Helper.SubSettings
    typealias AboutHelper = Helper.About

    func testSettingsMenuItems() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(parent, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(parent)
        Helper.navigateToSettings()

        // MARK: Check menu items of Settings
        let appearance = Helper.menuItemParent(.appearance).waitUntil(.visible)
        let about = Helper.menuItemParent(.about).waitUntil(.visible)
        let privacyPolicy = Helper.menuItemParent(.privacyPolicy).waitUntil(.visible)
        let termsOfUse = Helper.menuItemParent(.termsOfUse).waitUntil(.visible)
        XCTAssertVisible(appearance)
        XCTAssertVisible(about)
        XCTAssertVisible(privacyPolicy)
        XCTAssertVisible(termsOfUse)
    }

    func testAppearanceSetting() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(parent, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(parent)
        Helper.navigateToSettings()

        // MARK: Select "Appearance", check elements
        let appearance = Helper.menuItemParent(.appearance).waitUntil(.visible)
        XCTAssertVisible(appearance)

        appearance.hit()
        let dark = SubSettingsHelper.appearanceMenuItem(item: .dark).waitUntil(.visible)
        let light = SubSettingsHelper.appearanceMenuItem(item: .light).waitUntil(.visible)
        let system = SubSettingsHelper.appearanceMenuItem(item: .system).waitUntil(.visible)
        let appearanceNavBar = SubSettingsHelper.appearanceNavBar.waitUntil(.visible)
        XCTAssertVisible(appearanceNavBar)
        XCTAssertVisible(system)
        XCTAssertVisible(light)
        XCTAssertVisible(dark)

        // MARK: Select "Dark Theme", check selection, select "Light Theme", check selection
        dark.hit()
        XCTAssertTrue(dark.waitUntil(.selected).isSelected)

        light.hit()
        XCTAssertTrue(light.waitUntil(.selected).isSelected)
    }

    func testAbout() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(parent, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(parent)
        Helper.navigateToSettings()

        // MARK: Select About, check elements
        let about = Helper.menuItemParent(.about).waitUntil(.visible)
        XCTAssertVisible(about)

        about.hit()
        let aboutView = AboutHelper.aboutView.waitUntil(.visible)
        let appLabel = AboutHelper.appLabel.waitUntil(.visible)
        let domainLabel = AboutHelper.domainLabel.waitUntil(.visible)
        let loginIdLabel = AboutHelper.loginIdLabel.waitUntil(.visible)
        let emailLabel = AboutHelper.emailLabel.waitUntil(.visible)
        let versionLabel = AboutHelper.versionLabel.waitUntil(.visible)
        XCTAssertVisible(aboutView)
        XCTAssertVisible(appLabel)
        XCTAssertEqual(appLabel.label, "Canvas Parent")
        XCTAssertVisible(domainLabel)
        XCTAssertEqual(domainLabel.label, "https://\(user.host)")
        XCTAssertVisible(loginIdLabel)
        XCTAssertEqual(loginIdLabel.label, parent.id)
        XCTAssertVisible(emailLabel)
        XCTAssertEqual(emailLabel.label, "-")
        XCTAssertVisible(versionLabel)
    }

    func testPrivacyPolicy() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(parent, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(parent)
        Helper.navigateToSettings()

        // MARK: Select "Privacy Policy", check if Safari app opens
        let privacyPolicy = Helper.menuItemParent(.privacyPolicy).waitUntil(.visible)
        XCTAssertVisible(privacyPolicy)

        privacyPolicy.hit()
        let openInSafariButton = Helper.openInSafariButton.waitUntil(.visible)
        XCTAssertVisible(openInSafariButton)

        openInSafariButton.hit()
        XCTAssertTrue(SafariAppHelper.safariApp.wait(for: .runningForeground, timeout: 15))

        // MARK: Check URL
        let url = SafariAppHelper.browserURL
        XCTAssertEqual(url, "https://www.instructure.com/privacy-security")
    }

    func testTermsOfUse() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(parent, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(parent)
        Helper.navigateToSettings()

        // MARK: Select "Terms of Use", check elements
        let termsOfUse = Helper.menuItemParent(.termsOfUse).waitUntil(.visible)
        XCTAssertVisible(termsOfUse)

        termsOfUse.hit()
        let termsOfUseNavBar = SubSettingsHelper.termsOfUseNavBar.waitUntil(.visible)
        XCTAssertVisible(termsOfUseNavBar)
    }
}
