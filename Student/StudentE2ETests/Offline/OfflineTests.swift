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

class OfflineTests: OfflineE2ETest {
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
        XCTAssertTrue(offlineLine.isVisible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        offlineLine = ProfileHelper.offlineLine.waitUntil(.visible)
        let offlineLabel = ProfileHelper.offlineLabel.waitUntil(.visible)
        XCTAssertTrue(offlineLine.isVisible)
        XCTAssertTrue(offlineLabel.isVisible)

        // MARK: Go back online and check app behaviour
        profileButton.forceTap()
        let isOnline = setNetworkStateOnline()
        offlineLine = DashboardHelper.offlineLine.waitUntil(.vanish)
        XCTAssertTrue(isOnline)
        XCTAssertTrue(offlineLine.isVanished)
        XCTAssertTrue(profileButton.waitUntil(.visible).isVisible)

        profileButton.hit()
        offlineLine = ProfileHelper.offlineLine.waitUntil(.vanish)
        XCTAssertTrue(offlineLine.isVanished)
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
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(doneButton.isVisible)

        // MARK: Select Synchronization, check elements
        let offlineSync = SettingsHelper.menuItem(item: .synchronization).waitUntil(.visible)
        let valueOfOfflineSync = SettingsHelper.valueOfMenuItem(item: .synchronization)!.waitUntil(.visible)
        XCTAssertTrue(offlineSync.isVisible)
        XCTAssertTrue(valueOfOfflineSync.isVisible)
        XCTAssertTrue(valueOfOfflineSync.hasLabel(label: "Manual"))

        offlineSync.hit()

        let autoContentSyncSwitch = SettingsHelper.OfflineSync.autoContentSyncSwitch.waitUntil(.visible)
        let backButton = SettingsHelper.OfflineSync.backButton.waitUntil(.visible)
        XCTAssertTrue(autoContentSyncSwitch.isVisible)
        XCTAssertTrue(autoContentSyncSwitch.hasValue(value: "0"))
        XCTAssertTrue(backButton.isVisible)

        // MARK: Turn on "Auto Content Sync", check the changes
        autoContentSyncSwitch.hit()
        let syncFrequencyButton = SettingsHelper.OfflineSync.syncFrequencyButton.waitUntil(.visible)
        let syncContentOverWifiOnlySwitch = SettingsHelper.OfflineSync.wifiOnlySwitch.waitUntil(.visible)
        XCTAssertTrue(autoContentSyncSwitch.hasValue(value: "1"))
        XCTAssertTrue(syncFrequencyButton.isVisible)
        XCTAssertTrue(syncFrequencyButton.hasLabel(label: "Daily", strict: false))
        XCTAssertTrue(syncContentOverWifiOnlySwitch.isVisible)
        XCTAssertTrue(syncContentOverWifiOnlySwitch.hasValue(value: "1"))

        // MARK: Change "Sync Frequency" from "Daily" to "Weekly"
        syncFrequencyButton.hit()
        let asOsAllows = SettingsHelper.OfflineSync.SyncFrequency.asTheOsAllows.waitUntil(.visible)
        let daily = SettingsHelper.OfflineSync.SyncFrequency.daily.waitUntil(.visible)
        let weekly = SettingsHelper.OfflineSync.SyncFrequency.weekly.waitUntil(.visible)
        XCTAssertTrue(asOsAllows.isVisible)
        XCTAssertTrue(daily.isVisible)
        XCTAssertTrue(weekly.isVisible)

        weekly.hit()
        syncFrequencyButton.waitUntil(.visible)
        XCTAssertTrue(syncFrequencyButton.isVisible)
        XCTAssertTrue(syncFrequencyButton.hasLabel(label: "Weekly", strict: false))
        XCTAssertTrue(syncContentOverWifiOnlySwitch.isVisible)
        XCTAssertTrue(syncContentOverWifiOnlySwitch.hasValue(value: "1"))

        // MARK: Turn off "Sync Content Over Wifi Only"
        syncContentOverWifiOnlySwitch.hit()
        let turnOffWifiOnlySyncQuestion = SettingsHelper.OfflineSync.turnOffWifiOnlySyncStaticText.waitUntil(.visible)
        let turnOffButton = SettingsHelper.OfflineSync.turnOffButton.waitUntil(.visible)
        XCTAssertTrue(turnOffWifiOnlySyncQuestion.isVisible)
        XCTAssertTrue(turnOffButton.isVisible)

        turnOffButton.hit()
        syncContentOverWifiOnlySwitch.waitUntil(.value(expected: "0"))
        XCTAssertTrue(syncContentOverWifiOnlySwitch.hasValue(value: "0"))
        XCTAssertTrue(backButton.isVisible)

        backButton.hit()
        offlineSync.waitUntil(.visible)
        valueOfOfflineSync.waitUntil(.visible)
        XCTAssertTrue(offlineSync.isVisible)
        XCTAssertTrue(valueOfOfflineSync.isVisible)
        XCTAssertTrue(valueOfOfflineSync.hasLabel(label: "Weekly Auto"))
    }

