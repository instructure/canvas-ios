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

@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class GetAnnouncementsForCoursesTests: StudentTestCase {

    private static let testData = (
        courseId1: "course1",
        contextId1: "course_course1",
        courseId2: "course2",
        contextId2: "course_course2",
        announcementId1: "announcement1",
        announcementId2: "announcement2"
    )
    private lazy var testData = Self.testData

    // MARK: - cacheKey

    func test_cacheKey_shouldContainContextIds() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId1, testData.contextId2])

        XCTAssertEqual(testee.cacheKey, "announcementsForCourses(\(testData.contextId1),\(testData.contextId2))")
    }

    func test_cacheKey_shouldSortContextIdsAlphabetically() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId2, testData.contextId1])

        XCTAssertEqual(testee.cacheKey, "announcementsForCourses(\(testData.contextId1),\(testData.contextId2))")
    }

    // MARK: - request

    func test_request_shouldSetContextCodes() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId1, testData.contextId2])

        XCTAssertEqual(testee.request.contextCodes, [testData.contextId1, testData.contextId2])
    }

    func test_request_shouldUseAnnouncementsEndpoint() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId1])

        XCTAssertEqual(testee.request.path, "announcements")
    }

    // MARK: - scope

    func test_scope_shouldOrderByPostedAtDescending() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId1])

        XCTAssertEqual(testee.scope.order.first?.key, "postedAt")
        XCTAssertEqual(testee.scope.order.first?.ascending, false)
    }

    func test_scope_shouldIncludeAnnouncementsMatchingContextId() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId1])
        saveAnnouncement(id: testData.announcementId1, courseId: testData.courseId1)

        let result: [DiscussionTopic] = databaseClient.fetch(scope: testee.scope)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, testData.announcementId1)
    }

    func test_scope_shouldExcludeRegularDiscussions() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId1])
        saveDiscussion(id: testData.announcementId1, courseId: testData.courseId1)

        let result: [DiscussionTopic] = databaseClient.fetch(scope: testee.scope)

        XCTAssertEqual(result.count, 0)
    }

    func test_scope_shouldExcludeAnnouncementsFromOtherCourses() {
        let testee = GetAnnouncementsForCourses(courseContextIds: [testData.contextId1])
        saveAnnouncement(id: testData.announcementId1, courseId: testData.courseId2)

        let result: [DiscussionTopic] = databaseClient.fetch(scope: testee.scope)

        XCTAssertEqual(result.count, 0)
    }

    // MARK: - Private helpers

    private func saveAnnouncement(id: String, courseId: String) {
        DiscussionTopic.save(
            .make(
                html_url: URL(string: "https://canvas.instructure.com/courses/\(courseId)/announcements/\(id)"),
                id: ID(id),
                subscription_hold: "topic_is_announcement"
            ),
            in: databaseClient
        )
    }

    private func saveDiscussion(id: String, courseId: String) {
        DiscussionTopic.save(
            .make(
                html_url: URL(string: "https://canvas.instructure.com/courses/\(courseId)/discussion_topics/\(id)"),
                id: ID(id),
                subscription_hold: nil
            ),
            in: databaseClient
        )
    }
}
