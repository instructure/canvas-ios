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
import TestsFoundation

class GetCoursesTest: CoreTestCase {
    let request = GetCoursesRequest(includeUnpublished: true)

    func testItCreatesCourses() {
        let course = APICourse.make(id: "1", name: "Course 1")
        let getCourses = GetCourses()
        try! getCourses.write(response: [course], urlResponse: nil, to: databaseClient)

        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
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
        let c = Course.make(["name": "c", "isFavorite": true])
        let a = Course.make(["name": "a", "isFavorite": true])
        Course.make(["name": "b", "isFavorite": true])
        let d = Course.make(["name": "d", "isFavorite": false])
        let useCase = GetCourses(showFavorites: true)
        let courses: [Course] = databaseClient.fetch(predicate: useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertFalse(d.isFavorite)
        XCTAssertEqual(courses.count, 3)
        XCTAssertEqual(courses.first, a)
        XCTAssertEqual(courses.last, c)
    }

    func testScopeShowAll() {
        let c = Course.make(["name": "3", "isFavorite": true])
        let a = Course.make(["name": "1", "isFavorite": true])
        Course.make(["name": "2", "isFavorite": true])

        let useCase = GetCourses()
        let courses: [Course] = databaseClient.fetch(predicate: useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(courses.count, 3)
        XCTAssertEqual(courses.first, a)
        XCTAssertEqual(courses.last, c)
    }
}
