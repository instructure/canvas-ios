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
@testable import Core
import XCTest

class GetContextTests: CoreTestCase {
    func testCourse() {
        // given
        let request = GetCourseRequest(courseID: "1")
        let response = APICourse.make(["id": "1"])
        api.mock(request, value: response)

        // when
        let context = ContextModel(.course, id: "1")
        let getContext = GetContext(context: context, database: db, api: api)
        addOperationAndWait(getContext)

        // then
        let courses: [Course] = db.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.count, 1)
    }

    func testGroup() {
        // given
        let request = GetGroupRequest(id: "1")
        let response = APIGroup.make(["id": "1"])
        api.mock(request, value: response)

        // when
        let context = ContextModel(.group, id: "1")
        let getContext = GetContext(context: context, database: db, api: api)
        addOperationAndWait(getContext)

        // then
        let groups: [Group] = db.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(groups.count, 1)
    }

    func testItHasATTL() {
        // given
        let course = self.course()
        let request = GetCourseRequest(courseID: course.id)
        let response = APICourse.make(["id": course.id, "name": "Old Name"])
        api.mock(request, value: response)
        let context = ContextModel(.course, id: course.id)
        let getContext1 = GetContext(context: context, database: db, api: api)
        // refresh once to set TTL
        addOperationAndWait(getContext1)

        // when
        let updatedResponse = APICourse.make(["id": course.id, "name": "New Name"])
        api.mock(request, value: updatedResponse)
        let getContext2 = GetContext(context: context, database: db, api: api)
        addOperationAndWait(getContext2)

        // then
        db.refresh()
        XCTAssertEqual(course.name, "Old Name")
    }

    func testForce() {
        // given
        let course = self.course()
        let request = GetCourseRequest(courseID: course.id)
        let response = APICourse.make(["id": course.id, "name": "Old Name"])
        api.mock(request, value: response)
        let context = ContextModel(.course, id: course.id)
        let getContext1 = GetContext(context: context, database: db, api: api)
        // refresh once to set TTL
        addOperationAndWait(getContext1)

        // when
        let updatedResponse = APICourse.make(["id": course.id, "name": "New Name"])
        api.mock(request, value: updatedResponse)
        let getContext2 = GetContext(context: context, database: db, api: api, force: true)
        addOperationAndWait(getContext2)

        // then
        db.refresh()
        XCTAssertEqual(course.name, "New Name")
    }

}
