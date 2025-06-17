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
import CoreData
import XCTest

class GetCoursesProgressionUseCaseTests: CoreTestCase {
    func testCacheKeyWithCourseId() {
        let useCase = GetCoursesProgressionUseCase(userId: "user_1", courseId: "course_123")
        XCTAssertEqual(useCase.cacheKey, "courses-progression-course_123")
    }

    func testCacheKeyWithoutCourseId() {
        let useCase = GetCoursesProgressionUseCase(userId: "user_1")
        XCTAssertEqual(useCase.cacheKey, "courses-progression")
    }

    func testRequestProperties() {
        let useCase = GetCoursesProgressionUseCase(userId: "user_1", horizonCourses: true)
        let request = useCase.request

        XCTAssertEqual(request.variables.id, "user_1")
        XCTAssertEqual(request.variables.horizonCourses, true)
    }

    func testScopeWithCourseId() {
        let useCase = GetCoursesProgressionUseCase(userId: "user_1", courseId: "course_123")
        let scope = useCase.scope

        XCTAssertEqual(scope.predicate.predicateFormat, "courseID == \"course_123\"")

        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "courseID")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
    }

    func testScopeWithoutCourseId() {
        let useCase = GetCoursesProgressionUseCase(userId: "user_1")
        let scope = useCase.scope

        XCTAssertTrue(scope.predicate.predicateFormat == "TRUEPREDICATE")

        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "objectID")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
    }

    func testWriteSavesCoursesToCoreData() {
        let enrollment = GetCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll_1",
            course: GetCoursesProgressionResponse.CourseModel(
                id: "course_1",
                name: "Test Course",
                account: nil,
                imageUrl: nil,
                syllabusBody: nil,
                usersConnection: nil,
                modulesConnection: nil
            )
        )

        let response = GetCoursesProgressionResponse(
            data: GetCoursesProgressionResponse.DataModel(
                user: GetCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: [enrollment]
                )
            )
        )

        let useCase = GetCoursesProgressionUseCase(userId: "user_1")
        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let cdCourses: [CDHCourse] = databaseClient.fetch(scope: .where(#keyPath(CDHCourse.courseID), equals: "course_1"))
        XCTAssertEqual(cdCourses.count, 1)
        XCTAssertEqual(cdCourses.first?.courseID, "course_1")
        XCTAssertEqual(cdCourses.first?.state, "active")
    }
}
