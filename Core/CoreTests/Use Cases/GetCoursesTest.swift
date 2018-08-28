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

class GetCoursesTest: CoreTestCase {
    let request = GetCoursesRequest(includeUnpublished: true)

    func testItCreatesCourses() {
        let course = APICourse.make(["id": "1", "name": "Course 1"])
        api.mock(request, value: [course], response: nil, error: nil)

        let getCourses = GetCourses(api: api, database: database)
        addOperationAndWait(getCourses)

        let courses: [Course] = dbClient.fetch()
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, "1")
        XCTAssertEqual(courses.first?.name, "Course 1")
    }

    func testItUpdatesCourses() {
        let stale = course(["id": "1", "name": "Old Name"])
        let new = APICourse.make(["id": "1", "name": "New Name"])
        api.mock(request, value: [new])

        let getCourses = GetCourses(api: api, database: database)
        addOperationAndWait(getCourses)

        XCTAssertEqual(stale.reload().name, "New Name")
    }

    func testItDeletesCoursesThatNoLongerExist() {
        let course = self.course()
        api.mock(request, value: [], response: nil, error: nil)

        let getCourses = GetCourses(api: api, database: database)
        addOperationAndWait(getCourses)

        let courses: [Course] = dbClient.fetch()
        XCTAssertFalse(courses.contains(course))
    }
}