    func testManageOfflineContentScreen() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in, open "Course Options", open "Manage Offline Content"
        logInDSUser(student)
        let courseOptionsButton = DashboardHelper.courseOptionsButton(course: course).waitUntil(.visible)
        XCTAssertTrue(courseOptionsButton.isVisible)

        courseOptionsButton.hit()
        let manageOfflineContentButton = DashboardHelper.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

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
        XCTAssertTrue(headerLabel.isVisible)
        XCTAssertTrue(storageInfoLabel.isVisible)
        XCTAssertTrue(courseButton.isVisible)
        XCTAssertTrue(courseButton.hasLabel(label: "Deselected", strict: false))
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(selectedTickerOfCourseButton.isVanished)
        XCTAssertTrue(syncButton.isVisible)

        unselectedTickerOfCourseButton.hit()
        XCTAssertTrue(courseButton.waitUntil(.labelContaining(expected: "Selected")).hasLabel(label: "Selected", strict: false))
        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(selectedTickerOfCourseButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(syncButton.waitUntil(.enabled).isEnabled)

        selectedTickerOfCourseButton.hit()
        XCTAssertTrue(courseButton.waitUntil(.labelContaining(expected: "Deselected")).hasLabel(label: "Deselected", strict: false))
        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(selectedTickerOfCourseButton.waitUntil(.vanish).isVanished)

        courseButton.hit()
        let discussionsButton = DashboardHelper.Options.OfflineContent.discussionsButton.waitUntil(.visible)
        let gradesButton = DashboardHelper.Options.OfflineContent.gradesButton.waitUntil(.visible)
        let peopleButton = DashboardHelper.Options.OfflineContent.peopleButton.waitUntil(.visible)
        let syllabusButton = DashboardHelper.Options.OfflineContent.syllabusButton.waitUntil(.visible)
        let bigBlueButtonButton = DashboardHelper.Options.OfflineContent.bigBlueButtonButton.waitUntil(.visible)
        XCTAssertTrue(discussionsButton.isVisible)
        XCTAssertTrue(gradesButton.isVisible)
        XCTAssertTrue(peopleButton.isVisible)
        XCTAssertTrue(syllabusButton.isVisible)
        XCTAssertTrue(bigBlueButtonButton.isVisible)

        discussionsButton.hit()
        let partiallySelectedTickerOfCourse = DashboardHelper.Options.OfflineContent.partiallySelectedTickerOfCourseButton(course: course)
            .waitUntil(.visible)
        XCTAssertTrue(courseButton.waitUntil(.labelContaining(expected: "Partially selected"))
            .hasLabel(label: "Partially selected", strict: false))
        XCTAssertTrue(partiallySelectedTickerOfCourse.isVisible)
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
        XCTAssertTrue(courseOptionsButton.isVisible)

        courseOptionsButton.hit()
        let manageOfflineContentButton = DashboardHelper.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

        manageOfflineContentButton.hit()

        // MARK: Select complete course to sync
        let courseButton = DashboardHelper.Options.OfflineContent.courseButton(course: course)!.waitUntil(.visible)
        let unselectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent.unselectedTickerOfCourseButton(course: course)
            .waitUntil(.visible)
        let syncButton = DashboardHelper.Options.OfflineContent.syncButton.waitUntil(.visible)
        XCTAssertTrue(courseButton.isVisible)
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(syncButton.isVisible)

        unselectedTickerOfCourseButton.hit()
        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = DashboardHelper.Options.OfflineContent.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = DashboardHelper.Options.OfflineContent.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = DashboardHelper.Options.OfflineContent.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let successNotification = SpringboardAppHelper.successNotification.waitUntil(.visible, timeout: 30)
        XCTAssertTrue(successNotification.isVisible)

        // MARK: Go offline, check contents
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = DashboardHelper.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        courseCard.hit()
        let discussionButton = CourseDetailsHelper.cell(type: .discussions).waitUntil(.visible)
        let pagesButton = CourseDetailsHelper.cell(type: .pages).waitUntil(.visible)
        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitUntil(.visible)
        XCTAssertTrue(discussionButton.isVisible)
        XCTAssertTrue(pagesButton.isVisible)
        XCTAssertTrue(syllabusButton.isVisible)

        // MARK: Check discussion
        discussionButton.hit()
        let discussionItem = DiscussionsHelper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionItem.isVisible)

