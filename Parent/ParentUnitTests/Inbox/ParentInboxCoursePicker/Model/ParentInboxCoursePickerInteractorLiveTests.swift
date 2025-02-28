//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Combine
import Core
@testable import Parent
import XCTest

class ParentInboxCoursePickerInteractorLiveTests: ParentTestCase {
    private var testee: ParentInboxCoursePickerInteractorLive!
    private var observerId: String!

    override func setUp() {
        super.setUp()
        observerId = env.currentSession?.userID ?? ""
        mockData()

        testee = ParentInboxCoursePickerInteractorLive(env: env)

        waitForState(.data)
    }

    func testPopulatesListItems() {
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.studentContextItems.value.count, 2)
        XCTAssertEqual(testee.studentContextItems.value[0].course.name, "Course 1")
        XCTAssertEqual(testee.studentContextItems.value[0].studentDisplayName, "Student 1")
        XCTAssertEqual(testee.studentContextItems.value[1].course.name, "Course 2")
        XCTAssertEqual(testee.studentContextItems.value[1].studentDisplayName, "Student 2")
    }

    private func mockData() {
        let course1 = APICourse.make(
            id: "1",
            name: "Course 1"
        )
        let course2 = APICourse.make(
            id: "2",
            name: "Course 2"
        )
        let courses = [course1, course2]
        let coursesExpectation = XCTestExpectation(description: "Request was sent")

        let enrollment1 = APIEnrollment.make(
            id: "1",
            course_id: "1",
            user_id: observerId,
            observed_user: APIUser.make(id: "1", name: "Student 1")
        )
        let enrollment2 = APIEnrollment.make(
            id: "2",
            course_id: "2",
            user_id: observerId,
            observed_user: APIUser.make(id: "2", name: "Student 2")
        )
        let enrollment3 = APIEnrollment.make(
            id: "3",
            course_id: "2",
            user_id: observerId
        )
        let enrollments = [enrollment1, enrollment2, enrollment3]
        let enrollmentsExpectation = XCTestExpectation(description: "Request was sent")

        api.mock(GetCourses(), expectation: coursesExpectation, value: courses)
        api.mock(GetObservedEnrollments(observerID: observerId), expectation: enrollmentsExpectation, value: enrollments)
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        let subscription = testee
            .state
            .sink {
                if $0 == state {
                    stateUpdate.fulfill()
                }
            }
        wait(for: [stateUpdate], timeout: 1)
        subscription.cancel()
    }
}
