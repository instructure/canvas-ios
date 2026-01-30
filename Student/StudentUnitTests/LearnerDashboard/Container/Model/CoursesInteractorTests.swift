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

    func testMultipleCachedRequests_receiveSameData() {
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

        let expectation1 = expectation(description: "First call completes")
        let expectation2 = expectation(description: "Second call completes")
        let expectation3 = expectation(description: "Third call completes")

        var result1: CoursesResult?
        var result2: CoursesResult?
        var result3: CoursesResult?

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { _ in expectation1.fulfill() },
                receiveValue: { result1 = $0 }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { _ in expectation2.fulfill() },
                receiveValue: { result2 = $0 }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { _ in expectation3.fulfill() },
                receiveValue: { result3 = $0 }
            )
            .store(in: &subscriptions)

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

    func testFreshRequestDuringCached_triggersSecondFetch() {
        var activeCallCount = 0
        let firstFetchExpectation = expectation(description: "First fetch completes")
        let secondFetchExpectation = expectation(description: "Second fetch completes")

        let mocks = mockCourseRequests(
            active: [
                APICourse.make(id: "1", name: "Course 1"),
                APICourse.make(id: "2", name: "Course 2")
            ],
            onActiveCalled: {
                activeCallCount += 1
                if activeCallCount == 1 {
                    firstFetchExpectation.fulfill()
                } else if activeCallCount == 2 {
                    secondFetchExpectation.fulfill()
                }
            }
        )
        mocks.active.suspend()
        mocks.completed.suspend()
        mocks.invited.suspend()

        let cachedExpectation = expectation(description: "Cached request completes")
        let freshExpectation = expectation(description: "Fresh request completes")

        var cachedResult: CoursesResult?
        var freshResult: CoursesResult?

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { _ in cachedExpectation.fulfill() },
                receiveValue: { cachedResult = $0 }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: true)
            .sink(
                receiveCompletion: { _ in freshExpectation.fulfill() },
                receiveValue: { freshResult = $0 }
            )
            .store(in: &subscriptions)

        mocks.active.resume()
        mocks.completed.resume()
        mocks.invited.resume()

        wait(
            for: [
                firstFetchExpectation,
                cachedExpectation,
                secondFetchExpectation,
                freshExpectation
            ],
            timeout: 5
        )

        XCTAssertEqual(activeCallCount, 2)
        XCTAssertEqual(cachedResult?.allCourses.count, 2)
        XCTAssertEqual(freshResult?.allCourses.count, 2)
    }

    func testCachedRequestDuringFresh_receivesFreshData() {
        let useCaseCallExpectation = expectation(description: "UseCase invoked exactly once")
        useCaseCallExpectation.expectedFulfillmentCount = 1
        useCaseCallExpectation.assertForOverFulfill = true

        let mocks = mockCourseRequests(
            active: [
                APICourse.make(id: "1", name: "Course 1"),
                APICourse.make(id: "2", name: "Course 2")
            ],
            onActiveCalled: {
                useCaseCallExpectation.fulfill()
            }
        )
        mocks.active.suspend()
        mocks.completed.suspend()
        mocks.invited.suspend()

        let freshExpectation = expectation(description: "Fresh request completes")
        let cachedExpectation = expectation(description: "Cached request completes")

        var freshResult: CoursesResult?
        var cachedResult: CoursesResult?

        testee.getCourses(ignoreCache: true)
            .sink(
                receiveCompletion: { _ in freshExpectation.fulfill() },
                receiveValue: { freshResult = $0 }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { _ in cachedExpectation.fulfill() },
                receiveValue: { cachedResult = $0 }
            )
            .store(in: &subscriptions)

        mocks.active.resume()
        mocks.completed.resume()
        mocks.invited.resume()

        wait(
            for: [
                useCaseCallExpectation,
                freshExpectation,
                cachedExpectation
            ],
            timeout: 5
        )

        XCTAssertEqual(freshResult?.allCourses.count, 2)
        XCTAssertEqual(cachedResult?.allCourses.count, 2)
        XCTAssertEqual(freshResult?.allCourses.first?.id, cachedResult?.allCourses.first?.id)
    }

    func testError_broadcastsToAllPendingRequests() {
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        let mocks = mockCourseRequests(error: testError)
        mocks.active.suspend()

        let expectation1 = expectation(description: "First request receives error")
        let expectation2 = expectation(description: "Second request receives error")
        let expectation3 = expectation(description: "Third request receives error")

        var error1: Error?
        var error2: Error?
        var error3: Error?

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        error1 = error
                    }
                    expectation1.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: true)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        error2 = error
                    }
                    expectation2.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        error3 = error
                    }
                    expectation3.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        mocks.active.resume()

        wait(
            for: [
                expectation1,
                expectation2,
                expectation3
            ],
            timeout: 5
        )

        XCTAssertNotNil(error1)
        XCTAssertNotNil(error2)
        XCTAssertNotNil(error3)
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
