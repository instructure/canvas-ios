//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core

class GetCourseTest: CoreTestCase {
    func testItCreatesCourse() {
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make()
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, response.id)
        XCTAssertEqual(courses.first?.name, response.name)
    }

    func testItCreatesCourseWithEnrollments() {
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make()
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.first?.enrollments?.first?.canvasContextID, "course_1")
        XCTAssertEqual(courses.first?.enrollments?.first?.state, .active)
    }

    func testItCreatesCourseWithEnrollmentsAndDeletesExistingEnrollments() {
        let enrollment = Enrollment.make(["stateRaw": "invited"])
        let a = Course.make(["enrollments": Set([enrollment])])
        XCTAssertGreaterThan(a.enrollments!.count, 0)
        XCTAssertEqual(a.enrollments?.first?.state, .invited)

        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make()
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        databaseClient.refresh()
        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.first?.enrollments?.first?.canvasContextID, "course_1")
        XCTAssertEqual(courses.first?.enrollments?.first?.state, .active)
    }

    func testItCreatesCourseWithEnrollmentsWithMissingRoleType() {
        let enrollment = Enrollment.make(["roleRaw": "ObserverEnrollment"])
        let a = Course.make(["enrollments": Set([enrollment])])
        XCTAssertGreaterThan(a.enrollments!.count, 0)
        XCTAssertNil(a.enrollments?.first?.role)

        let request = GetCourseRequest(courseID: "1")

        let response = APICourse.make(["enrollments": [APIEnrollment.fixture(["role": "foo"])]])
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        databaseClient.refresh()
        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.first?.enrollments?.first?.canvasContextID, "course_1")
        XCTAssertNil(courses.first?.enrollments?.first?.role)
    }

    func testItDeletesEnrollmentsIfNotReceivedInResponse() {
        let enrollment = Enrollment.make(["stateRaw": "invited"])
        let a = Course.make(["enrollments": Set([enrollment])])
        XCTAssertGreaterThan(a.enrollments!.count, 0)
        XCTAssertEqual(a.enrollments?.first?.state, .invited)

        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make(["enrollments": nil])
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)

        databaseClient.refresh()
        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        if let enrollments = courses.first?.enrollments {
            XCTAssertEqual(enrollments.count, 0)
        } else {
            XCTAssertNil(courses.first?.enrollments)
        }
    }

    func testItUpdatesCourse() {
        let course = Course.make(["id": "1", "name": "Old Name"])
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make(["id": "1", "name": "New Name"])
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", env: environment)
        addOperationAndWait(getCourse)
        databaseClient.refresh()
        XCTAssertEqual(course.name, "New Name")
    }

    func testCacheKey() {
        XCTAssertEqual(GetCourseUseCase(courseID: "72").cacheKey, "get-course-72")
    }

    func testScope() {
        XCTAssertEqual(GetCourseUseCase(courseID: "5").scope, Scope.where(#keyPath(Course.id), equals: "5"))
    }

    func testRequest() {
        XCTAssertEqual(GetCourseUseCase(courseID: "2").request.courseID, "2")
    }
}
