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
        let getContext = GetContext(context: context, env: environment)
        addOperationAndWait(getContext)

        // then
        let courses: [Course] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(courses.count, 1)
    }

    func testItHasATTL() {
        // given
        let course = Course.make()
        let request = GetCourseRequest(courseID: course.id)
        let response = APICourse.make(["id": course.id, "name": "Old Name"])
        api.mock(request, value: response)
        let context = ContextModel(.course, id: course.id)
        let getContext1 = GetContext(context: context, env: environment)
        // refresh once to set TTL
        addOperationAndWait(getContext1)

        // when
        let updatedResponse = APICourse.make(["id": course.id, "name": "New Name"])
        api.mock(request, value: updatedResponse)
        let getContext2 = GetContext(context: context, env: environment)
        addOperationAndWait(getContext2)

        // then
        databaseClient.refresh()
        XCTAssertEqual(course.name, "Old Name")
    }

    func testForce() {
        // given
        let course = Course.make()
        let request = GetCourseRequest(courseID: course.id)
        let response = APICourse.make(["id": course.id, "name": "Old Name"])
        api.mock(request, value: response)
        let context = ContextModel(.course, id: course.id)
        let getContext1 = GetContext(context: context, env: environment)
        // refresh once to set TTL
        addOperationAndWait(getContext1)

        // when
        let updatedResponse = APICourse.make(["id": course.id, "name": "New Name"])
        api.mock(request, value: updatedResponse)
        let getContext2 = GetContext(context: context, env: environment, force: true)
        addOperationAndWait(getContext2)

        // then
        databaseClient.refresh()
        XCTAssertEqual(course.name, "New Name")
    }

}
