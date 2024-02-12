//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class FeatureFlagOfflineTests: OfflineE2ETest {
    override func setUp() {
        // Enable discussion redesign feature flag before app start
        let featureFlagResponse = seeder.setFeatureFlag(featureFlag: .newDiscussion, state: .allowedOn)
        XCTAssertEqual(featureFlagResponse.state, DSFeatureFlagState.allowedOn.rawValue)

        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        // Disable discussion redesign feature flag
        let featureFlagResponse = seeder.setFeatureFlag(featureFlag: .newDiscussion, state: .off)
        XCTAssertEqual(featureFlagResponse.state, DSFeatureFlagState.off.rawValue)
    }

    func testDiscussionsButtonIsDisabledIfDiscussionRedesignIsEnabled() {
        // MARK: Seed the usual stuff with discussion and announcement
        let student = seeder.createUser()
        let course = seeder.createCourse()
        DiscussionsHelper.createDiscussion(course: course)
        AnnouncementsHelper.createAnnouncements(course: course)
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
        XCTAssertTrue(syncButton.isDisabled)

        unselectedTickerOfCourseButton.hit()
        XCTAssertTrue(unselectedTickerOfCourseButton.waitUntil(.vanish).isVanished)
        XCTAssertTrue(syncButton.waitUntil(.enabled).isEnabled)

        // MARK: Tap "Sync" button
        syncButton.hit()
        let alertSyncButton = DashboardHelper.Options.OfflineContent.alertSyncButton.waitUntil(.visible)
        let alertSyncOfflineContentLabel = DashboardHelper.Options.OfflineContent.alertSyncOfflineContentLabel.waitUntil(.visible)
        let alertCancelButton = DashboardHelper.Options.OfflineContent.alertCancelButton.waitUntil(.visible)
        XCTAssertTrue(alertSyncOfflineContentLabel.isVisible)
        XCTAssertTrue(alertCancelButton.isVisible)
        XCTAssertTrue(alertSyncButton.isVisible)

        alertSyncButton.hit()
        let syncingOfflineContentLabel = DashboardHelper.Options.OfflineContent.syncingOfflineContentLabel.waitUntil(.visible)
        XCTAssertTrue(syncingOfflineContentLabel.isVisible)

        syncingOfflineContentLabel.waitUntil(.vanish)
        XCTAssertTrue(syncingOfflineContentLabel.isVanished)

        // MARK: Go offline, check contents
        let isOffline = setNetworkStateOffline()
        XCTAssertTrue(isOffline)

        let offlineLineImage = DashboardHelper.offlineLine.waitUntil(.visible)
        XCTAssertTrue(offlineLineImage.isVisible)

        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        courseCard.hit()
        let announcementsButton = CourseDetailsHelper.cell(type: .announcements).waitUntil(.visible)
        let discussionButton = CourseDetailsHelper.cell(type: .discussions).waitUntil(.visible)
        XCTAssertTrue(announcementsButton.isVisible)
        XCTAssertTrue(discussionButton.isVisible)

        announcementsButton.hit()
        let offlineWarning = DashboardHelper.Options.OfflineContent.notAvailableOfflineLabel.waitUntil(.visible)
        let okButton = DashboardHelper.Options.OfflineContent.okButton.waitUntil(.visible)
        XCTAssertTrue(offlineWarning.isVisible)
        XCTAssertTrue(okButton.isVisible)

        okButton.hit()
        discussionButton.hit()
        XCTAssertTrue(offlineWarning.waitUntil(.visible).isVisible)
        XCTAssertTrue(okButton.waitUntil(.visible).isVisible)
    }
}
