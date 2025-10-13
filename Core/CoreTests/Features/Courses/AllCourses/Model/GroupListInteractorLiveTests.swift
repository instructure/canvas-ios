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

class GroupListInteractorLiveTests: CoreTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private var testee: GroupListInteractorLive!

    override func setUp() {
        super.setUp()

        api.mock(
            GetAllCoursesGroupListUseCase(),
            value: [
                .make(id: "1", name: "abc"),
                .make(id: "2", name: "foe")
            ]
        )
        environment.app = .student
        testee = GroupListInteractorLive(shouldListGroups: true)
    }

    override func tearDown() {
        testee = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    func testPopulatesListItems() {
        XCTAssertFirstValue(testee.getGroups()) { list in
            XCTAssertEqual(list.map { $0.id }, ["1", "2"])
        }
    }

    func testFilter() {
        testee
            .setFilter("b")
            .sink()
            .store(in: &subscriptions)

        XCTAssertFirstValue(testee.getGroups()) { list in
            XCTAssertEqual(list.map { $0.id }, ["1"])
        }
    }

    func testRefresh() {
        XCTAssertFirstValue(testee.getGroups()) { list in
            XCTAssertEqual(list.map { $0.id }, ["1", "2"])
        }

        api.mock(
            GetAllCoursesGroupListUseCase(),
            value: [
                .make(id: "3", name: "xyz")
            ]
        )

        testee.refresh()
            .sink()
            .store(in: &subscriptions)

        XCTAssertFirstValue(testee.getGroups()) { list in
            XCTAssertEqual(list.map { $0.id }, ["3"])
        }
    }

    func testTeacherReturnsEmptyList() {
        environment.app = .teacher
        testee = GroupListInteractorLive(shouldListGroups: false)

        XCTAssertFirstValue(testee.getGroups()) { list in
            XCTAssertEqual(list.map { $0.id }, [])
        }
    }

    func test_getGroups_shouldFilterOutConcludedOrNotAccessibleGroups() {
        api.mock(
            GetAllCoursesGroupListUseCase(),
            value: [
                .make(id: "1", name: "active-accessible", concluded: false, can_access: true),
                .make(id: "2", name: "active-not-accessible", concluded: false, can_access: false),
                .make(id: "3", name: "concluded-accessible", concluded: true, can_access: true),
                .make(id: "4", name: "concluded-not-accessible", concluded: true, can_access: false),
                .make(id: "5", name: "another-active-accessible", concluded: false, can_access: true)
            ]
        )

        XCTAssertFirstValue(testee.getGroups()) { list in
            XCTAssertEqual(list.map { $0.id }, ["1", "5"])
            XCTAssertEqual(list.map { $0.name }, ["active-accessible", "another-active-accessible"])
        }
    }
}
