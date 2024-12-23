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

import Combine
@testable import Core
import XCTest

class AllCoursesViewModelTests: CoreTestCase {
    var mockInteractor: AllCoursesInteractorMock!
    var testee: AllCoursesViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = AllCoursesInteractorMock()
        testee = AllCoursesViewModel(mockInteractor)
    }

    func testInitialLoadingState() {
        XCTAssertEqual(testee.state, .loading)
    }

    func testEmptyState() {
        mockInteractor.sections.send(AllCoursesSections())
        XCTAssertEqual(testee.state, .empty)
    }

    func testErrorState() {
        mockInteractor.sections.send(completion: .failure(NSError.instructureError("failed")))
        XCTAssertEqual(testee.state, .error)
    }

    func testDataState() {
        let data = AllCoursesSections(
            courses: .init(future: [.make(courseId: "future", enrollmentState: "future")]),
            groups: [.make(id: "1")]
        )
        mockInteractor.sections.send(data)
        let state = testee.state
        if case let .data(allCoursesSections) = state {
            XCTAssertEqual(allCoursesSections.courses.current, [])
            XCTAssertEqual(allCoursesSections.courses.past, [])
            XCTAssertEqual(allCoursesSections.courses.future.map { $0.courseId }, ["future"])
            XCTAssertEqual(allCoursesSections.groups.map { $0.id }, ["1"])
        } else {
            XCTFail("Expected data state")
        }
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

class AllCoursesInteractorMock: AllCoursesInteractor {
    private(set) var refreshCalled = false
    private(set) var loadAsyncCalled = false
    private(set) var filter = ""

    var sections = PassthroughSubject<Core.AllCoursesSections, Error>()

    // MARK: - Inputs

    func loadAsync() {
        loadAsyncCalled = true
    }

    func refresh() -> AnyPublisher<Void, Never> {
        refreshCalled = true
        return Just(()).eraseToAnyPublisher()
    }

    func setFilter(_ filter: String) -> AnyPublisher<Void, Never> {
        self.filter = filter
        return Just(()).eraseToAnyPublisher()
    }
}
