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

class OperationSetTest: CoreTestCase {
    func testItRunsOperations() {
        let coursesRequest = GetCoursesRequest(includeUnpublished: true)
        let groupsRequest = GetGroupsRequest(context: ContextModel.currentUser)

        let course = APICourse.make(["id": "1", "name": "Course 1"])
        api.mock(coursesRequest, value: [course], response: nil, error: nil)

        let group = APIGroup.make(["id": "2", "name": "Group 2"])
        api.mock(groupsRequest, value: [group], response: nil, error: nil)

        let getCourses = GetCourses(env: environment)
        let getGroups = GetUserGroups(env: environment)
        let grouped = OperationSet(operations: [getCourses, getGroups])
        addOperationAndWait(grouped)

        XCTAssert(getCourses.errors.isEmpty)
        XCTAssert(getGroups.errors.isEmpty)

        let courses: [Course] = databaseClient.fetch()
        XCTAssertEqual(courses.count, 1)
        XCTAssertEqual(courses.first?.id, "1")
        XCTAssertEqual(courses.first?.name, "Course 1")

        let groups: [Group] = databaseClient.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, "2")
        XCTAssertEqual(groups.first?.name, "Group 2")
        XCTAssertEqual(groups.first?.showOnDashboard, true)
    }

    func testAddSequence() {
        let one = BlockOperation {}
        let two = BlockOperation {}
        let three = BlockOperation {}
        let group = OperationSet()

        group.addSequence([one, two, three])

        XCTAssertEqual(one.dependencies.count, 0)
        XCTAssertEqual(two.dependencies.count, 1)
        XCTAssertEqual(two.dependencies.first, one)
        XCTAssertEqual(three.dependencies.count, 1)
        XCTAssertEqual(three.dependencies.first, two)
    }
}
