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
        testee.getGroups()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { list in
                    XCTAssertEqual(list.map { $0.id }, ["1", "2"])
                }
            )
            .store(in: &subscriptions)
    }

    func testFilter() {
        testee
            .setFilter("b")
            .sink()
            .store(in: &subscriptions)

        testee.getGroups()
            .sink(receiveCompletion: { _ in }) { list in
                XCTAssertEqual(list.map { $0.id }, ["1"])
            }
            .store(in: &subscriptions)
    }

    func testRefresh() {
        var list: [AllCoursesGroupItem] = []

        testee.getGroups()
            .sink { _ in } receiveValue: { val in
                list = val
            }
            .store(in: &subscriptions)

        drainMainQueue()
        XCTAssertEqual(list.map { $0.id }, ["1", "2"])

        api.mock(
            GetAllCoursesGroupListUseCase(),
            value: [
                .make(id: "3", name: "xyz")
            ]
        )

        testee.refresh()
            .sink()
            .store(in: &subscriptions)

        drainMainQueue()
        XCTAssertEqual(list.map { $0.id }, ["3"])
    }

    func testTeacherReturnsEmptyList() {
        environment.app = .teacher
        testee = GroupListInteractorLive(shouldListGroups: false)
        testee.getGroups()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { list in
                    XCTAssertEqual(list.map { $0.id }, [])
                }
            )
            .store(in: &subscriptions)
    }
}