        // MARK: Check page
        DashboardHelper.backButton.hit()
        pagesButton.hit()
        let pagesItem = PagesHelper.page(index: 0).waitUntil(.visible)
        XCTAssertTrue(pagesItem.isVisible)

        // MARK: Check syllabus
        DashboardHelper.backButton.hit()
        syllabusButton.hit()
        let syllabusBody = SyllabusHelper.syllabusBody.waitUntil(.visible)
        XCTAssertTrue(syllabusBody.isVisible)
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
        XCTAssertTrue(dashboardOptionsButton.isVisible)
        XCTAssertTrue(offlineCourseCard.isVisible)
        XCTAssertTrue(onlineCourseCard.isVisible)

        dashboardOptionsButton.hit()
        let manageOfflineContentButton = DashboardHelper.Options.manageOfflineContentButton.waitUntil(.visible)
        XCTAssertTrue(manageOfflineContentButton.isVisible)

        manageOfflineContentButton.hit()

        // MARK: Select pages of "offlineCourse" to sync
        let courseButton = DashboardHelper.Options.OfflineContent.courseButton(course: offlineCourse)!.waitUntil(.visible)
        let unselectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent
            .unselectedTickerOfCourseButton(course: offlineCourse).waitUntil(.visible)
        let partiallySelectedTickerOfCourseButton = DashboardHelper.Options.OfflineContent
            .partiallySelectedTickerOfCourseButton(course: offlineCourse).waitUntil(.vanish)
        let syncButton = DashboardHelper.Options.OfflineContent.syncButton.waitUntil(.visible)
        XCTAssertTrue(courseButton.isVisible)
        XCTAssertTrue(unselectedTickerOfCourseButton.isVisible)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.isVanished)
        XCTAssertTrue(syncButton.isVisible)

        courseButton.hit()
        let pagesButton = DashboardHelper.Options.OfflineContent.pagesButton.waitUntil(.visible)
        pagesButton.hit()

        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(partiallySelectedTickerOfCourseButton.waitUntil(.visible).isVisible)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = DashboardHelper.Options.OfflineContent.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = DashboardHelper.Options.OfflineContent.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = DashboardHelper.Options.OfflineContent.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let successNotification = SpringboardAppHelper.successNotification.waitUntil(.visible, timeout: 30)
        XCTAssertTrue(successNotification.isVisible)

        // MARK: Go offline, check contents
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = DashboardHelper.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        // MARK: Check "All Courses" button, check "Star" button is disabled
        let allCoursesButton = DashboardHelper.editButton.waitUntil(.visible)
        XCTAssertTrue(allCoursesButton.isVisible)

        allCoursesButton.hit()
        let starButton = DashboardHelper.favoriteButton.waitUntil(.visible)
        let backButton = DashboardHelper.backButton.waitUntil(.visible)
        XCTAssertTrue(starButton.isVisible)
        XCTAssertTrue(starButton.isDisabled)
        XCTAssertTrue(backButton.isVisible)

        // MARK: Tap on "onlineCourse" card and check alert message
        backButton.hit()
        onlineCourseCard.hit()
        let notAvailableOfflineLabel = DashboardHelper.Options.OfflineContent.notAvailableOfflineLabel.waitUntil(.visible)
        let okButton = DashboardHelper.Options.OfflineContent.okButton.waitUntil(.visible)
        XCTAssertTrue(notAvailableOfflineLabel.isVisible)
        XCTAssertTrue(okButton.isVisible)

        okButton.hit()
        offlineCourseCard.hit()
        pagesButton.waitUntil(.visible, timeout: 90)
        let syllabusButton = CourseDetailsHelper.cell(type: .syllabus).waitUntil(.visible)
        XCTAssertTrue(pagesButton.isVisible)
        XCTAssertTrue(syllabusButton.isVisible)

        // MARK: Check syllabus is not available
        syllabusButton.hit()
        XCTAssertTrue(notAvailableOfflineLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(okButton.waitUntil(.visible).isVisible)

        // MARK: Check page
        okButton.hit()
        pagesButton.hit()
        let pagesItem = PagesHelper.page(index: 0).waitUntil(.visible)
        XCTAssertTrue(pagesItem.isVisible)
    }
}
