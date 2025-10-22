//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Core
@testable import Horizon
import XCTest

final class NotificationInteractorTests: HorizonTestCase {
    func testGetNotifications() {
        // Given
        let testee = NotificationInteractorLive(userID: "123", formatter: NotificationFormatterMock())
        // When
        api.mock(
            GetActivitiesRequest(onlyActiveCourses: true),
            value: [APIActivity.make()]
        )
        api.mock(
            GetAccountNotificationsRequest(),
            value: [APIAccountNotification.make()]
        )
        api.mock(
            GetHCoursesProgressionRequest(userId: "123", horizonCourses: true),
            value: GetHCoursesProgressionResponse.make()
        )

        XCTAssertSingleOutputAndFinish(testee.getNotifications(ignoreCache: false)) { notifications in
            // Then
            XCTAssertEqual(notifications.count, 3)
            XCTAssertEqual(notifications[0].type, .dueDate)
            XCTAssertEqual(notifications[1].type, .scoreChanged)
            XCTAssertEqual(notifications[2].type, .announcement)
        }
    }

    func testGetUnreadNotificationCount() {
        // Given
        let testee = NotificationInteractorLive(userID: "123", formatter: NotificationFormatterMock())
        // When
        api.mock(
            GetActivitiesRequest(onlyActiveCourses: true),
            value: [APIActivity.make()]
        )
        api.mock(
            GetHCoursesProgressionRequest(userId: "123", horizonCourses: true),
            value: GetHCoursesProgressionResponse.make()
        )

        // Then
        XCTAssertSingleOutputEqualsAndFinish(testee.getUnreadNotificationCount(), 1)
    }

    func testMarkNotificationAsReadGloablAnnouncement() {
        // Given
        let testee = NotificationInteractorLive(userID: "123", formatter: NotificationFormatterMock())
        // When
        api.mock(
            GetActivitiesRequest(onlyActiveCourses: true),
            value: [APIActivity.make()]
        )
        api.mock(
            GetAccountNotificationsRequest(),
            value: [APIAccountNotification.make(id: "12")]
        )
        api.mock(
            GetHCoursesProgressionRequest(userId: "123", horizonCourses: true),
            value: GetHCoursesProgressionResponse.make()
        )

        api.mock(DeleteAccountNotification(id: "1"), value: .init())

        let notification = NotificationModel(
            id: "12",
            title: "Title 1",
            date: Date(),
            isRead: false,
            courseName: "Course 1",
            courseID: "1",
            enrollmentID: "enrollmentID-1",
            isScoreAnnouncement: false,
            type: .scoreChanged,
            announcementId: "announcementId-1",
            assignmentURL: URL(string: "https://course/1231/123"),
            htmlURL: nil,
            isGlobalNotification: true
        )
        XCTAssertSingleOutputAndFinish(testee.markNotificationAsRead(notification: notification)) { notifications in
            // Then
            XCTAssertEqual(notifications.count, 3)
        }
    }

    func testMarkNotificationAsReadNotifcation() {
        // Given
        let testee = NotificationInteractorLive(userID: "123", formatter: NotificationFormatterMock())
        // When
        api.mock(
            GetActivitiesRequest(onlyActiveCourses: true),
            value: [APIActivity.make()]
        )
        api.mock(
            GetAccountNotificationsRequest(),
            value: [APIAccountNotification.make(id: "12")]
        )
        api.mock(
            GetHCoursesProgressionRequest(userId: "123", horizonCourses: true),
            value: GetHCoursesProgressionResponse.make()
        )

        api.mock(MarkDiscussionTopicRead(context: .course("12"), topicID: "topicID-12", isRead: true), value: .init())
        let notification = NotificationModel(
            id: "12",
            title: "Title 1",
            date: Date(),
            isRead: false,
            courseName: "Course 1",
            courseID: "1",
            enrollmentID: "enrollmentID-1",
            isScoreAnnouncement: false,
            type: .scoreChanged,
            announcementId: "announcementId-1",
            assignmentURL: URL(string: "https://course/1231/123"),
            htmlURL: nil,
            isGlobalNotification: false
        )
        XCTAssertSingleOutputAndFinish(testee.markNotificationAsRead(notification: notification)) { notifications in
            // Then
            XCTAssertEqual(notifications.count, 3)
        }
    }
}
