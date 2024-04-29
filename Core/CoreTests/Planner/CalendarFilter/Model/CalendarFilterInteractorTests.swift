//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import XCTest

class CalendarFilterInteractorTests: CoreTestCase {

    override func setUp() {
        super.setUp()
        environment.userDefaults!.reset()
    }

    override func tearDown() {
        environment.userDefaults!.reset()
        super.tearDown()
    }

    func testClearsNoLongerAvailableSelectedContexts() {
        environment.userDefaults!.setCalendarSelectedContexts(
            Set([
                .course("1"),
                .course("2"),
                .group("1"),
                .group("2"),
            ]),
            observedStudentId: nil
        )
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: []
        )
        let groupsRequest = GetGroupsRequest(context: .currentUser)
        api.mock(coursesRequest, value: [.make(id: "2")])
        api.mock(groupsRequest, value: [.make(id: "2")])
        let testee = CalendarFilterInteractorLive(observedUserId: nil, env: environment)

        // WHEN
        XCTAssertFinish(testee.load(ignoreCache: false))

        // THEN
        XCTAssertEqual(environment.userDefaults!.calendarSelectedContexts(for: nil),
                       Set([
                        .course("2"),
                        .group("2"),
                       ]))
    }

    func testUpdatesSelectedContexts() {
        environment.userDefaults!.setCalendarSelectedContexts(
            Set([
                .course("c1"),
            ]),
            observedStudentId: nil
        )
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: []
        )
        let groupsRequest = GetGroupsRequest(context: .currentUser)
        api.mock(coursesRequest, value: [.make(id: "c1")])
        api.mock(groupsRequest, value: [.make(id: "g1")])
        let testee = CalendarFilterInteractorLive(observedUserId: nil, env: environment)

        // WHEN
        XCTAssertFinish(testee.load(ignoreCache: false))

        // THEN
        XCTAssertEqual(environment.userDefaults!.calendarSelectedContexts(for: nil), Set([.course("c1")]))
        XCTAssertEqual(testee.selectedContexts.value, Set([.course("c1")]))

        // WHEN
        XCTAssertFinish(testee.updateFilteredContexts([.course("c1")], isSelected: false))

        // THEN
        XCTAssertEqual(environment.userDefaults!.calendarSelectedContexts(for: nil), Set())
        XCTAssertEqual(testee.selectedContexts.value, Set())
    }

    func testSynchronizesSelectedContextsBetweenDifferentInteractors() {
        let coursesRequest = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: []
        )
        api.mock(coursesRequest, value: [.make(id: "c1")])

        let testee1 = CalendarFilterInteractorLive(observedUserId: nil, env: environment, scheduler: .immediate)
        let testee2 = CalendarFilterInteractorLive(observedUserId: nil, env: environment, scheduler: .immediate)
        XCTAssertEqual(testee1.selectedContexts.value, Set())
        XCTAssertEqual(testee2.selectedContexts.value, Set())

        // WHEN
        XCTAssertFinish(testee1.updateFilteredContexts([.course("c1")], isSelected: true))

        // THEN
        XCTAssertEqual(testee1.selectedContexts.value, Set([.course("c1")]))
        XCTAssertEqual(testee2.selectedContexts.value, Set([.course("c1")]))
    }
}
