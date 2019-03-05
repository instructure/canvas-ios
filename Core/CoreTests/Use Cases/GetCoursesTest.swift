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
        let course = APICourse.make(["id": "1", "name": "Course 1"])
        let getCourses = GetCourses()
        try! getCourses.write(response: [course], urlResponse: nil, to: databaseClient)

        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, "1")
        XCTAssertEqual(courses.first?.name, "Course 1")
    }

    func testRequest() {
        XCTAssertEqual(GetCourses().request.includeUnpublished, true)
    }

    func testScope() {
        XCTAssertEqual(GetCourses().scope, Scope.all(orderBy: #keyPath(Course.name), ascending: true, naturally: true))
        XCTAssertEqual(GetCourses(showFavorites: true).scope, Scope.where(#keyPath(Course.isFavorite), equals: true, orderBy: #keyPath(Course.name)))
    }
}
