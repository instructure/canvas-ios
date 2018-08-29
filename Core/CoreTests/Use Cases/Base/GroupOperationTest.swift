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

class GroupOperationTest: CoreTestCase {
    func testItRunsOperations() {
        let coursesRequest = GetCoursesRequest(includeUnpublished: true)
        let groupsRequest = GetGroupsRequest(context: ContextModel.currentUser)

        let course = APICourse.make(["id": "1", "name": "Course 1"])
        api.mock(coursesRequest, value: [course], response: nil, error: nil)

        let group = APIGroup.make(["id": "2", "name": "Group 2", "member": true])
        api.mock(groupsRequest, value: [group], response: nil, error: nil)

        let getCourses = GetCourses(api: api, database: database)
        let getGroups = GetUserGroups(api: api, database: database)
        let grouped = GroupOperation(operations: [getCourses, getGroups])
        addOperationAndWait(grouped)

        let courses: [Course] = dbClient.fetch()
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, "1")
        XCTAssertEqual(courses.first?.name, "Course 1")

        let groups: [Group] = dbClient.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, "2")
        XCTAssertEqual(groups.first?.name, "Group 2")
        XCTAssertEqual(groups.first?.member, true)
    }
}
