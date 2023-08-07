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
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Check menu items of Settings
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        let landingPageLabel = Helper.labelOfMenuItem(menuItem: landingPage).waitUntil(.visible)
        XCTAssertTrue(landingPage.isVisible)
        XCTAssertTrue(landingPageLabel.isVisible)
        XCTAssertEqual(landingPageLabel.label, "Landing Page")

        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        let appearanceLabel = Helper.labelOfMenuItem(menuItem: appearance).waitUntil(.visible)
        XCTAssertTrue(appearance.isVisible)
        XCTAssertTrue(appearanceLabel.isVisible)
        XCTAssertEqual(appearanceLabel.label, "Appearance")

        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitUntil(.visible)
        let pairWithObserverLabel = Helper.labelOfMenuItem(menuItem: pairWithObserver).waitUntil(.visible)
        XCTAssertTrue(pairWithObserver.isVisible)
        XCTAssertTrue(pairWithObserverLabel.isVisible)
        XCTAssertEqual(pairWithObserverLabel.label, "Pair with Observer")

        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitUntil(.visible)
        let subscribeToCalendarFeedLabel = Helper.labelOfMenuItem(menuItem: subscribeToCalendarFeed).waitUntil(.visible)
        XCTAssertTrue(subscribeToCalendarFeed.isVisible)
        XCTAssertTrue(subscribeToCalendarFeedLabel.isVisible)
        XCTAssertEqual(subscribeToCalendarFeedLabel.label, "Subscribe to Calendar Feed")

        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        let aboutLabel = Helper.labelOfMenuItem(menuItem: about).waitUntil(.visible)
        XCTAssertTrue(about.isVisible)
        XCTAssertTrue(aboutLabel.isVisible)
        XCTAssertEqual(aboutLabel.label, "About")

        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        let privacyPolicyLabel = Helper.labelOfMenuItem(menuItem: privacyPolicy).waitUntil(.visible)
        XCTAssertTrue(privacyPolicy.isVisible)
        XCTAssertTrue(privacyPolicyLabel.isVisible)
        XCTAssertEqual(privacyPolicyLabel.label, "Privacy Policy")

        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        let termsOfUseLabel = Helper.labelOfMenuItem(menuItem: termsOfUse).waitUntil(.visible)
        XCTAssertTrue(termsOfUse.isVisible)
        XCTAssertTrue(termsOfUseLabel.isVisible)
        XCTAssertEqual(termsOfUseLabel.label, "Terms of Use")

        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitUntil(.visible)
        let canvasOnGitHubLabel = Helper.labelOfMenuItem(menuItem: canvasOnGitHub).waitUntil(.visible)
        XCTAssertTrue(canvasOnGitHub.isVisible)
        XCTAssertTrue(canvasOnGitHubLabel.isVisible)
        XCTAssertEqual(canvasOnGitHubLabel.label, "Canvas on GitHub")
    }

    func testLandingPageSetting() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
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
        XCTAssertTrue(landingPageNavBar.isVisible)

        let dashboard = SubSettingsHelper.landingPageMenuItem(item: .dashboard).waitUntil(.visible)
        let dashboardLabel = SubSettingsHelper.labelOfMenuItem(menuItem: dashboard).waitUntil(.visible)
        XCTAssertTrue(dashboard.isVisible)
        XCTAssertTrue(dashboard.isSelected)
        XCTAssertTrue(dashboardLabel.isVisible)
        XCTAssertEqual(dashboardLabel.label, "Dashboard")

        let calendar = SubSettingsHelper.landingPageMenuItem(item: .calendar).waitUntil(.visible)
        let calendarLabel = SubSettingsHelper.labelOfMenuItem(menuItem: calendar).waitUntil(.visible)
        XCTAssertTrue(calendar.isVisible)
        XCTAssertFalse(calendar.isSelected)
        XCTAssertTrue(calendarLabel.isVisible)
        XCTAssertEqual(calendarLabel.label, "Calendar")

        let toDo = SubSettingsHelper.landingPageMenuItem(item: .toDo).waitUntil(.visible)
        let toDoLabel = SubSettingsHelper.labelOfMenuItem(menuItem: toDo).waitUntil(.visible)
        XCTAssertTrue(toDo.isVisible)
        XCTAssertFalse(toDo.isSelected)
        XCTAssertTrue(toDoLabel.isVisible)
        XCTAssertEqual(toDoLabel.label, "To Do")

        let notifications = SubSettingsHelper.landingPageMenuItem(item: .notifications).waitUntil(.visible)
        let notificationsLabel = SubSettingsHelper.labelOfMenuItem(menuItem: notifications).waitUntil(.visible)
        XCTAssertTrue(notifications.isVisible)
        XCTAssertFalse(notifications.isSelected)
        XCTAssertTrue(notificationsLabel.isVisible)
        XCTAssertEqual(notificationsLabel.label, "Notifications")

        let inbox = SubSettingsHelper.landingPageMenuItem(item: .inbox).waitUntil(.visible)
        let inboxLabel = SubSettingsHelper.labelOfMenuItem(menuItem: inbox).waitUntil(.visible)
        XCTAssertTrue(inbox.isVisible)
        XCTAssertFalse(inbox.isSelected)
        XCTAssertTrue(inboxLabel.isVisible)
        XCTAssertEqual(inboxLabel.label, "Inbox")

        let backButton = SubSettingsHelper.backButton.waitUntil(.visible)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Select "Inbox", logout, login, check landing page
        inbox.hit()
        XCTAssertTrue(inbox.waitUntil(.visible).isVisible)

        backButton.hit()
        doneButton.hit()
        logOut()
        logInDSUser(student)
        let inboxNavBar = InboxHelper.navBar.waitUntil(.visible)
        XCTAssertTrue(inboxNavBar.isVisible)
    }

    func testAppearanceSetting() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
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
        XCTAssertTrue(appearanceNavBar.isVisible)

        let system = SubSettingsHelper.appearanceMenuItem(item: .system).waitUntil(.visible)
        let systemLabel = SubSettingsHelper.labelOfMenuItem(menuItem: system).waitUntil(.visible)
        XCTAssertTrue(system.isVisible)
        XCTAssertTrue(system.isSelected)
        XCTAssertTrue(systemLabel.isVisible)
        XCTAssertEqual(systemLabel.label, "System Settings")

        let light = SubSettingsHelper.appearanceMenuItem(item: .light).waitUntil(.visible)
        let lightLabel = SubSettingsHelper.labelOfMenuItem(menuItem: light).waitUntil(.visible)
        XCTAssertTrue(light.isVisible)
        XCTAssertFalse(light.isSelected)
        XCTAssertTrue(lightLabel.isVisible)
        XCTAssertEqual(lightLabel.label, "Light Theme")

        let dark = SubSettingsHelper.appearanceMenuItem(item: .dark).waitUntil(.visible)
        let darkLabel = SubSettingsHelper.labelOfMenuItem(menuItem: dark).waitUntil(.visible)
        XCTAssertTrue(dark.isVisible)
        XCTAssertFalse(dark.isSelected)
        XCTAssertTrue(darkLabel.isVisible)
        XCTAssertEqual(darkLabel.label, "Dark Theme")

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
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Subscribe to Calendar Feed", check if Calendar app opens
        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitUntil(.visible)
        XCTAssertTrue(subscribeToCalendarFeed.isVisible)

        subscribeToCalendarFeed.hit()
        let calendarAppRunning = CalendarAppHelper.calendarApp.wait(for: .runningForeground, timeout: 15)
        XCTAssertTrue(calendarAppRunning)

        // MARK: Handle first start of Calendar App, check subscription URL
        let continueButton = CalendarAppHelper.continueButton.waitUntil(.visible, timeout: 5)
        if continueButton.isVisible {
            continueButton.hit()
            app.hit()
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
        XCTAssertEqual(appLabel.label, "Canvas Student")

        let domainLabel = AboutHelper.domainLabel.waitUntil(.visible)
        XCTAssertTrue(domainLabel.isVisible)
        XCTAssertEqual(domainLabel.label, "https://\(user.host)")

        let loginIdLabel = AboutHelper.loginIdLabel.waitUntil(.visible)
        XCTAssertTrue(loginIdLabel.isVisible)
        XCTAssertEqual(loginIdLabel.label, student.id)

        let emailLabel = AboutHelper.emailLabel.waitUntil(.visible)
        XCTAssertTrue(emailLabel.isVisible)
        XCTAssertEqual(emailLabel.label, "-")

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
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Privacy Policy", check if Safari app opens
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        XCTAssertTrue(privacyPolicy.isVisible)

        privacyPolicy.hit()

        let safariAppState = SafariAppHelper.safariApp.state
        XCTAssertEqual(safariAppState, .runningForeground)

        // MARK: Check URL
        let url = SafariAppHelper.browserURL
        XCTAssertEqual(url, "https://www.instructure.com/canvas/privacy")
    }

    func testTermsOfUse() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
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
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitUntil(.visible)
        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Canvas on GitHub", check if Safari opens
        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitUntil(.visible)
        XCTAssertTrue(canvasOnGitHub.isVisible)

        canvasOnGitHub.hit()

        let safariAppState = SafariAppHelper.safariApp.state
        XCTAssertEqual(safariAppState, .runningForeground)

        // MARK: Check URL
        let url = SafariAppHelper.browserURL
        XCTAssertEqual(url, "https://github.com/instructure/canvas-ios")
    }
}
