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

class SettingsTests: E2ETestCase {
    typealias Helper = SettingsHelper
    typealias SubSettingsHelper = Helper.SubSettings
    typealias AboutHelper = Helper.About

    func testSettingsMenuItems() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        Helper.navigateToSettings()

        // MARK: Check menu items of Settings
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        XCTAssertVisible(landingPage)
        XCTAssertVisible(appearance)
        XCTAssertVisible(about)
        XCTAssertVisible(privacyPolicy)
        XCTAssertVisible(termsOfUse)
    }

    func testLandingPageSetting() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        Helper.navigateToSettings()

        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertVisible(doneButton)

        // MARK: Select "Landing Page", check elements
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        XCTAssertVisible(landingPage)

        landingPage.hit()
        let landingPageNavBar = SubSettingsHelper.landingPageNavBar.waitUntil(.visible)
        let courses = SubSettingsHelper.landingPageMenuItem(item: .dashboard).waitUntil(.visible)
        let toDo = SubSettingsHelper.landingPageMenuItem(item: .todo).waitUntil(.visible)
        let inbox = SubSettingsHelper.landingPageMenuItem(item: .inbox).waitUntil(.visible)
        let backButton = SubSettingsHelper.backButton.waitUntil(.visible)
        XCTAssertVisible(landingPageNavBar)
        XCTAssertVisible(courses)
        XCTAssertVisible(toDo)
        XCTAssertVisible(inbox)
        XCTAssertVisible(backButton)

        // MARK: Select "Inbox", logout, log back in, check landing page
        inbox.hit()
        XCTAssertTrue(inbox.waitUntil(.visible).isVisible)

        backButton.hit()
        doneButton.hit()
        logOut()
        logInDSUser(teacher)
        let newMessageButton = InboxHelper.newMessageButton.waitUntil(.visible)
        XCTAssertVisible(newMessageButton)
    }

    func testAppearanceSetting() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        Helper.navigateToSettings()

        // MARK: Select "Appearance", check elements
        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
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
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        Helper.navigateToSettings()

        // MARK: Select About, check elements
        let about = Helper.menuItem(item: .about).waitUntil(.visible)
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
        XCTAssertEqual(appLabel.label, "Canvas Teacher")
        XCTAssertVisible(domainLabel)
        XCTAssertEqual(domainLabel.label, "https://\(user.host)")
        XCTAssertVisible(loginIdLabel)
        XCTAssertEqual(loginIdLabel.label, teacher.id)
        XCTAssertVisible(emailLabel)
        XCTAssertEqual(emailLabel.label, "-")
        XCTAssertVisible(versionLabel)
    }

    func testPrivacyPolicy() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        Helper.navigateToSettings()

        // MARK: Select "Privacy Policy", check if Safari app opens
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
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
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        Helper.navigateToSettings()

        // MARK: Select "Terms of Use", check elements
        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        XCTAssertVisible(termsOfUse)

        termsOfUse.hit()
        let termsOfUseNavBar = SubSettingsHelper.termsOfUseNavBar.waitUntil(.visible)
        XCTAssertVisible(termsOfUseNavBar)
    }
}
