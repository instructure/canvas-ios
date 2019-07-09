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
    let request = GetCoursesRequest(includeUnpublished: true)

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
        let useCase = GetCourses()
        XCTAssertEqual("get-courses", useCase.cacheKey)
    }

    func testRequest() {
        XCTAssertEqual(GetCourses().request.includeUnpublished, true)
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

    func testScopeShowAll() {
        let c = Course.make(from: .make(id: "3", name: "3", is_favorite: true))
        let a = Course.make(from: .make(id: "1", name: "1", is_favorite: true))
        Course.make(from: .make(id: "2", name: "2", is_favorite: true))

        let useCase = GetCourses()
        let courses: [Course] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(courses.count, 3)
        XCTAssertEqual(courses.first, a)
        XCTAssertEqual(courses.last, c)
    }
}
