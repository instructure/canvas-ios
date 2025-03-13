//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
@testable import Core
import XCTest

class InboxCoursePickerInteractorLiveTests: CoreTestCase {
    private var testee: InboxCoursePickerInteractorLive!

    override func setUp() {
        super.setUp()
        mockData()

        testee = InboxCoursePickerInteractorLive(env: environment)

        waitForState(.data)
    }

    func testPopulatesListItems() {
        XCTAssertEqual(testee.state.value, .data)

        XCTAssertEqual(testee.moreCourses.value.count, 2)
        XCTAssertEqual(testee.favoriteCourses.value.count, 1)
        XCTAssertEqual(testee.groups.value.count, 1)

        XCTAssertEqual(testee.moreCourses.value.first?.name, "Course 1")
        XCTAssertEqual(testee.favoriteCourses.value.first?.name, "Course 3 (favorite)")
        XCTAssertEqual(testee.groups.value.first?.name, "Group 1")
    }

    private func mockData() {
        let courses: [APICourse] = [
            .make(id: "1", name: "Course 1"),
            .make(id: "2", name: "Course 2"),
            .make(id: 3, name: "Course 3 (favorite)", is_favorite: true)
        ]

        let groups: [APIGroup] = [
            .make(id: "1", name: "Group 1")
        ]

        api.mock(GetCourses(), value: courses)
        api.mock(GetGroups(), value: groups)
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
