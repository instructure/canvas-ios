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
import TestsFoundation

class GetCoursesTest: CoreTestCase {
    let request = GetCoursesRequest(includeUnpublished: true)

    func testItCreatesCourses() {
        let course = APICourse.make(["id": "1", "name": "Course 1"])
        api.mock(request, value: [course], response: nil, error: nil)

        let getCourses = GetCourses(env: environment)
        addOperationAndWait(getCourses)

        let courses: [Course] = db.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, "1")
        XCTAssertEqual(courses.first?.name, "Course 1")
    }

    func testItDeletesCoursesThatNoLongerExist() {
        let course = self.course()
        api.mock(request, value: [], response: nil, error: nil)

        let getCourses = GetCourses(env: environment)
        addOperationAndWait(getCourses)

        let courses: [Course] = db.fetch()
        XCTAssertFalse(courses.contains(course))
    }
}
