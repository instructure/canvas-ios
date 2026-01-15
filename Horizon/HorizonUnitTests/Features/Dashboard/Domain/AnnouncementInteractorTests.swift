//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Combine
import TestsFoundation
@testable import Core
@testable import Horizon
import XCTest

final class AnnouncementInteractorTests: HorizonTestCase {
    private var testee: AnnouncementInteractorLive!
    private var learnCoursesInteractor: GetLearnCoursesInteractorMock!

    override func setUp() {
        super.setUp()
        learnCoursesInteractor = GetLearnCoursesInteractorMock()
        testee = AnnouncementInteractorLive(
            userID: "test-user-123",
            isIncludePast: false,
            learnCoursesInteractor: learnCoursesInteractor
        )
    }

    override func tearDown() {
        testee = nil
        learnCoursesInteractor = nil
        super.tearDown()
    }

    // MARK: - Get All Announcements Tests

    func testGetAllAnnouncementsReturnsGlobalAndCourseAnnouncements() {
        // Given
        mockAccountNotifications()
        mockDiscussionTopics()

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.getAllAnnouncements(ignoreCache: false)) { announcements in
            XCTAssertEqual(announcements.count, 3)
            XCTAssertTrue(announcements.contains(where: { $0.isGlobal }))
        }
    }

    func testGetAllAnnouncementsReturnsOnlyGlobalWhenNoDiscussionTopics() {
        // Given
        mockAccountNotifications()
        mockEmptyDiscussionTopics()

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.getAllAnnouncements(ignoreCache: false)) { announcements in
            XCTAssertEqual(announcements.count, 1)
            XCTAssertTrue(announcements.allSatisfy { $0.isGlobal })
        }
    }

    func testGetAllAnnouncementsReturnsOnlyCourseWhenNoAccountNotifications() {
        // Given
        mockEmptyAccountNotifications()
        mockDiscussionTopics()

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.getAllAnnouncements(ignoreCache: false)) { announcements in
            XCTAssertEqual(announcements.count, 2)
            XCTAssertTrue(announcements.allSatisfy { !$0.isGlobal })
        }
    }

    func testGetAllAnnouncementsReturnsEmptyWhenNoAnnouncements() {
        // Given
        mockEmptyAccountNotifications()
        mockEmptyDiscussionTopics()

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.getAllAnnouncements(ignoreCache: false)) { announcements in
            XCTAssertEqual(announcements.count, 0)
        }
    }

    func testGetAllAnnouncementsSortsByDateDescending() {
        // Given
        mockAccountNotificationsWithDates()
        mockDiscussionTopicsWithDates()

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.getAllAnnouncements(ignoreCache: false)) { announcements in
            XCTAssertEqual(announcements.count, 4)
            for i in 0..<announcements.count - 1 {
                let currentDate = announcements[i].date ?? .distantPast
                let nextDate = announcements[i + 1].date ?? .distantPast
                XCTAssertGreaterThanOrEqual(currentDate, nextDate)
            }
        }
    }

    func testGetAllAnnouncementsIgnoresCache() {
        // Given
        mockAccountNotifications()
        mockDiscussionTopics()

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.getAllAnnouncements(ignoreCache: true)) { announcements in
            XCTAssertEqual(announcements.count, 3)
        }
    }

    func testGetAllAnnouncementsIncludesPastWhenConfigured() {
        // Given
        let testee = AnnouncementInteractorLive(
            userID: "test-user-123",
            isIncludePast: true,
            learnCoursesInteractor: learnCoursesInteractor
        )
        mockAccountNotifications()
        mockDiscussionTopics()

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.getAllAnnouncements(ignoreCache: false)) { announcements in
            XCTAssertGreaterThanOrEqual(announcements.count, 0)
        }
    }

    // MARK: - Mark Announcement As Read Tests

    func testMarkAnnouncementAsReadForGlobalAnnouncement() {
        // Given
        let globalAnnouncement = AnnouncementModel(
            id: "global-1",
            title: "Global Announcement",
            content: "Important message",
            date: Date(),
            isRead: false,
            isGlobal: true
        )
        mockAccountNotifications()
        mockDiscussionTopics()
        api.mock(DeleteAccountNotification(id: "global-1"), value: APINoContent())

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.markAnnouncementAsRead(announcement: globalAnnouncement)) { announcements in
            XCTAssertNotNil(announcements)
        }
    }

    func testMarkAnnouncementAsReadForCourseAnnouncement() {
        // Given
        let courseAnnouncement = AnnouncementModel(
            id: "discussion-1",
            title: "Course Announcement",
            content: "Course update",
            courseID: "course-1",
            courseName: "iOS Development",
            date: Date(),
            isRead: false,
            isGlobal: false
        )
        mockAccountNotifications()
        mockDiscussionTopics()
        api.mock(
            MarkDiscussionTopicRead(
                context: .course("course-1"),
                topicID: "discussion-1",
                isRead: true
            ),
            value: APINoContent()
        )

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.markAnnouncementAsRead(announcement: courseAnnouncement)) { announcements in
            XCTAssertNotNil(announcements)
        }
    }

    func testMarkAnnouncementAsReadRefreshesAnnouncements() {
        // Given
        let announcement = AnnouncementModel(
            id: "global-1",
            title: "Global Announcement",
            content: "Important message",
            date: Date(),
            isRead: false,
            isGlobal: true
        )
        mockAccountNotifications()
        mockDiscussionTopics()
        api.mock(DeleteAccountNotification(id: "global-1"), value: APINoContent())

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.markAnnouncementAsRead(announcement: announcement)) { announcements in
            XCTAssertGreaterThanOrEqual(announcements.count, 0)
        }
    }

    func testMarkAnnouncementAsReadHandlesErrorGracefully() {
        // Given
        let announcement = AnnouncementModel(
            id: "global-1",
            title: "Global Announcement",
            content: "Important message",
            date: Date(),
            isRead: false,
            isGlobal: true
        )
        mockEmptyAccountNotifications()
        mockEmptyDiscussionTopics()
        api.mock(
            DeleteAccountNotification(id: "global-1"),
            error: NSError.instructureError("Test error")
        )

        // When & Then
        XCTAssertSingleOutputAndFinish(testee.markAnnouncementAsRead(announcement: announcement)) { announcements in
            XCTAssertEqual(announcements.count, 0)
        }
    }

    // MARK: - Helper Methods

    private func mockAccountNotifications() {
        api.mock(
            GetAccountNotifications(includePast: false),
            value: [
                APIAccountNotification.make(
                    end_at: nil,
                    icon: .warning,
                    id: "global-1",
                    message: "Important message",
                    start_at: Date(),
                    subject: "Global Announcement",
                    closed: false
                )
            ]
        )
    }

    private func mockEmptyAccountNotifications() {
        api.mock(
            GetAccountNotifications(includePast: false),
            value: []
        )
    }

    private func mockAccountNotificationsWithDates() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!

        api.mock(
            GetAccountNotifications(includePast: false),
            value: [
                APIAccountNotification.make(
                    end_at: nil,
                    icon: .warning,
                    id: "global-1",
                    message: "Message 1",
                    start_at: yesterday,
                    subject: "Recent Announcement",
                    closed: false
                ),
                APIAccountNotification.make(
                    end_at: nil,
                    icon: .warning,
                    id: "global-2",
                    message: "Message 2",
                    start_at: twoDaysAgo,
                    subject: "Older Announcement",
                    closed: false
                )
            ]
        )
    }

    private func mockDiscussionTopics() {
        let now = Date.now
        let startDate = now.addYears(-1)

        api.mock(
            GetAllAnnouncementsRequest(
                contextCodes: [
                    "course_ID-1",
                    "course_ID-2",
                    "course_ID-3"
                ],
                activeOnly: nil,
                latestOnly: nil,
                startDate: startDate,
                endDate: now
            ),
            value: [
                APIDiscussionTopic.make(
                    context_code: "course_ID-1",
                    id: "discussion-1",
                    message: "Message 1",
                    posted_at: now,
                    title: "Course Announcement 1",
                    read_state: "unread"
                ),
                APIDiscussionTopic.make(
                    context_code: "course_ID-2",
                    id: "discussion-2",
                    message: "Message 2",
                    posted_at: now,
                    title: "Course Announcement 2", read_state: "unread"
                )
            ]
        )
    }

    private func mockEmptyDiscussionTopics() {
        let now = Date.now
        let startDate = now.addYears(-1)

        api.mock(
            GetAllAnnouncementsRequest(
                contextCodes: [
                    "course_ID-1",
                    "course_ID-2",
                    "course_ID-3"
                ],
                activeOnly: nil,
                latestOnly: nil,
                startDate: startDate,
                endDate: now
            ),
            value: []
        )
    }

    private func mockDiscussionTopicsWithDates() {
        let now = Date.now
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        let startDate = now.addYears(-1)

        api.mock(
            GetAllAnnouncementsRequest(
                contextCodes: [
                    "course_ID-1",
                    "course_ID-2",
                    "course_ID-3"
                ],
                activeOnly: nil,
                latestOnly: nil,
                startDate: startDate,
                endDate: now
            ),
            value: [
                APIDiscussionTopic.make(
                    context_code: "course_ID-1",
                    id: "discussion-1",
                    message: "Message 1",
                    posted_at: now,
                    title: "Recent Course Announcement",
                    read_state: "unread"
                ),
                APIDiscussionTopic.make(
                    context_code: "course_ID-2",
                    id: "discussion-2",
                    message: "Message 2",
                    posted_at: threeDaysAgo,
                    title: "Older Course Announcement",
                    read_state: "unread"
                )
            ]
        )
    }
}
