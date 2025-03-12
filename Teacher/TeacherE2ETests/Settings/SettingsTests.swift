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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Check menu items of Settings
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitUntil(.visible)
        XCTAssertTrue(landingPage.isVisible)
        XCTAssertTrue(appearance.isVisible)
        XCTAssertTrue(about.isVisible)
        XCTAssertTrue(privacyPolicy.isVisible)
        XCTAssertTrue(termsOfUse.isVisible)
        XCTAssertTrue(canvasOnGitHub.isVisible)
    }

    func testLandingPageSetting() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Landing Page", check elements
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        XCTAssertTrue(landingPage.isVisible)

        landingPage.hit()
        let landingPageNavBar = SubSettingsHelper.landingPageNavBar.waitUntil(.visible)
        let courses = SubSettingsHelper.landingPageMenuItem(item: .courses).waitUntil(.visible)
        let toDo = SubSettingsHelper.landingPageMenuItem(item: .toDo).waitUntil(.visible)
        let inbox = SubSettingsHelper.landingPageMenuItem(item: .inbox).waitUntil(.visible)
        let backButton = SubSettingsHelper.backButton.waitUntil(.visible)
        XCTAssertTrue(landingPageNavBar.isVisible)
        XCTAssertTrue(courses.isVisible)
        XCTAssertTrue(toDo.isVisible)
        XCTAssertTrue(inbox.isVisible)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Select "Inbox", logout, log back in, check landing page
        inbox.hit()
        XCTAssertTrue(inbox.waitUntil(.visible).isVisible)

        backButton.hit()
        doneButton.hit()
        logOut()
        logInDSUser(teacher)
        let newMessageButton = InboxHelper.newMessageButton.waitUntil(.visible)
        XCTAssertTrue(newMessageButton.isVisible)
    }

    func testAppearanceSetting() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Appearance", check elements
        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        XCTAssertTrue(appearance.isVisible)

        appearance.hit()
        let dark = SubSettingsHelper.appearanceMenuItem(item: .dark).waitUntil(.visible)
        let light = SubSettingsHelper.appearanceMenuItem(item: .light).waitUntil(.visible)
        let system = SubSettingsHelper.appearanceMenuItem(item: .system).waitUntil(.visible)
        let appearanceNavBar = SubSettingsHelper.appearanceNavBar.waitUntil(.visible)
        XCTAssertTrue(appearanceNavBar.isVisible)
        XCTAssertTrue(system.isVisible)
        XCTAssertTrue(light.isVisible)
        XCTAssertTrue(dark.isVisible)

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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select About, check elements
        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        XCTAssertTrue(about.isVisible)

        about.hit()
        let aboutView = AboutHelper.aboutView.waitUntil(.visible)
        let appLabel = AboutHelper.appLabel.waitUntil(.visible)
        let domainLabel = AboutHelper.domainLabel.waitUntil(.visible)
        let loginIdLabel = AboutHelper.loginIdLabel.waitUntil(.visible)
        let emailLabel = AboutHelper.emailLabel.waitUntil(.visible)
        let versionLabel = AboutHelper.versionLabel.waitUntil(.visible)
        XCTAssertTrue(aboutView.isVisible)
        XCTAssertTrue(appLabel.isVisible)
        XCTAssertTrue(appLabel.hasLabel(label: "Canvas Teacher"))
        XCTAssertTrue(domainLabel.isVisible)
        XCTAssertTrue(domainLabel.hasLabel(label: "https://\(user.host)"))
        XCTAssertTrue(loginIdLabel.isVisible)
        XCTAssertTrue(loginIdLabel.hasLabel(label: teacher.id))
        XCTAssertTrue(emailLabel.isVisible)
        XCTAssertTrue(emailLabel.hasLabel(label: "-"))
        XCTAssertTrue(versionLabel.isVisible)
    }

    func testPrivacyPolicy() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Privacy Policy", check if Safari app opens
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        XCTAssertTrue(privacyPolicy.isVisible)

        privacyPolicy.hit()
        let openInSafariButton = Helper.openInSafariButton.waitUntil(.visible)
        XCTAssertTrue(openInSafariButton.isVisible)

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
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Terms of Use", check elements
        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        XCTAssertTrue(termsOfUse.isVisible)

        termsOfUse.hit()
        let termsOfUseNavBar = SubSettingsHelper.termsOfUseNavBar.waitUntil(.visible)
        XCTAssertTrue(termsOfUseNavBar.isVisible)
    }

    func testCanvasOnGitHub() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Canvas on GitHub", check if Safari opens
        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitUntil(.visible)
        XCTAssertTrue(canvasOnGitHub.isVisible)

        canvasOnGitHub.hit()
        let openInSafariButton = Helper.openInSafariButton.waitUntil(.visible)
        XCTAssertTrue(openInSafariButton.isVisible)

        openInSafariButton.hit()
        XCTAssertTrue(SafariAppHelper.safariApp.wait(for: .runningForeground, timeout: 15))

        // MARK: Check URL
        let url = SafariAppHelper.browserURL
        XCTAssertEqual(url, "https://github.com/instructure/canvas-ios")
    }
}
