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

        // MARK: Check menu items of Settings
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        XCTAssertVisible(landingPage)

        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        XCTAssertVisible(appearance)

        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitUntil(.visible)
        XCTAssertVisible(pairWithObserver)

        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitUntil(.visible)
        XCTAssertVisible(subscribeToCalendarFeed)

        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        XCTAssertVisible(about)

        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        XCTAssertVisible(privacyPolicy)

        let offlineSync = Helper.menuItem(item: .synchronization).waitUntil(.visible)
        XCTAssertVisible(offlineSync)

        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        XCTAssertVisible(termsOfUse)
    }

    func testLandingPageSetting() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()

        let doneButton = Helper.doneButton.waitUntil(.visible)
        XCTAssertVisible(doneButton)

        // MARK: Select "Landing Page", check elements
        let landingPage = Helper.menuItem(item: .landingPage).waitUntil(.visible)
        XCTAssertVisible(landingPage)

        landingPage.hit()

        let landingPageNavBar = SubSettingsHelper.landingPageNavBar.waitUntil(.visible)
        let dashboard = SubSettingsHelper.landingPageMenuItem(item: .dashboard).waitUntil(.visible)
        let calendar = SubSettingsHelper.landingPageMenuItem(item: .calendar).waitUntil(.visible)
        let toDo = SubSettingsHelper.landingPageMenuItem(item: .todo).waitUntil(.visible)
        let notifications = SubSettingsHelper.landingPageMenuItem(item: .notifications).waitUntil(.visible)
        let inbox = SubSettingsHelper.landingPageMenuItem(item: .inbox).waitUntil(.visible)
        let backButton = SubSettingsHelper.backButton.waitUntil(.visible)
        XCTAssertVisible(landingPageNavBar)
        XCTAssertVisible(dashboard)
        XCTAssertVisible(calendar)
        XCTAssertVisible(toDo)
        XCTAssertVisible(notifications)
        XCTAssertVisible(inbox)
        XCTAssertVisible(backButton)

        // MARK: Select "Inbox", logout, login, check landing page
        inbox.hit()
        XCTAssertTrue(inbox.waitUntil(.visible).isVisible)

        backButton.hit()
        doneButton.hit()
        logOut()
        logInDSUser(student)
        let inboxNewMessageButton = InboxHelper.newMessageButton.waitUntil(.visible)
        XCTAssertVisible(inboxNewMessageButton)
    }

    func testAppearanceSetting() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()

        // MARK: Select "Appearance", check elements
        let appearance = Helper.menuItem(item: .appearance).waitUntil(.visible)
        XCTAssertVisible(appearance)

        appearance.hit()
        let appearanceNavBar = SubSettingsHelper.appearanceNavBar.waitUntil(.visible)
        let system = SubSettingsHelper.appearanceMenuItem(item: .system).waitUntil(.visible)
        let light = SubSettingsHelper.appearanceMenuItem(item: .light).waitUntil(.visible)
        let dark = SubSettingsHelper.appearanceMenuItem(item: .dark).waitUntil(.visible)
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

    func testPairWithObserverQRAppearance() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()

        // MARK: Select "Pair with Observer", check elements
        let pairWithObserver = Helper.menuItem(item: .pairWithObserver).waitUntil(.visible)
        XCTAssertVisible(pairWithObserver)

        pairWithObserver.hit()

        let pairWithObserverNavBar = SubSettingsHelper.pairWithObserverNavBar.waitUntil(.visible)
        XCTAssertVisible(pairWithObserverNavBar)

        let doneButton = SubSettingsHelper.doneButton.waitUntil(.visible)
        XCTAssertVisible(doneButton)

        let shareButton = SubSettingsHelper.shareButton.waitUntil(.visible)
        XCTAssertVisible(shareButton)

        let QRCodeImage = SubSettingsHelper.QRCodeImage.waitUntil(.visible)
        XCTAssertVisible(QRCodeImage)
    }

    func testSubscribeToCalendarFeed() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()

        // MARK: Select "Subscribe to Calendar Feed", check if Calendar app opens
        let subscribeToCalendarFeed = Helper.menuItem(item: .subscribeToCalendarFeed).waitUntil(.visible)
        XCTAssertVisible(subscribeToCalendarFeed)

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
        XCTAssertVisible(calendarNavBar)

        let subscriptionUrlElement = CalendarAppHelper.subscriptionUrl.waitUntil(.visible)
        XCTAssertVisible(subscriptionUrlElement)
        XCTAssertContains(subscriptionUrlElement.stringValue, user.host)
    }

    func testAbout() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()

        // MARK: Select About, check elements
        let about = Helper.menuItem(item: .about).waitUntil(.visible)
        XCTAssertVisible(about)

        about.hit()

        let aboutView = AboutHelper.aboutView.waitUntil(.visible)
        XCTAssertVisible(aboutView)

        let appLabel = AboutHelper.appLabel.waitUntil(.visible)
        XCTAssertVisible(appLabel)
        XCTAssertEqual(appLabel.label, "Canvas")

        let domainLabel = AboutHelper.domainLabel.waitUntil(.visible)
        XCTAssertVisible(domainLabel)
        XCTAssertEqual(domainLabel.label, "https://\(user.host)")

        let loginIdLabel = AboutHelper.loginIdLabel.waitUntil(.visible)
        XCTAssertVisible(loginIdLabel)
        XCTAssertEqual(loginIdLabel.label, student.id)

        let emailLabel = AboutHelper.emailLabel.waitUntil(.visible)
        XCTAssertVisible(emailLabel)
        XCTAssertEqual(emailLabel.label, "-")

        let versionLabel = AboutHelper.versionLabel.waitUntil(.visible)
        XCTAssertVisible(versionLabel)
    }

    func testPrivacyPolicy() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        Helper.navigateToSettings()

        // MARK: Select "Privacy Policy", check if Safari app opens
        let privacyPolicy = Helper.menuItem(item: .privacyPolicy).waitUntil(.visible)
        XCTAssertVisible(privacyPolicy)

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
        Helper.navigateToSettings()

        // MARK: Select "Terms of Use", check elements
        let termsOfUse = Helper.menuItem(item: .termsOfUse).waitUntil(.visible)
        XCTAssertVisible(termsOfUse)

        termsOfUse.hit()
        let termsOfUseNavBar = SubSettingsHelper.termsOfUseNavBar.waitUntil(.visible)
        XCTAssertVisible(termsOfUseNavBar)
    }
}
