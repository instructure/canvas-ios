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
import XCTest

class FeatureFlagOfflineTests: OfflineE2ETestCase {

    func testDiscussionsFallbackToNativeAppearanceWhenOffline() {
        // MARK: Seed the usual stuff with discussion and announcement
        let student = seeder.createUser()
        let course = seeder.createCourse()
        let discussion = DiscussionsHelper.createDiscussion(course: course)
        AnnouncementsHelper.createAnnouncement(course: course)
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
        let announcementsButton = CourseDetailsHelper.cell(type: .announcements).waitUntil(.visible, timeout: 60)
        let discussionButton = CourseDetailsHelper.cell(type: .discussions).waitUntil(.visible)
        XCTAssertVisible(announcementsButton)
        XCTAssertVisible(discussionButton)

        announcementsButton.hit()
        let announcementItem = AnnouncementsHelper.cell(index: 0).waitUntil(.visible)
        XCTAssertVisible(announcementItem)

        announcementItem.hit()
        let announcementTitleItem = AnnouncementsHelper.Details.title.waitUntil(.visible)
        let announcementBodyItem = AnnouncementsHelper.Details.message.waitUntil(.visible)
        let backButton = AnnouncementsHelper.backButton.waitUntil(.visible)
        XCTAssertVisible(announcementTitleItem)
        XCTAssertVisible(announcementBodyItem)
        XCTAssertVisible(backButton)

        backButton.hit()
        XCTAssertTrue(announcementItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(backButton.waitUntil(.visible).isVisible)

        backButton.hit()
        XCTAssertTrue(discussionButton.waitUntil(.visible).isVisible)

        discussionButton.hit()
        let discussionItem = DiscussionsHelper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertVisible(discussionItem)

        discussionItem.hit()
        let discussionTitleItem = DiscussionsHelper.Details.titleLabel.waitUntil(.visible)
        let discussionBodyItem = DiscussionsHelper.Details.messageLabel.waitUntil(.visible)
        XCTAssertVisible(discussionTitleItem)
        XCTAssertVisible(discussionBodyItem)
    }
}
