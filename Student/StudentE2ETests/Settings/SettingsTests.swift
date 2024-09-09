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

class SettingsTests: E2ETestCase {
    typealias Helper = SettingsHelper
    typealias SubSettingsHelper = Helper.SubSettings
    typealias AboutHelper = Helper.About

    func testSettingsMenuItems() {
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

        // MARK: Check menu items of Settings
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        XCTAssertTrue(landingPage.isVisible)

        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        XCTAssertTrue(appearance.isVisible)

        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitUntil(.visible)
        XCTAssertTrue(pairWithObserver.isVisible)

        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitUntil(.visible)
        XCTAssertTrue(subscribeToCalendarFeed.isVisible)

        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        XCTAssertTrue(about.isVisible)

        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        XCTAssertTrue(privacyPolicy.isVisible)

        let offlineSync = Helper.menuItem(item: .synchronization).waitUntil(.visible)
        XCTAssertTrue(offlineSync.isVisible)

        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        XCTAssertTrue(termsOfUse.isVisible)

        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitUntil(.visible)
        XCTAssertTrue(canvasOnGitHub.isVisible)
    }

    func testLandingPageSetting() {
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

        // MARK: Select "Landing Page", check elements
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        XCTAssertTrue(landingPage.isVisible)

        landingPage.hit()

        let landingPageNavBar = SubSettingsHelper.landingPageNavBar.waitUntil(.visible)
        let dashboard = SubSettingsHelper.landingPageMenuItem(item: .dashboard).waitUntil(.visible)
        let calendar = SubSettingsHelper.landingPageMenuItem(item: .calendar).waitUntil(.visible)
        let toDo = SubSettingsHelper.landingPageMenuItem(item: .toDo).waitUntil(.visible)
        let notifications = SubSettingsHelper.landingPageMenuItem(item: .notifications).waitUntil(.visible)
        let inbox = SubSettingsHelper.landingPageMenuItem(item: .inbox).waitUntil(.visible)
        let backButton = SubSettingsHelper.backButton.waitUntil(.visible)
        XCTAssertTrue(landingPageNavBar.isVisible)
        XCTAssertTrue(dashboard.isVisible)
        XCTAssertTrue(calendar.isVisible)
        XCTAssertTrue(toDo.isVisible)
        XCTAssertTrue(notifications.isVisible)
        XCTAssertTrue(inbox.isVisible)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Select "Inbox", logout, login, check landing page
        inbox.hit()
        XCTAssertTrue(inbox.waitUntil(.visible).isVisible)

        backButton.hit()
        doneButton.hit()
        logOut()
        logInDSUser(student)
        let inboxNewMessageButton = InboxHelper.newMessageButton.waitUntil(.visible)
        XCTAssertTrue(inboxNewMessageButton.isVisible)
    }

