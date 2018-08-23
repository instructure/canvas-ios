//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
@testable import Core

class TestOperationQueue: OperationQueue {
    override init() {
        super.init()
        maxConcurrentOperationCount = 1
    }
}

class GetCoursesTest: XCTestCase {
    let api = MockAPI()
    let database = MockDatabase()
    let queue = TestOperationQueue()

    override func setUp() {
        super.setUp()
    }

    func testItStoresCourses() {
        let request = GetCoursesRequest(includeUnpublished: true)
        let one = APICourse.make(["id": "1"])
        let two = APICourse.make(["id": "2"])
        api.mock(request, value: [one, two], response: nil, error: nil)

        let getCourses = GetCourses(api: api, database: database)
        queue.addOperation(getCourses)
        queue.waitUntilAllOperationsAreFinished()

        let courses: [Course] = database.mainClient.fetch()
        XCTAssertEqual(courses.count, 2)
    }

    func testItDeletesCoursesThatNoLongerExist() {
        let course: Course = database.mainClient.insert()
        course.id = "1"
        course.name = "Course One"
        try! database.mainClient.save()

        let request = GetCoursesRequest(includeUnpublished: true)
        api.mock(request, value: [], response: nil, error: nil)

        let getCourses = GetCourses(api: api, database: database)
        queue.addOperation(getCourses)
        queue.waitUntilAllOperationsAreFinished()

        let courses: [Course] = database.mainClient.fetch()
        XCTAssertEqual(courses.count, 0)
    }
}
