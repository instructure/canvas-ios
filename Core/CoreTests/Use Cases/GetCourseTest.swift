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

class GetCourseTest: CoreTestCase {
    func testItCreatesCourse() {
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make()
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", api: api, database: db)
        addOperationAndWait(getCourse)

        let courses: [Course] = db.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, response.id)
        XCTAssertEqual(courses.first?.name, response.name)
    }

    func testItUpdatesCourse() {
        let course = self.course(["id": "1", "name": "Old Name"])
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make(["id": "1", "name": "New Name"])
        api.mock(request, value: response)

        let getCourse = GetCourse(courseID: "1", api: api, database: db)
        addOperationAndWait(getCourse)

        XCTAssertEqual(course.name, "New Name")
    }
}
