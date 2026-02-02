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

class OfflineTests: OfflineE2ETestCase {
    func testNetworkConnectionLose() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in
        logInDSUser(student)

        // MARK: Go offline and check app behaviour
        let isOffline = setNetworkStateOffline()
        var offlineLine = DashboardHelper.offlineLine.waitUntil(.visible)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(isOffline)
        XCTAssertVisible(offlineLine)
        XCTAssertVisible(profileButton)

        profileButton.hit()
        let offlineLabel = ProfileHelper.offlineLabel.waitUntil(.visible)
        XCTAssertVisible(offlineLabel)

        // MARK: Go back online and check app behaviour
        profileButton.forceTap()
        let isOnline = setNetworkStateOnline()
        offlineLine = DashboardHelper.offlineLine.waitUntil(.vanish)
        XCTAssertTrue(isOnline)
        XCTAssertTrue(offlineLine.isVanished)
        XCTAssertVisible(profileButton.waitUntil(.visible))

        profileButton.hit()
        XCTAssertTrue(offlineLabel.waitUntil(.vanish).isVanished)
    }

    func testOfflineSynchronizationSetting() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, navigate to Settings
        logInDSUser(student)
        SettingsHelper.navigateToSettings()
        let navBar = SettingsHelper.navBar.waitUntil(.visible)
        let doneButton = SettingsHelper.doneButton.waitUntil(.visible)
        XCTAssertVisible(navBar)
        XCTAssertVisible(doneButton)

        // MARK: Select Synchronization, check elements
        let offlineSync = SettingsHelper.menuItem(item: .synchronization).waitUntil(.visible)
        let valueOfOfflineSync = SettingsHelper.valueOfMenuItem(item: .synchronization)!.waitUntil(.visible)
        XCTAssertVisible(offlineSync)
        XCTAssertVisible(valueOfOfflineSync)
        XCTAssertEqual(valueOfOfflineSync.label, "Manual")

        offlineSync.hit()

        let autoContentSyncSwitch = SettingsHelper.OfflineSync.autoContentSyncSwitch.waitUntil(.visible)
        let backButton = SettingsHelper.OfflineSync.backButton.waitUntil(.visible)
        XCTAssertVisible(autoContentSyncSwitch)
        XCTAssertEqual(autoContentSyncSwitch.stringValue, "off")
        XCTAssertVisible(backButton)

        // MARK: Turn on "Auto Content Sync", check the changes
        autoContentSyncSwitch.hit()
        let syncFrequencyButton = SettingsHelper.OfflineSync.syncFrequencyButton.waitUntil(.visible)
        let syncContentOverWifiOnlySwitch = SettingsHelper.OfflineSync.wifiOnlySwitch.waitUntil(.visible)
        XCTAssertEqual(autoContentSyncSwitch.stringValue, "on")
        XCTAssertVisible(syncFrequencyButton)
        XCTAssertContains(syncFrequencyButton.label, "Daily")
        XCTAssertVisible(syncContentOverWifiOnlySwitch)
        XCTAssertEqual(syncContentOverWifiOnlySwitch.stringValue, "on")

        // MARK: Change "Sync Frequency" from "Daily" to "Weekly"
        syncFrequencyButton.hit()
        let asOsAllows = SettingsHelper.OfflineSync.SyncFrequency.asTheOsAllows.waitUntil(.visible)
        let daily = SettingsHelper.OfflineSync.SyncFrequency.daily.waitUntil(.visible)
        let weekly = SettingsHelper.OfflineSync.SyncFrequency.weekly.waitUntil(.visible)
        XCTAssertVisible(asOsAllows)
        XCTAssertVisible(daily)
        XCTAssertVisible(weekly)

        weekly.hit()
        syncFrequencyButton.waitUntil(.visible)
        XCTAssertVisible(syncFrequencyButton)
        XCTAssertContains(syncFrequencyButton.label, "Weekly")
        XCTAssertVisible(syncContentOverWifiOnlySwitch)
        XCTAssertEqual(syncContentOverWifiOnlySwitch.stringValue, "on")

        // MARK: Turn off "Sync Content Over Wifi Only"
        syncContentOverWifiOnlySwitch.hit()
        let turnOffWifiOnlySyncQuestion = SettingsHelper.OfflineSync.turnOffWifiOnlySyncStaticText.waitUntil(.visible)
        let turnOffButton = SettingsHelper.OfflineSync.turnOffButton.waitUntil(.visible)
        XCTAssertVisible(turnOffWifiOnlySyncQuestion)
        XCTAssertVisible(turnOffButton)

        turnOffButton.hit()
        syncContentOverWifiOnlySwitch.waitUntil(.value(expected: "off"))
        XCTAssertEqual(syncContentOverWifiOnlySwitch.stringValue, "off")
        XCTAssertVisible(backButton)

        backButton.hit()
        offlineSync.waitUntil(.visible)
        valueOfOfflineSync.waitUntil(.visible)
        XCTAssertVisible(offlineSync)
        XCTAssertVisible(valueOfOfflineSync)
        XCTAssertEqual(valueOfOfflineSync.label, "Weekly Auto")
    }

    func testManageOfflineContentScreen() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, open "Course Options", open "Manage Offline Content"
        logInDSUser(student)
        let courseOptionsButton = DashboardHelper.courseOptionsButton(course: course).waitUntil(.visible)
        XCTAssertVisible(courseOptionsButton)

        courseOptionsButton.hit()
        let manageOfflineContentButton = DashboardHelper.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertVisible(manageOfflineContentButton)

        manageOfflineContentButton.hit()

        // MARK: Check labels and buttons
        let headerLabel = DashboardHelper.Options.OfflineContent.headerLabel.waitUntil(.visible)
        let storageInfoLabel = DashboardHelper.Options.OfflineContent.storageInfoLabel.waitUntil(.visible)
        let courseButton = DashboardHelper.Options.OfflineContent.courseButton(course: course)!.waitUntil(.visible)
        let unselectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent.unselectedTickerOfCourseButton(course: course)
            .waitUntil(.visible)
        let selectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent.selectedTickerOfCourseButton(course: course)
            .waitUntil(.vanish)
        let syncButton = DashboardHelper.Options.OfflineContent.syncButton.waitUntil(.visible)
        XCTAssertVisible(headerLabel)
        XCTAssertVisible(storageInfoLabel)
        XCTAssertVisible(courseButton)
        XCTAssertContains(courseButton.label, "Deselected")
        XCTAssertVisible(unselectedTickerOfCourseButton)
        XCTAssertTrue(selectedTickerOfCourseButton.isVanished)
        XCTAssertVisible(syncButton)

        unselectedTickerOfCourseButton.hit()
        XCTAssertContains(courseButton.waitUntil(.labelContaining(expected: "Selected")).label, "Selected")
        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertVisible(selectedTickerOfCourseButton.waitUntil(.visible))
        XCTAssertTrue(syncButton.waitUntil(.enabled).isEnabled)

        selectedTickerOfCourseButton.hit()
        XCTAssertContains(courseButton.waitUntil(.labelContaining(expected: "Deselected")).label, "Deselected")
        XCTAssertVisible(unselectedTickerOfCourseButton.waitUntil(.visible))
        XCTAssertTrue(selectedTickerOfCourseButton.waitUntil(.vanish).isVanished)

        courseButton.hit()
        let discussionsButton = DashboardHelper.Options.OfflineContent.discussionsButton.waitUntil(.visible)
        let gradesButton = DashboardHelper.Options.OfflineContent.gradesButton.waitUntil(.visible)
        let peopleButton = DashboardHelper.Options.OfflineContent.peopleButton.waitUntil(.visible)
        let syllabusButton = DashboardHelper.Options.OfflineContent.syllabusButton.waitUntil(.visible)
        let bigBlueButtonButton = DashboardHelper.Options.OfflineContent.bigBlueButtonButton.waitUntil(.visible)
        XCTAssertVisible(discussionsButton)
        XCTAssertVisible(gradesButton)
        XCTAssertVisible(peopleButton)
        XCTAssertVisible(syllabusButton)
        XCTAssertVisible(bigBlueButtonButton)

        discussionsButton.hit()
        let partiallySelectedTickerOfCourse = DashboardHelper.Options.OfflineContent.partiallySelectedTickerOfCourseButton(course: course)
            .waitUntil(.visible)
        XCTAssertContains(courseButton.waitUntil(.labelContaining(expected: "Partially selected")).label, "Partially selected")
        XCTAssertVisible(partiallySelectedTickerOfCourse)
        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(selectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
    }

    func testOfflineContentSync() {
        // MARK: Seed the usual stuff with page, discussion, syllabus contents
        let student = seeder.createUser()
        let course = SyllabusHelper.createCourseWithSyllabus()
        let discussion = DiscussionsHelper.createDiscussion(course: course)
        PagesHelper.createPage(course: course)
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, open "Course Options", open "Manage Offline Content"
        logInDSUser(student)
        let courseOptionsButton = DashboardHelper.courseOptionsButton(course: course).waitUntil(.visible)
        XCTAssertVisible(courseOptionsButton)

        courseOptionsButton.hit()
        let manageOfflineContentButton = DashboardHelper.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertVisible(manageOfflineContentButton)

        manageOfflineContentButton.hit()

        // MARK: Select complete course to sync
        let courseButton = DashboardHelper.Options.OfflineContent.courseButton(course: course)!.waitUntil(.visible)
        let unselectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent.unselectedTickerOfCourseButton(course: course)
            .waitUntil(.visible)
        let syncButton = DashboardHelper.Options.OfflineContent.syncButton.waitUntil(.visible)
        XCTAssertVisible(courseButton)
        XCTAssertVisible(unselectedTickerOfCourseButton)
        XCTAssertVisible(syncButton)

        unselectedTickerOfCourseButton.hit()
        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = DashboardHelper.Options.OfflineContent.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = DashboardHelper.Options.OfflineContent.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = DashboardHelper.Options.OfflineContent.alertCancelButton.waitUntil(.visible)
        XCTAssertVisible(alertSyncOfflineContentLabel)
        XCTAssertVisible(alertCancelButton)
        XCTAssertVisible(alertSyncButton)

        alertSyncButton.hit()
        let successNotification = SpringboardAppHelper.successNotification.waitUntil(.visible, timeout: 30)
        XCTAssertVisible(successNotification)

        // MARK: Go offline, check contents
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = DashboardHelper.offlineLine.waitUntil(.visible)
        XCTAssertVisible(offlineLineImage)

        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        courseCard.hit()
        let discussionButton = CourseDetailsHelper.cell(type: .discussions).waitUntil(.visible)
        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitUntil(.visible)
        XCTAssertVisible(discussionButton)
        XCTAssertVisible(pagesButton)
        XCTAssertVisible(syllabusButton)

        // MARK: Check discussion
        discussionButton.hit()
        let discussionItem = DiscussionsHelper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertVisible(discussionItem)

        // MARK: Check page
        DashboardHelper.backButtonByIdOrLabel.hit()
        pagesButton.hit()
        let pagesItem = PagesHelper.page(index: 0).waitUntil(.visible)
        XCTAssertVisible(pagesItem)

        // MARK: Check syllabus
        DashboardHelper.backButtonByIdOrLabel.hit()
        syllabusButton.hit()
        let syllabusBody = SyllabusHelper.syllabusBody.waitUntil(.visible)
        XCTAssertVisible(syllabusBody)
    }

    func testOfflineCourseAvailabilityAndAlertMessageAndStarButton() {
        // Covers MBL-17063

        // MARK: Seed the usual stuff with courses, page, discussion, syllabus contents
        let student = seeder.createUser()
        let offlineCourse = SyllabusHelper.createCourseWithSyllabus()
        let onlineCourse = seeder.createCourse()
        DiscussionsHelper.createDiscussion(course: offlineCourse)
        PagesHelper.createPage(course: offlineCourse)
        seeder.enrollStudent(student, in: offlineCourse)
        seeder.enrollStudent(student, in: onlineCourse)

        // MARK: Get the user logged in, open "Dashboard Options", open "Manage Offline Content"
        logInDSUser(student)
        let dashboardOptionsButton = DashboardHelper.optionsButton.waitUntil(.visible)
        let offlineCourseCard = DashboardHelper.courseCard(course: offlineCourse).waitUntil(.visible)
        let onlineCourseCard = DashboardHelper.courseCard(course: onlineCourse).waitUntil(.visible)
        XCTAssertVisible(dashboardOptionsButton)
        XCTAssertVisible(offlineCourseCard)
        XCTAssertVisible(onlineCourseCard)

        dashboardOptionsButton.hit()
        let manageOfflineContentButton = DashboardHelper.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertVisible(manageOfflineContentButton)

        manageOfflineContentButton.hit()

        // MARK: Select pages of "offlineCourse" to sync
        let courseButton = DashboardHelper.Options.OfflineContent.courseButton(course: offlineCourse)!.waitUntil(.visible)
        let unselectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent
            .unselectedTickerOfCourseButton(course: offlineCourse).waitUntil(.visible)
        let partiallySelectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent
            .partiallySelectedTickerOfCourseButton(course: offlineCourse).waitUntil(.vanish)
        let syncButton = DashboardHelper.Options.OfflineContent.syncButton.waitUntil(.visible)
        XCTAssertVisible(courseButton)
        XCTAssertVisible(unselectedTickerOfCourseButton)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.isVanished)
        XCTAssertVisible(syncButton)

        courseButton.hit()
        let pagesButton = DashboardHelper.Options.OfflineContent.pagesButton.waitUntil(.visible)
        pagesButton.hit()

        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertVisible(partiallySelectedTickerOfCourseButton.waitUntil(.visible))

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = DashboardHelper.Options.OfflineContent.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = DashboardHelper.Options.OfflineContent.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = DashboardHelper.Options.OfflineContent.alertCancelButton.waitUntil(.visible)
        XCTAssertVisible(alertSyncOfflineContentLabel)
        XCTAssertVisible(alertCancelButton)
        XCTAssertVisible(alertSyncButton)

        alertSyncButton.hit()
        let successNotification = SpringboardAppHelper.successNotification.waitUntil(.visible, timeout: 30)
        XCTAssertVisible(successNotification)

        // MARK: Go offline, check contents
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = DashboardHelper.offlineLine.waitUntil(.visible)
        XCTAssertVisible(offlineLineImage)

        // MARK: Check "All Courses" button, check "Star" button is disabled
        let allCoursesButton = DashboardHelper.allCoursesButton.waitUntil(.visible)
        XCTAssertVisible(allCoursesButton)

        allCoursesButton.hit()
        let starButton = DashboardHelper.AllCourses.firstFavoriteButton().waitUntil(.visible)
        let backButton = DashboardHelper.backButtonByIdOrLabel.waitUntil(.visible)
        XCTAssertVisible(starButton)
        XCTAssertTrue(starButton.isDisabled)
        XCTAssertVisible(backButton)

        // MARK: Tap on "onlineCourse" card and check alert message
        backButton.hit()
        onlineCourseCard.hit()
        let notAvailableOfflineLabel = DashboardHelper.Options.OfflineContent.notAvailableOfflineLabel.waitUntil(.visible)
        let okButton = DashboardHelper.Options.OfflineContent.okButton.waitUntil(.visible)
        XCTAssertVisible(notAvailableOfflineLabel)
        XCTAssertVisible(okButton)

        okButton.hit()
        offlineCourseCard.hit()
        pagesButton.waitUntil(.visible, timeout: 90)
        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitUntil(.visible)
        XCTAssertVisible(pagesButton)
        XCTAssertVisible(syllabusButton)

        // MARK: Check syllabus is not available
        syllabusButton.hit()
        XCTAssertVisible(notAvailableOfflineLabel.waitUntil(.visible))
        XCTAssertVisible(okButton.waitUntil(.visible))

        // MARK: Check page
        okButton.hit()
        pagesButton.hit()
        let pagesItem = PagesHelper.page(index: 0).waitUntil(.visible)
        XCTAssertVisible(pagesItem)
    }
}
