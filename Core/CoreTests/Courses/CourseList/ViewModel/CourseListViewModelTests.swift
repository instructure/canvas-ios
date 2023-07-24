//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import Combine

class CourseListViewModelTests: CoreTestCase {
    var mockInteractor: CourseListInteractorMock!
    var testee: CourseListViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = CourseListInteractorMock()
        testee = CourseListViewModel(mockInteractor)
    }

    func testReadsInteractorState() {
        mockInteractor.state.send(.error)

        XCTAssertEqual(testee.state, .error)
    }

    func testReadsInteractorData() {
        let data = CourseListSections(future: [
            CourseListItem.save(.make(name: "future"), enrollmentState: .invited_or_pending, in: databaseClient),
        ])
        mockInteractor.courseList.send(data)

        XCTAssertEqual(testee.sections.current, [])
        XCTAssertEqual(testee.sections.past, [])
        XCTAssertEqual(testee.sections.future.map { $0.name }, ["future"])

    }

    func testForwardsRefreshEventToInteractor() {
        let refreshed = expectation(description: "refresh finished")
        testee.refresh {
            refreshed.fulfill()
        }
        waitForExpectations(timeout: 1)

        XCTAssertTrue(mockInteractor.refreshCalled)
    }

    func testForwardsFilterChangesToInteractor() {
        testee.filter.send("test")
        XCTAssertEqual(mockInteractor.filter, "test")
    }
}

class CourseListInteractorMock: CourseListInteractor {
    // MARK: - Outputs
    var state = CurrentValueSubject<StoreState, Never>(.loading)
    var courseList = CurrentValueSubject<CourseListSections, Never>(.init())

    private(set) var refreshCalled = false
    private(set) var filter = ""

    // MARK: - Inputs
    func refresh() -> Future<Void, Never> {
        refreshCalled = true
        return Future { $0(.success(())) }
    }

    func setFilter(_ filter: String) -> Future<Void, Never> {
        self.filter = filter
        return Future { $0(.success(())) }
    }
}
