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
@testable import Horizon
import TestsFoundation
import XCTest

final class GetAnnouncementsUseCaseTests: HorizonTestCase {

    // MARK: - Cache Key Tests

    func testCacheKeyWithBasicParameters() {
        // Given
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1", "course-2"]
        )

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertEqual(cacheKey, "announcements(course_course-1,course_course-2),activeOnly=true,latestOnly=true")
    }

    func testCacheKeyWithSortedCourseIds() {
        // Given
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-3", "course-1", "course-2"]
        )

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertTrue(cacheKey?.contains("course_course-1,course_course-2,course_course-3") ?? false)
    }

    func testCacheKeyWithNilActiveOnly() {
        // Given
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1"],
            activeOnly: nil
        )

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertEqual(cacheKey, "announcements(course_course-1),latestOnly=true")
    }

    func testCacheKeyWithNilLatestOnly() {
        // Given
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1"],
            latestOnly: nil
        )

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertEqual(cacheKey, "announcements(course_course-1),activeOnly=true")
    }

    func testCacheKeyWithStartDate() {
        // Given
        let startDate = Date(timeIntervalSince1970: 1640995200)
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1"],
            startDate: startDate
        )

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertTrue(cacheKey?.contains("startDate=1640995200.0") ?? false)
    }

    func testCacheKeyWithEndDate() {
        // Given
        let endDate = Date(timeIntervalSince1970: 1672531200)
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1"],
            endDate: endDate
        )

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertTrue(cacheKey?.contains("endDate=1672531200.0") ?? false)
    }

    func testCacheKeyWithAllParameters() {
        // Given
        let startDate = Date(timeIntervalSince1970: 1640995200)
        let endDate = Date(timeIntervalSince1970: 1672531200)
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1", "course-2"],
            activeOnly: false,
            latestOnly: false,
            startDate: startDate,
            endDate: endDate
        )

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertNotNil(cacheKey)
        XCTAssertTrue(cacheKey?.contains("announcements(") ?? false)
        XCTAssertTrue(cacheKey?.contains("activeOnly=false") ?? false)
        XCTAssertTrue(cacheKey?.contains("latestOnly=false") ?? false)
        XCTAssertTrue(cacheKey?.contains("startDate=1640995200.0") ?? false)
        XCTAssertTrue(cacheKey?.contains("endDate=1672531200.0") ?? false)
    }

    func testCacheKeyWithEmptyCourseIds() {
        // Given
        let useCase = GetAnnouncementsUseCase(courseIds: [])

        // When
        let cacheKey = useCase.cacheKey

        // Then
        XCTAssertEqual(cacheKey, "announcements(),activeOnly=true,latestOnly=true")
    }

    // MARK: - Request Tests

    func testRequestCreationWithBasicParameters() {
        // Given
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1", "course-2"]
        )

        // When
        let request = useCase.request

        // Then
        XCTAssertEqual(request.contextCodes.count, 2)
        XCTAssertTrue(request.contextCodes.contains("course_course-1"))
        XCTAssertTrue(request.contextCodes.contains("course_course-2"))
        XCTAssertEqual(request.path, "announcements")
    }

    func testRequestCreationWithAllParameters() {
        // Given
        let startDate = Date(timeIntervalSince1970: 1640995200)
        let endDate = Date(timeIntervalSince1970: 1672531200)
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1"],
            activeOnly: false,
            latestOnly: false,
            startDate: startDate,
            endDate: endDate
        )

        // When
        let request = useCase.request

        // Then
        XCTAssertEqual(request.contextCodes.count, 1)
        XCTAssertTrue(request.contextCodes.contains("course_course-1"))
    }

    func testRequestContextCodesFormat() {
        // Given
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["123", "456", "789"]
        )

        // When
        let request = useCase.request

        // Then
        XCTAssertEqual(request.contextCodes.count, 3)
        request.contextCodes.forEach { contextCode in
            XCTAssertTrue(contextCode.hasPrefix("course_"))
        }
    }

    // MARK: - Scope Tests

    func testScopeConfiguration() {
        // Given
        let useCase = GetAnnouncementsUseCase(courseIds: ["course-1"])

        // When
        let scope = useCase.scope

        // Then
        XCTAssertEqual(scope.predicate.predicateFormat, "TRUEPREDICATE")
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, #keyPath(DiscussionTopic.postedAt))
        XCTAssertEqual(scope.order.first?.ascending, false)
    }

    // MARK: - Model Type Tests

    func testModelType() {
        // Given
        let useCase = GetAnnouncementsUseCase(courseIds: ["course-1"])

        // Then
        XCTAssertTrue(type(of: useCase).Model.self == DiscussionTopic.self)
    }

    func testUseCaseWithEmptyResponse() {
        // Given
        let now = Date.now
        let startDate = now.addYears(-1)
        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1"],
            startDate: startDate,
            endDate: now
        )

        api.mock(
            GetAllAnnouncementsRequest(
                contextCodes: ["course_course-1"],
                activeOnly: true,
                latestOnly: true,
                startDate: startDate,
                endDate: now
            ),
            value: []
        )

        // When & Then
        let store = ReactiveStore(useCase: useCase)
        XCTAssertSingleOutputAndFinish(store.getEntities(ignoreCache: true)) { topics in
            XCTAssertEqual(topics.count, 0)
        }
    }

    func testUseCaseOrdersByPostedAtDescending() {
        // Given
        let now = Date.now
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: now)!
        let startDate = now.addYears(-1)

        let useCase = GetAnnouncementsUseCase(
            courseIds: ["course-1"],
            startDate: startDate,
            endDate: now
        )

        api.mock(
            GetAllAnnouncementsRequest(
                contextCodes: ["course_course-1"],
                activeOnly: true,
                latestOnly: true,
                startDate: startDate,
                endDate: now
            ),
            value: [
                .make(
                    id: "old-announcement",
                    message: "Old announcement",
                    posted_at: twoDaysAgo,
                    title: "Old"
                ),
                .make(
                    id: "new-announcement",
                    message: "New announcement",
                    posted_at: now,
                    title: "New"
                ),
                .make(
                    id: "middle-announcement",
                    message: "Middle announcement",
                    posted_at: yesterday,
                    title: "Middle"
                )
            ]
        )

        // When & Then
        let store = ReactiveStore(useCase: useCase)
        XCTAssertSingleOutputAndFinish(store.getEntities(ignoreCache: true)) { topics in
            XCTAssertEqual(topics.count, 3)
            XCTAssertEqual(topics[0].id, "new-announcement")
            XCTAssertEqual(topics[1].id, "middle-announcement")
            XCTAssertEqual(topics[2].id, "old-announcement")
        }
    }
}
