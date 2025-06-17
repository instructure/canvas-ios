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
import XCTest

final class GetHScoresCourseUseCaseTests: CoreTestCase {
    func testRequest() {
        let useCase = GetScoresCourseUseCase(courseID: "course-123")
        let request = useCase.request

        XCTAssertEqual(request.courseID, "course-123")
        XCTAssertEqual(request.include, GetCourseRequest.defaultIncludes)
    }

    func testRequestWithCustomIncludes() {
        let customIncludes: [GetCourseRequest.Include] = [.term, .favorites]
        let useCase = GetScoresCourseUseCase(courseID: "course-123", include: customIncludes)
        let request = useCase.request

        XCTAssertEqual(request.courseID, "course-123")
        XCTAssertEqual(request.include, customIncludes)
    }

    func testCacheKey() {
        let useCase = GetScoresCourseUseCase(courseID: "course-123")

        XCTAssertEqual(useCase.cacheKey, "get-score-course-course-123")
    }

    func testScope() {
        let useCase = GetScoresCourseUseCase(courseID: "course-123")

        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(CDHScoresCourse.courseID), equals: "course-123"))
    }

    func testWrite() {
        let useCase = GetScoresCourseUseCase(courseID: "course-123")

        let apiCourse = APICourse.make(
            id: ID("course-123"),
            name: "Test Course",
            enrollments: [
                APIEnrollment.make(
                    user_id: "user-123",
                    computed_current_score: 95.5,
                    computed_current_grade: "A"
                )
            ],
            settings: APICourseSettings.make(
                restrict_quantitative_data: true
            )
        )

        useCase.write(response: apiCourse, urlResponse: nil, to: databaseClient)
        try? databaseClient.save()

        let courses: [CDHScoresCourse] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 1)

        let course = courses.first
        XCTAssertEqual(course?.courseID, "course-123")

        let enrollments = course?.enrollments.compactMap { $0 }
        XCTAssertEqual(enrollments?.count, 1)

        let enrollment = enrollments?.first
        XCTAssertEqual(enrollment?.courseID, "course-123")
        XCTAssertEqual(enrollment?.grade, "A")
        XCTAssertEqual(enrollment?.score?.doubleValue, 95.5)

        let settings = course?.settings
        XCTAssertNotNil(settings)
        XCTAssertEqual(settings?.restrictQuantitativeData, true)
    }

    func testWriteWithNilResponse() {
        let useCase = GetScoresCourseUseCase(courseID: "course-123")

        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let courses: [CDHScoresCourse] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 0)
    }
}
