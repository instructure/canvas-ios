//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Student
@testable import TestsFoundation
import XCTest

final class CoursesInteractorTests: StudentTestCase {

    private var testee: CoursesInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        testee = CoursesInteractorLive(env: env)
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testParallelCalls_sharePublisher() {
        // MARK: Setup expectations and mock API
        let useCaseCallExpectation = expectation(description: "UseCase invoked exactly once")
        useCaseCallExpectation.expectedFulfillmentCount = 1
        useCaseCallExpectation.assertForOverFulfill = true

        let mocks = mockCourseRequests(
            active: [
                APICourse.make(id: "1", name: "Course 1"),
                APICourse.make(id: "2", name: "Course 2"),
                APICourse.make(id: "3", name: "Course 3")
            ],
            onActiveCalled: {
                useCaseCallExpectation.fulfill()
            }
        )
        mocks.active.suspend()
        mocks.completed.suspend()
        mocks.invited.suspend()

        // MARK: Create parallel subscriptions
        let expectation1 = expectation(description: "First call completes")
        let expectation2 = expectation(description: "Second call completes")
        let expectation3 = expectation(description: "Third call completes")

        var result1: CoursesResult?
        var result2: CoursesResult?
        var result3: CoursesResult?

        testee.getCourses()
            .sink(
                receiveCompletion: { _ in expectation1.fulfill() },
                receiveValue: { result1 = $0 }
            )
            .store(in: &subscriptions)

        testee.getCourses()
            .sink(
                receiveCompletion: { _ in expectation2.fulfill() },
                receiveValue: { result2 = $0 }
            )
            .store(in: &subscriptions)

        testee.getCourses()
            .sink(
                receiveCompletion: { _ in expectation3.fulfill() },
                receiveValue: { result3 = $0 }
            )
            .store(in: &subscriptions)

        // MARK: Resume mocks to trigger API responses
        mocks.active.resume()
        mocks.completed.resume()
        mocks.invited.resume()

        wait(
            for: [
                useCaseCallExpectation,
                expectation1,
                expectation2,
                expectation3
            ],
            timeout: 5
        )

        // MARK: Verify all subscribers received the same data
        XCTAssertEqual(result1?.allCourses.count, 3)
        XCTAssertEqual(result2?.allCourses.count, 3)
        XCTAssertEqual(result3?.allCourses.count, 3)

        let ids1 = result1?.allCourses.map { $0.id }.sorted()
        let ids2 = result2?.allCourses.map { $0.id }.sorted()
        let ids3 = result3?.allCourses.map { $0.id }.sorted()

        XCTAssertEqual(ids1, ["1", "2", "3"])
        XCTAssertEqual(ids2, ["1", "2", "3"])
        XCTAssertEqual(ids3, ["1", "2", "3"])
    }

    // MARK: - Helpers

    private func mockCourseRequests(
        active: [APICourse] = [],
        completed: [APICourse] = [],
        invited: [APICourse] = [],
        error: Error? = nil,
        onActiveCalled: (() -> Void)? = nil
    ) -> (active: APIMock, completed: APIMock, invited: APIMock) {
        let activeMock = api.mock(testee.useCase.activeRequest) { _ in
            onActiveCalled?()
            if let error {
                return (nil, nil, error)
            }
            return (active, nil, nil)
        }
        let completedMock = api.mock(testee.useCase.completedRequest, value: completed)
        let invitedMock = api.mock(testee.useCase.invitedRequest, value: invited)
        return (activeMock, completedMock, invitedMock)
    }
}
