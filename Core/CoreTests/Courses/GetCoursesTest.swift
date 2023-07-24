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

    func testGetUserCourses() {
        XCTAssertEqual(GetUserCourses(userID: "2").cacheKey, "users/2/courses")
        XCTAssertEqual(GetUserCourses(userID: "2").request.path, "courses")
        XCTAssertEqual(GetUserCourses(userID: "2").scope, Scope(
            predicate: NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.userID), "2"),
            order: [
                NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
                NSSortDescriptor(key: #keyPath(Course.id), ascending: true),
            ]
        ))
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

    func testUpdateCourse() {
        let useCase = UpdateCourse(courseID: "1", name: "New Course Name", defaultView: .wiki, syllabusBody: "Syllabus", syllabusSummary: true)
        XCTAssertEqual(useCase.cacheKey, nil)
        XCTAssertEqual(useCase.request.courseID, "1")

        Course.make(from: .make(id: "1", name: "c", default_view: .assignments))
        let settingsUseCase = GetCourseSettings(courseID: "1")
        settingsUseCase.write(response: .make(), urlResponse: nil, to: databaseClient)

        useCase.write(response: .make(name: "New Course Name", default_view: .wiki), urlResponse: nil, to: databaseClient)

        let course: Course? = databaseClient.first(where: #keyPath(Course.id), equals: "1")
        XCTAssertEqual(course?.syllabusBody, "Syllabus")
        XCTAssertEqual(course?.name, "New Course Name")
        XCTAssertEqual(course?.defaultView, .wiki)

        let settings: CourseSettings? = databaseClient.first(where: #keyPath(CourseSettings.courseID), equals: "1")
        XCTAssertEqual(settings?.syllabusCourseSummary, true)
    }

    func testAllCoursesScopeHidesDeleted() {
        Course.make(from: .make(id: "1", name: "a", workflow_state: .deleted))
        let b = Course.make(from: .make(id: "2", name: "b", workflow_state: .available))
        let enrollement = APIEnrollment.make(enrollment_state: .deleted)
        Course.make(from: .make(id: "3", name: "c", enrollments: [enrollement]))
        let useCase = GetAllCourses()
        let courses: [Course] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first, b)
    }

    func testAllCoursesScopeHidesUnpublishedForStudent() {
        environment.app = .student
        Course.make(from: .make(id: "1", name: "a"))
        let b = Course.make(from: .make(id: "2", name: "b", workflow_state: .available))
        let useCase = GetAllCourses()
        let courses: [Course] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first, b)
    }

    func testAllCoursesScopeShowsUnpublishedForTeacher() {
        environment.app = .teacher
        Course.make(from: .make(id: "1", name: "a"))
        Course.make(from: .make(id: "2", name: "b", workflow_state: .available))
        let useCase = GetAllCourses()
        let courses: [Course] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)
        XCTAssertEqual(courses.count, 2)
    }

    func testMarkFavoriteCourse() {
        let course = Course.make(from: .make(id: "1", is_favorite: false))
        let courseListItem = CourseListItem.save(.make(id: "1", is_favorite: false),
                                                 enrollmentState: .active,
                                                 in: databaseClient)

        let testee = MarkFavoriteCourse(courseID: "1", markAsFavorite: true)
        testee.write(response: APIFavorite(context_id: ID("1"), context_type: "course"), urlResponse: nil, to: databaseClient)

        XCTAssertTrue(course.isFavorite)
        XCTAssertTrue(courseListItem.isFavorite)
    }
}
