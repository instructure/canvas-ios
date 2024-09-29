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
        let announcementsButton = CourseDetailsHelper.cell(type: .announcements).waitUntil(.visible, timeout: 60)
        let discussionButton = CourseDetailsHelper.cell(type: .discussions).waitUntil(.visible)
        XCTAssertTrue(announcementsButton.isVisible)
        XCTAssertTrue(discussionButton.isVisible)

        announcementsButton.hit()
        let announcementItem = AnnouncementsHelper.cell(index: 0).waitUntil(.visible)
        XCTAssertTrue(announcementItem.isVisible)

        announcementItem.hit()
        let announcementTitleItem = AnnouncementsHelper.Details.title.waitUntil(.visible)
        let announcementBodyItem = AnnouncementsHelper.Details.message.waitUntil(.visible)
        let backButton = AnnouncementsHelper.backButton.waitUntil(.visible)
        XCTAssertTrue(announcementTitleItem.isVisible)
        XCTAssertTrue(announcementBodyItem.isVisible)
        XCTAssertTrue(backButton.isVisible)

        backButton.hit()
        XCTAssertTrue(announcementItem.waitUntil(.visible).isVisible)
        XCTAssertTrue(backButton.waitUntil(.visible).isVisible)

        backButton.hit()
        XCTAssertTrue(discussionButton.waitUntil(.visible).isVisible)

        discussionButton.hit()
        let discussionItem = DiscussionsHelper.discussionButton(discussion: discussion).waitUntil(.visible)
        XCTAssertTrue(discussionItem.isVisible)

        discussionItem.hit()
        let discussionTitleItem = DiscussionsHelper.Details.titleLabel.waitUntil(.visible)
        let discussionBodyItem = DiscussionsHelper.Details.messageLabel.waitUntil(.visible)
        XCTAssertTrue(discussionTitleItem.isVisible)
        XCTAssertTrue(discussionBodyItem.isVisible)
    }
}
