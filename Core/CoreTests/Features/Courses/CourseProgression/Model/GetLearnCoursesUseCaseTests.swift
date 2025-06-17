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

@testable import Core
import CoreData
import TestsFoundation
import XCTest

class GetLearnCoursesUseCaseTests: CoreTestCase {
    func testCacheKey() {
        let useCase = GetLearnCoursesUseCase(userId: "user_123")
        XCTAssertEqual(useCase.cacheKey, "learn-courses")
    }

    func testRequestProperties() {
        let useCase = GetLearnCoursesUseCase(userId: "user_123")
        let request = useCase.request

        XCTAssertEqual(request.variables.id, "user_123")
        XCTAssertTrue(request.variables.horizonCourses)
    }

    func testWriteSavesLearnCoursesToCoreData() {
        let enrollment = GetCoursesProgressionResponse.EnrollmentModel(
            state: "active",
            id: "enroll_1",
            course: GetCoursesProgressionResponse.CourseModel(
                id: "course_1",
                name: "Learn Course 1",
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

        let useCase = GetLearnCoursesUseCase(userId: "user_123")
        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let learnCourses: [CDHLearnCourse] = databaseClient.fetch()
        XCTAssertEqual(learnCourses.count, 1)

        let savedCourse = learnCourses.first
        XCTAssertEqual(savedCourse?.id, "course_1")
        XCTAssertEqual(savedCourse?.name, "Learn Course 1")
        XCTAssertEqual(savedCourse?.enrollmentId, "enroll_1")
    }

    func testWriteWithMultipleEnrollments() {
        let enrollments = [
            GetCoursesProgressionResponse.EnrollmentModel(
                state: "active",
                id: "enroll_1",
                course: GetCoursesProgressionResponse.CourseModel(
                    id: "course_1",
                    name: "Learn Course 1",
                    account: nil,
                    imageUrl: nil,
                    syllabusBody: nil,
                    usersConnection: nil,
                    modulesConnection: nil
                )
            ),
            GetCoursesProgressionResponse.EnrollmentModel(
                state: "invited",
                id: "enroll_2",
                course: GetCoursesProgressionResponse.CourseModel(
                    id: "course_2",
                    name: "Learn Course 2",
                    account: nil,
                    imageUrl: nil,
                    syllabusBody: nil,
                    usersConnection: nil,
                    modulesConnection: nil
                )
            )
        ]

        let response = GetCoursesProgressionResponse(
            data: GetCoursesProgressionResponse.DataModel(
                user: GetCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: enrollments
                )
            )
        )

        let useCase = GetLearnCoursesUseCase(userId: "user_123")
        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let learnCourses: [CDHLearnCourse] = databaseClient.fetch()
        XCTAssertEqual(learnCourses.count, 2)

        let sortedCourses = learnCourses.sorted { (course1: CDHLearnCourse, course2: CDHLearnCourse) -> Bool in
            course1.id < course2.id
        }

        XCTAssertEqual(sortedCourses[0].id, "course_1")
        XCTAssertEqual(sortedCourses[0].name, "Learn Course 1")
        XCTAssertEqual(sortedCourses[0].enrollmentId, "enroll_1")

        XCTAssertEqual(sortedCourses[1].id, "course_2")
        XCTAssertEqual(sortedCourses[1].name, "Learn Course 2")
        XCTAssertEqual(sortedCourses[1].enrollmentId, "enroll_2")
    }

    func testWriteWithNilResponse() {
        let useCase = GetLearnCoursesUseCase(userId: "user_123")
        useCase.write(response: nil, urlResponse: nil, to: databaseClient)

        let learnCourses: [CDHLearnCourse] = databaseClient.fetch()
        XCTAssertEqual(learnCourses.count, 0)
    }

    func testWriteWithEmptyEnrollments() {
        let response = GetCoursesProgressionResponse(
            data: GetCoursesProgressionResponse.DataModel(
                user: GetCoursesProgressionResponse.LegacyNodeModel(
                    enrollments: []
                )
            )
        )

        let useCase = GetLearnCoursesUseCase(userId: "user_123")
        useCase.write(response: response, urlResponse: nil, to: databaseClient)

        let learnCourses: [CDHLearnCourse] = databaseClient.fetch()
        XCTAssertEqual(learnCourses.count, 0)
    }
}
