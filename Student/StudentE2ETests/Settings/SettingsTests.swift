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
    typealias CalendarAppHelper = SubSettingsHelper.CalendarApp
    typealias SafariAppHelper = SubSettingsHelper.SafariApp

    func testSettingsMenuItems() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Check menu items of Settings
        let landingPage = Helper.menuItem(item: .landingPage).waitToExist()
        let landingPageLabel = Helper.labelOfMenuItem(menuItem: landingPage).waitToExist()
        XCTAssertTrue(landingPage.isVisible)
        XCTAssertTrue(landingPageLabel.isVisible)
        XCTAssertEqual(landingPageLabel.label(), "Landing Page")

        let appearance = Helper.menuItem(item: .appearance).waitToExist()
        let appearanceLabel = Helper.labelOfMenuItem(menuItem: appearance).waitToExist()
        XCTAssertTrue(appearance.isVisible)
        XCTAssertTrue(appearanceLabel.isVisible)
        XCTAssertEqual(appearanceLabel.label(), "Appearance")

        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitToExist()
        let pairWithObserverLabel = Helper.labelOfMenuItem(menuItem: pairWithObserver).waitToExist()
        XCTAssertTrue(pairWithObserver.isVisible)
        XCTAssertTrue(pairWithObserverLabel.isVisible)
        XCTAssertEqual(pairWithObserverLabel.label(), "Pair with Observer")

        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitToExist()
        let subscribeToCalendarFeedLabel = Helper.labelOfMenuItem(menuItem: subscribeToCalendarFeed).waitToExist()
        XCTAssertTrue(subscribeToCalendarFeed.isVisible)
        XCTAssertTrue(subscribeToCalendarFeedLabel.isVisible)
        XCTAssertEqual(subscribeToCalendarFeedLabel.label(), "Subscribe to Calendar Feed")

        let about = Helper.menuItem(item: .about).waitToExist()
        let aboutLabel = Helper.labelOfMenuItem(menuItem: about).waitToExist()
        XCTAssertTrue(about.isVisible)
        XCTAssertTrue(aboutLabel.isVisible)
        XCTAssertEqual(aboutLabel.label(), "About")

        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitToExist()
        let privacyPolicyLabel = Helper.labelOfMenuItem(menuItem: privacyPolicy).waitToExist()
        XCTAssertTrue(privacyPolicy.isVisible)
        XCTAssertTrue(privacyPolicyLabel.isVisible)
        XCTAssertEqual(privacyPolicyLabel.label(), "Privacy Policy")

        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitToExist()
        let termsOfUseLabel = Helper.labelOfMenuItem(menuItem: termsOfUse).waitToExist()
        XCTAssertTrue(termsOfUse.isVisible)
        XCTAssertTrue(termsOfUseLabel.isVisible)
        XCTAssertEqual(termsOfUseLabel.label(), "Terms of Use")

        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitToExist()
        let canvasOnGitHubLabel = Helper.labelOfMenuItem(menuItem: canvasOnGitHub).waitToExist()
        XCTAssertTrue(canvasOnGitHub.isVisible)
        XCTAssertTrue(canvasOnGitHubLabel.isVisible)
        XCTAssertEqual(canvasOnGitHubLabel.label(), "Canvas on GitHub")
    }

    func testLandingPageSetting() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Landing Page", check elements
        let landingPage = Helper.menuItem(item: .landingPage).waitToExist()
        XCTAssertTrue(landingPage.isVisible)

        landingPage.tap()

        let landingPageNavBar = SubSettingsHelper.landingPageNavBar.waitToExist()
        XCTAssertTrue(landingPageNavBar.isVisible)

        let dashboard = SubSettingsHelper.landingPageMenuItem(item: .dashboard).waitToExist()
        let dashboardLabel = SubSettingsHelper.labelOfMenuItem(menuItem: dashboard).waitToExist()
        XCTAssertTrue(dashboard.isVisible)
        XCTAssertTrue(dashboard.isSelected)
        XCTAssertTrue(dashboardLabel.isVisible)
        XCTAssertEqual(dashboardLabel.label(), "Dashboard")

        let calendar = SubSettingsHelper.landingPageMenuItem(item: .calendar).waitToExist()
        let calendarLabel = SubSettingsHelper.labelOfMenuItem(menuItem: calendar).waitToExist()
        XCTAssertTrue(calendar.isVisible)
        XCTAssertFalse(calendar.isSelected)
        XCTAssertTrue(calendarLabel.isVisible)
        XCTAssertEqual(calendarLabel.label(), "Calendar")

        let toDo = SubSettingsHelper.landingPageMenuItem(item: .toDo).waitToExist()
        let toDoLabel = SubSettingsHelper.labelOfMenuItem(menuItem: toDo).waitToExist()
        XCTAssertTrue(toDo.isVisible)
        XCTAssertFalse(toDo.isSelected)
        XCTAssertTrue(toDoLabel.isVisible)
        XCTAssertEqual(toDoLabel.label(), "To Do")

        let notifications = SubSettingsHelper.landingPageMenuItem(item: .notifications).waitToExist()
        let notificationsLabel = SubSettingsHelper.labelOfMenuItem(menuItem: notifications).waitToExist()
        XCTAssertTrue(notifications.isVisible)
        XCTAssertFalse(notifications.isSelected)
        XCTAssertTrue(notificationsLabel.isVisible)
        XCTAssertEqual(notificationsLabel.label(), "Notifications")

        let inbox = SubSettingsHelper.landingPageMenuItem(item: .inbox).waitToExist()
        let inboxLabel = SubSettingsHelper.labelOfMenuItem(menuItem: inbox).waitToExist()
        XCTAssertTrue(inbox.isVisible)
        XCTAssertFalse(inbox.isSelected)
        XCTAssertTrue(inboxLabel.isVisible)
        XCTAssertEqual(inboxLabel.label(), "Inbox")

        let backButton = SubSettingsHelper.backButton.waitToExist()
        XCTAssertTrue(backButton.isVisible)

        // MARK: Select "Inbox", logout, login, check landing page
        inbox.tap()
        XCTAssertTrue(inbox.waitUntilSelected())

        backButton.tap()
        doneButton.tap()
        logOut()
        logInDSUser(student)
        let inboxNavBar = InboxHelper.navBar.waitToExist()
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
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Appearance", check elements
        let appearance = Helper.menuItem(item: .appearance).waitToExist()
        XCTAssertTrue(appearance.isVisible)

        appearance.tap()

        let appearanceNavBar = SubSettingsHelper.appearanceNavBar.waitToExist()
        XCTAssertTrue(appearanceNavBar.isVisible)

        let system = SubSettingsHelper.appearanceMenuItem(item: .system).waitToExist()
        let systemLabel = SubSettingsHelper.labelOfMenuItem(menuItem: system).waitToExist()
        XCTAssertTrue(system.isVisible)
        XCTAssertTrue(system.isSelected)
        XCTAssertTrue(systemLabel.isVisible)
        XCTAssertEqual(systemLabel.label(), "System Settings")

        let light = SubSettingsHelper.appearanceMenuItem(item: .light).waitToExist()
        let lightLabel = SubSettingsHelper.labelOfMenuItem(menuItem: light).waitToExist()
        XCTAssertTrue(light.isVisible)
        XCTAssertFalse(light.isSelected)
        XCTAssertTrue(lightLabel.isVisible)
        XCTAssertEqual(lightLabel.label(), "Light Theme")

        let dark = SubSettingsHelper.appearanceMenuItem(item: .dark).waitToExist()
        let darkLabel = SubSettingsHelper.labelOfMenuItem(menuItem: dark).waitToExist()
        XCTAssertTrue(dark.isVisible)
        XCTAssertFalse(dark.isSelected)
        XCTAssertTrue(darkLabel.isVisible)
        XCTAssertEqual(darkLabel.label(), "Dark Theme")

        // MARK: Select "Dark Theme", check selection, select "Light Theme", check selection
        dark.tap()
        XCTAssertTrue(dark.waitUntilSelected())

        light.tap()
        XCTAssertTrue(light.waitUntilSelected())
    }

    func testPairWithObserverQRAppearance() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitToExist()
        var doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Pair with Observer", check elements
        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitToExist()
        XCTAssertTrue(pairWithObserver.isVisible)

        pairWithObserver.tap()

        let pairWithObserverNavBar = SubSettingsHelper.pairWithObserverNavBar.waitToExist()
        XCTAssertTrue(pairWithObserverNavBar.isVisible)

        doneButton = SubSettingsHelper.doneButton.waitToExist()
        XCTAssertTrue(doneButton.isVisible)

        let shareButton = SubSettingsHelper.shareButton.waitToExist()
        XCTAssertTrue(shareButton.isVisible)

        let QRCodeImage = SubSettingsHelper.QRCodeImage.waitToExist()
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
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Subscribe to Calendar Feed", check if Calendar app opens
        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitToExist()
        XCTAssertTrue(subscribeToCalendarFeed.isVisible)

        let calendarAppBaseState = CalendarAppHelper.calendarApp.state
        XCTAssertEqual(calendarAppBaseState, .notRunning)

        subscribeToCalendarFeed.tap()
        let calendarAppState = CalendarAppHelper.calendarApp.state
        XCTAssertEqual(calendarAppState, .runningForeground)

        // MARK: Handle first start of Calendar App, check subscription URL
        let continueButton = CalendarAppHelper.continueButton.waitToExist(5, shouldFail: false)
        if continueButton.isVisible {
            continueButton.tap()
            app.tap()
        }

        let calendarNavBar = CalendarAppHelper.navBar.waitToExist()
        XCTAssertTrue(calendarNavBar.isVisible)

        let subscriptionUrlElement = CalendarAppHelper.subscriptionUrl.waitToExist()
        XCTAssertTrue(subscriptionUrlElement.isVisible)
        XCTAssertTrue(subscriptionUrlElement.value()!.contains(user.host))
    }

    func testAbout() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select About, check elements
        let about = Helper.menuItem(item: .about).waitToExist()
        XCTAssertTrue(about.isVisible)

        about.tap()

        let aboutView = AboutHelper.aboutView.waitToExist()
        XCTAssertTrue(aboutView.isVisible)

        let appLabel = AboutHelper.appLabel.waitToExist()
        XCTAssertTrue(appLabel.isVisible)
        XCTAssertEqual(appLabel.label(), "Canvas Student")

        let domainLabel = AboutHelper.domainLabel.waitToExist()
        XCTAssertTrue(domainLabel.isVisible)
        XCTAssertEqual(domainLabel.label(), "https://\(user.host)")

        let loginIdLabel = AboutHelper.loginIdLabel.waitToExist()
        XCTAssertTrue(loginIdLabel.isVisible)
        XCTAssertEqual(loginIdLabel.label(), student.id)

        let emailLabel = AboutHelper.emailLabel.waitToExist()
        XCTAssertTrue(emailLabel.isVisible)
        XCTAssertEqual(emailLabel.label(), "-")

        let versionLabel = AboutHelper.versionLabel.waitToExist()
        XCTAssertTrue(versionLabel.isVisible)

        let instructureLogo = AboutHelper.instructureLogo.waitToExist()
        XCTAssertTrue(instructureLogo.isVisible)
    }

    func testPrivacyPolicy() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Privacy Policy", check if Safari app opens
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitToExist()
        XCTAssertTrue(privacyPolicy.isVisible)

        privacyPolicy.tap()

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
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Terms of Use", check elements
        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitToExist()
        XCTAssertTrue(termsOfUse.isVisible)

        termsOfUse.tap()

        let termsOfUseNavBar = SubSettingsHelper.termsOfUseNavBar.waitToExist()
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
        let navBar = Helper.navBar.waitToExist()
        let doneButton = Helper.doneButton.waitToExist()
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select "Canvas on GitHub", check if Safari opens
        let canvasOnGitHub = Helper.menuItem(item: .canvasOnGitHub).waitToExist()
        XCTAssertTrue(canvasOnGitHub.isVisible)

        canvasOnGitHub.tap()

        let safariAppState = SafariAppHelper.safariApp.state
        XCTAssertEqual(safariAppState, .runningForeground)

        // MARK: Check URL
        let url = SafariAppHelper.browserURL
        XCTAssertEqual(url, "https://github.com/instructure/canvas-ios")
    }
}
