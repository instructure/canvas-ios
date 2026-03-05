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

import BusinessLogic
import Combine
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class CoursesInteractorLiveTests: StudentTestCase {

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

        var result1: CoursesResult?
        var result2: CoursesResult?
        var result3: CoursesResult?

        let expectation1 = expectation(description: "Request 1")
        let expectation2 = expectation(description: "Request 2")
        let expectation3 = expectation(description: "Request 3")

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

        wait(for: [useCaseCallExpectation, expectation1, expectation2, expectation3], timeout: 5)

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

        var cachedResult: CoursesResult?
        var freshResult: CoursesResult?

        let cachedExpectation = expectation(description: "Cached request")
        let freshExpectation = expectation(description: "Fresh request")

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

        wait(for: [firstFetchExpectation, secondFetchExpectation, cachedExpectation, freshExpectation], timeout: 5)

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

        var freshResult: CoursesResult?
        var cachedResult: CoursesResult?

        let freshExpectation = expectation(description: "Fresh request")
        let cachedExpectation = expectation(description: "Cached request")

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

        wait(for: [useCaseCallExpectation, freshExpectation, cachedExpectation], timeout: 5)

        XCTAssertEqual(freshResult?.allCourses.count, 2)
        XCTAssertEqual(cachedResult?.allCourses.count, 2)
        XCTAssertEqual(freshResult?.allCourses.first?.id, cachedResult?.allCourses.first?.id)
    }

    func testError_broadcastsToAllPendingRequests() {
        let testError = NSError(domain: "test", code: 1, userInfo: nil)
        let mocks = mockCourseRequests(error: testError)
        mocks.active.suspend()

        let expectation1 = expectation(description: "Request 1 fails")
        let expectation2 = expectation(description: "Request 2 fails")
        let expectation3 = expectation(description: "Request 3 fails")

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation1.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: true)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation2.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        testee.getCourses(ignoreCache: false)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation3.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        mocks.active.resume()

        wait(for: [expectation1, expectation2, expectation3], timeout: 5)
    }

    func testGetCoursesReturnsInvitedCourses() throws {
        _ = mockCourseRequests(
            active: [
                APICourse.make(id: "1", name: "Active Course")
            ],
            invited: [
                APICourse.make(
                    id: "2",
                    name: "Invited Course 1",
                    enrollments: [APIEnrollment.make(id: "e1", enrollment_state: .invited)]
                ),
                APICourse.make(
                    id: "3",
                    name: "Invited Course 2",
                    enrollments: [APIEnrollment.make(id: "e2", enrollment_state: .invited)]
                )
            ]
        )

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: false), timeout: 5) { result in
            XCTAssertEqual(result.allCourses.count, 3)
            XCTAssertEqual(result.invitedCourses.count, 2)
        }
    }

    func testGetCourses_forwardsCorrectArgumentsToBusinessLogic() {
        let courseLogicMock = BusinessLogic.CourseMock()
        testee = CoursesInteractorLive(env: env, courseLogic: courseLogicMock)

        _ = mockCourseRequests(
            active: [
                APICourse.make(
                    id: "1",
                    workflow_state: .available,
                    enrollments: [APIEnrollment.make(id: "e1", enrollment_state: .active)]
                ),
                APICourse.make(
                    id: "2",
                    workflow_state: .completed,
                    enrollments: [APIEnrollment.make(id: "e2", enrollment_state: .invited)]
                )
            ]
        )

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: false), timeout: 5) { _ in
            let invocations = courseLogicMock.shouldShowAsInvitedCourseReceivedInvocations
            XCTAssertEqual(invocations.count, 2)
            XCTAssertTrue(invocations.contains { !$0.isCourseClosed && !$0.hasInvitedEnrollment })
            XCTAssertTrue(invocations.contains { $0.isCourseClosed && $0.hasInvitedEnrollment })
        }
    }

    func testGetCourses_businessLogicReturnValueControlsInvitedCourses() {
        let courseLogicMock = BusinessLogic.CourseMock(shouldShowAsInvitedCourseReturnValue: true)
        testee = CoursesInteractorLive(env: env, courseLogic: courseLogicMock)

        _ = mockCourseRequests(
            active: [
                APICourse.make(id: "1", name: "Course 1"),
                APICourse.make(id: "2", name: "Course 2")
            ],
            invited: [
                APICourse.make(
                    id: "3",
                    name: "Course 3",
                    workflow_state: .deleted,
                    enrollments: [APIEnrollment.make(id: "e3", enrollment_state: .invited)]
                )
            ]
        )

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: false), timeout: 5) { result in
            XCTAssertEqual(result.allCourses.count, 2)
            XCTAssertEqual(result.invitedCourses.count, 2)
        }
    }

    func testGetCoursesInvokesSortComparator() throws {
        let mockComparator = MockCourseSortComparator()
        testee = CoursesInteractorLive(env: env, sortComparator: mockComparator)

        _ = mockCourseRequests(
            active: [],
            invited: [
                APICourse.make(
                    id: "1",
                    name: "Course 1",
                    enrollments: [APIEnrollment.make(id: "e1", enrollment_state: .invited)]
                ),
                APICourse.make(
                    id: "2",
                    name: "Course 2",
                    enrollments: [APIEnrollment.make(id: "e2", enrollment_state: .invited)]
                )
            ]
        )

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: false), timeout: 5) { _ in
            XCTAssertTrue(mockComparator.compareCalled)
            XCTAssertGreaterThan(mockComparator.compareCallCount, 0)
        }
    }

    func test_getCourses_shouldReturnGroups() {
        _ = mockCourseRequests(
            active: [APICourse.make(id: "1", name: "Course 1")]
        )
        api.mock(
            GetAllCoursesGroupListUseCase(),
            value: [
                .make(id: "group1", name: "Study Group"),
                .make(id: "group2", name: "Project Team")
            ]
        )

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: false), timeout: 5) { result in
            XCTAssertEqual(result.allCourses.count, 1)
            XCTAssertEqual(result.groups.count, 2)
            XCTAssertEqual(result.groups.first?.name, "Project Team")
            XCTAssertEqual(result.groups.last?.name, "Study Group")
        }
    }

    func test_getCourses_shouldReturnCourseCards() {
        _ = mockCourseRequests(
            dashboardCards: [
                .make(id: "card 1"),
                .make(id: "card 2")
            ]
        )

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: false), timeout: 5) { result in
            XCTAssertEqual(result.courseCards.count, 2)
        }
    }

    func test_getCourses_shouldReturnFavoriteGroups() {
        _ = mockCourseRequests(
            favoriteGroups: [
                .make(id: "group 1"),
                .make(id: "group 2")
            ]
        )

        XCTAssertSingleOutputAndFinish(testee.getCourses(ignoreCache: false), timeout: 5) { result in
            XCTAssertEqual(result.favoriteGroups.count, 2)
        }
    }

    // MARK: - Helpers

    private class MockCourseSortComparator: SortComparator {
        typealias Compared = Course
        var order: SortOrder = .forward

        private(set) var compareCalled = false
        private(set) var compareCallCount = 0

        func compare(_ lhs: Course, _ rhs: Course) -> ComparisonResult {
            compareCalled = true
            compareCallCount += 1
            return .orderedSame
        }

        static func == (lhs: MockCourseSortComparator, rhs: MockCourseSortComparator) -> Bool {
            true
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(order)
        }
    }

    private func mockCourseRequests(
        active: [APICourse] = [],
        completed: [APICourse] = [],
        invited: [APICourse] = [],
        dashboardCards: [APIDashboardCard] = [],
        favoriteGroups: [APIGroup] = [],
        error: Error? = nil,
        onActiveCalled: (() -> Void)? = nil
    ) -> (active: APIMock, completed: APIMock, invited: APIMock) {
        api.mock(GetDashboardCardsRequest(), value: dashboardCards)
        api.mock(GetFavoriteGroupsRequest(context: .currentUser), value: favoriteGroups)
        let activeMock = api.mock(testee.coursesUseCase.activeRequest) { _ in
            onActiveCalled?()
            if let error {
                return (nil, nil, error)
            }
            return (active, nil, nil)
        }
        let completedMock = api.mock(testee.coursesUseCase.completedRequest, value: completed)
        let invitedMock = api.mock(testee.coursesUseCase.invitedRequest, value: invited)
        return (activeMock, completedMock, invitedMock)
    }
}
