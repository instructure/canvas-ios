//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class GetCoursesTest: CoreTestCase {
    let request = GetCoursesRequest()

    func testItCreatesCourses() {
        let course = APICourse.make(id: "1", name: "Course 1")
        let getCourses = GetCourses()
        getCourses.write(response: [course], urlResponse: nil, to: databaseClient)

        let courses: [Course] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, "1")
        XCTAssertEqual(courses.first?.name, "Course 1")
    }

    func testCache() {
        var useCase = GetCourses()
        XCTAssertEqual("get-courses-active", useCase.cacheKey)

        useCase = GetCourses(enrollmentState: .completed)
        XCTAssertEqual("get-courses-completed", useCase.cacheKey)

        useCase = GetCourses(enrollmentState: nil)
        XCTAssertEqual("get-courses", useCase.cacheKey)
    }

    func testRequest() {
        XCTAssertEqual(GetCourses().request.enrollmentState, .active)
        XCTAssertEqual(GetCourses(enrollmentState: .active).request.enrollmentState, .active)
        XCTAssertEqual(GetCourses(enrollmentState: .completed).request.enrollmentState, .completed)
        XCTAssertEqual(GetCourses(perPage: 123).request.perPage, 123)
    }

    func testScopeShowFavorites() {
        let c = Course.make(from: .make(id: "3", name: "c", is_favorite: true))
        let a = Course.make(from: .make(id: "1", name: "a", is_favorite: true))
        Course.make(from: .make(id: "2", name: "b", is_favorite: true))
        let d = Course.make(from: .make(id: "4", name: "d", is_favorite: false))
        let useCase = GetCourses(showFavorites: true)
        let courses: [Course] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertFalse(d.isFavorite)
        XCTAssertEqual(courses.count, 3)
        XCTAssertEqual(courses.first, a)
        XCTAssertEqual(courses.last, c)
    }

    func testScopeEnrollmentState() {
        let active = Course.make(from: .make(id: "1", enrollments: [.make(id: "1", enrollment_state: .active)]))
        let completed = Course.make(from: .make(id: "2", enrollments: [.make(id: "2", enrollment_state: .completed)]))
        var useCase = GetCourses(enrollmentState: .active)
        XCTAssertTrue(useCase.scope.predicate.evaluate(with: active))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: completed))

        useCase = GetCourses(enrollmentState: .completed)
        let courses: [Course] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 2)
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: active))
        XCTAssertTrue(useCase.scope.predicate.evaluate(with: completed))
    }

    func testScopeShowAll() {
        let c = Course.make(from: .make(id: "3", name: "3", is_favorite: true))
        let a = Course.make(from: .make(id: "1", name: "1", is_favorite: true))
        Course.make(from: .make(id: "2", name: "2", is_favorite: true))

        let useCase = GetCourses(enrollmentState: nil)
        let courses: [Course] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(courses.count, 3)
        XCTAssertEqual(courses.first, a)
        XCTAssertEqual(courses.last, c)
    }

    func testScopeOrder() {
        let one = Course.make(from: .make(id: "1", name: "A"))
        let two = Course.make(from: .make(id: "2", name: "B"))
        let three = Course.make(from: .make(id: "3", name: "B"))

        let useCase = GetCourses(enrollmentState: nil)
        let courses: [Course] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(courses.count, 3)
        XCTAssertEqual(courses[0], one)
        XCTAssertEqual(courses[1], two)
        XCTAssertEqual(courses[2], three)
    }

    func testGetCourse() {
        XCTAssertEqual(GetCourse(courseID: "72").cacheKey, "get-course-72")
        XCTAssertEqual(GetCourse(courseID: "5").scope, Scope.where(#keyPath(Course.id), equals: "5"))
        XCTAssertEqual(GetCourse(courseID: "2").request.courseID, "2")
    }

    func testGetCourseSettings() {
        let useCase = GetCourseSettings(courseID: "3")
        XCTAssertEqual(useCase.cacheKey, "courses/3/settings")
        XCTAssertEqual(useCase.request.courseID, "3")
        XCTAssertEqual(useCase.scope, .where(#keyPath(CourseSettings.courseID), equals: "3"))
        useCase.write(response: .make(), urlResponse: nil, to: databaseClient)
        let settings: [CourseSettings] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(settings.count, 1)
        XCTAssertEqual(settings.first?.courseID, "3")
    }
}