    func testAppearanceSetting() {
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

        // MARK: Select "Appearance", check elements
        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        XCTAssertTrue(appearance.isVisible)

        appearance.hit()
        let appearanceNavBar = SubSettingsHelper.appearanceNavBar.waitUntil(.visible)
        let system = SubSettingsHelper.appearanceMenuItem(item: .system).waitUntil(.visible)
        let light = SubSettingsHelper.appearanceMenuItem(item: .light).waitUntil(.visible)
        let dark = SubSettingsHelper.appearanceMenuItem(item: .dark).waitUntil(.visible)
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

    func testPairWithObserverQRAppearance() {
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
        var doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Pair with Observer", check elements
        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitUntil(.visible)
        XCTAssertTrue(pairWithObserver.isVisible)

        pairWithObserver.hit()

        let pairWithObserverNavBar = SubSettingsHelper.pairWithObserverNavBar.waitUntil(.visible)
        XCTAssertTrue(pairWithObserverNavBar.isVisible)

        doneButton = SubSettingsHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(doneButton.isVisible)

        let shareButton = SubSettingsHelper.shareButton.waitUntil(.visible)
        XCTAssertTrue(shareButton.isVisible)

        let QRCodeImage = SubSettingsHelper.QRCodeImage.waitUntil(.visible)
        XCTAssertTrue(QRCodeImage.isVisible)
    }

    func testSubscribeToCalendarFeed() {
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

        // MARK: Select "Subscribe to Calendar Feed", check if Calendar app opens
        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitUntil(.visible)
        XCTAssertTrue(subscribeToCalendarFeed.isVisible)

        subscribeToCalendarFeed.hit()
        CalendarAppHelper.calendarApp.activate()
        let calendarAppRunning = CalendarAppHelper.calendarApp.wait(for: .runningForeground, timeout: 15)
        XCTAssertTrue(calendarAppRunning)

        // MARK: Handle first start of Calendar App, check subscription URL
        let continueButton = CalendarAppHelper.continueButton.waitUntil(.visible, timeout: 5)
        if continueButton.isVisible {
            continueButton.hit()
            CalendarAppHelper.calendarApp.hit()
        }

        let calendarNavBar = CalendarAppHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(calendarNavBar.isVisible)

        let subscriptionUrlElement = CalendarAppHelper.subscriptionUrl.waitUntil(.visible)
        XCTAssertTrue(subscriptionUrlElement.isVisible)
        XCTAssertTrue(subscriptionUrlElement.hasValue(value: user.host, strict: false))
    }

    func testAbout() {
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

        // MARK: Select About, check elements
        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        XCTAssertTrue(about.isVisible)

        about.hit()

        let aboutView = AboutHelper.aboutView.waitUntil(.visible)
        XCTAssertTrue(aboutView.isVisible)

        let appLabel = AboutHelper.appLabel.waitUntil(.visible)
        XCTAssertTrue(appLabel.isVisible)
        XCTAssertTrue(appLabel.hasLabel(label: "Degrees edX"))

        let domainLabel = AboutHelper.domainLabel.waitUntil(.visible)
        XCTAssertTrue(domainLabel.isVisible)
        XCTAssertTrue(domainLabel.hasLabel(label: "https://\(user.host)"))

        let loginIdLabel = AboutHelper.loginIdLabel.waitUntil(.visible)
        XCTAssertTrue(loginIdLabel.isVisible)
        XCTAssertTrue(loginIdLabel.hasLabel(label: student.id))

        let emailLabel = AboutHelper.emailLabel.waitUntil(.visible)
        XCTAssertTrue(emailLabel.isVisible)
        XCTAssertTrue(emailLabel.hasLabel(label: "-"))

        let versionLabel = AboutHelper.versionLabel.waitUntil(.visible)
        XCTAssertTrue(versionLabel.isVisible)
    }

    func testPrivacyPolicy() {
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

        // MARK: Select "Privacy Policy", check if Safari app opens
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        XCTAssertTrue(privacyPolicy.isVisible)

        privacyPolicy.hit()
        XCTAssertTrue(SafariAppHelper.safariApp.wait(for: .runningForeground, timeout: 15))

        // MARK: Check URL
        let url = SafariAppHelper.browserURL
        XCTAssertEqual(url, "https://www.instructure.com/privacy-security")
    }

    func testTermsOfUse() {
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

        // MARK: Select "Terms of Use", check elements
        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        XCTAssertTrue(termsOfUse.isVisible)

        termsOfUse.hit()
        let termsOfUseNavBar = SubSettingsHelper.termsOfUseNavBar.waitUntil(.visible)
        XCTAssertTrue(termsOfUseNavBar.isVisible)
    }

    func testCanvasOnGitHub() {
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

        // MARK: Select "Degrees edX on GitHub", check if Safari opens
        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitUntil(.visible)
        XCTAssertTrue(canvasOnGitHub.isVisible)

        canvasOnGitHub.hit()
        XCTAssertTrue(SafariAppHelper.safariApp.wait(for: .runningForeground, timeout: 15))

        // MARK: Check URL
        let url = SafariAppHelper.browserURL
        XCTAssertEqual(url, "https://github.com/2uinc/canvas-ios")
    }
}
