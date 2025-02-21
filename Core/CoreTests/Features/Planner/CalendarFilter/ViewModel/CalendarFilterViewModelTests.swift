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
import Combine
import XCTest

class CalendarFilterViewModelTests: CoreTestCase {
    private var mockInteractor: MockCalendarFilterInteractor!

    override func setUp() {
        super.setUp()
        mockInteractor = MockCalendarFilterInteractor()
    }

    func testGroupsFilters() {
        let groupFilter: CDCalendarFilterEntry = databaseClient.insert()
        groupFilter.context = .group("g1")
        let courseFilter: CDCalendarFilterEntry = databaseClient.insert()
        courseFilter.context = .course("c1")
        let userFilter: CDCalendarFilterEntry = databaseClient.insert()
        userFilter.context = .user("u1")
        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})

        // WHEN
        mockInteractor.filters.send([groupFilter, userFilter, courseFilter])
        mockInteractor.mockLoadPublisher.send(completion: .finished)

        // THEN
        XCTAssertEqual(testee.userFilterOptions.map(\.id), ["user_u1"])
        XCTAssertEqual(testee.courseFilterOptions.map(\.id), ["course_c1"])
        XCTAssertEqual(testee.groupFilterOptions.map(\.id), ["group_g1"])
    }

    func testUpdatesRightNavButtonTitle() {
        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})

        mockInteractor.filterCountLimit.send(.base)
        mockInteractor.selectedContexts.send(Set())
        XCTAssertEqual(testee.selectAllButtonTitle, nil)

        mockInteractor.filterCountLimit.send(.base)
        mockInteractor.selectedContexts.send(Set([.course("1")]))
        XCTAssertEqual(testee.selectAllButtonTitle, "Deselect all")

        mockInteractor.filterCountLimit.send(.unlimited)
        mockInteractor.selectedContexts.send(Set())
        XCTAssertEqual(testee.selectAllButtonTitle, "Select all")

        mockInteractor.filterCountLimit.send(.unlimited)
        mockInteractor.selectedContexts.send(Set([.course("1")]))
        XCTAssertEqual(testee.selectAllButtonTitle, "Deselect all")
    }

    func testShowsFilterLimitMessage() {
        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})

        mockInteractor.filterCountLimit.send(.base)
        XCTAssertEqual(testee.filterLimitMessage, "Select the calendars you want to see, up to 10.")

        mockInteractor.filterCountLimit.send(.unlimited)
        XCTAssertEqual(testee.filterLimitMessage, nil)
    }

    func testSelectAllActions() {
        let groupFilter: CDCalendarFilterEntry = databaseClient.insert()
        groupFilter.context = .group("g1")
        let courseFilter: CDCalendarFilterEntry = databaseClient.insert()
        courseFilter.context = .course("c1")

        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})

        // GIVEN
        mockInteractor.filters.send([groupFilter, courseFilter])
        mockInteractor.selectedContexts.send(Set([.group("g1")]))

        // WHEN
        testee.didTapSelectAllButton.send(())

        // THEN
        XCTAssertEqual(mockInteractor.receivedContextsForUpdateFilter, [])

        // GIVEN
        mockInteractor.selectedContexts.send(Set([]))

        // WHEN
        testee.didTapSelectAllButton.send(())

        // THEN
        XCTAssertEqual(mockInteractor.receivedContextsForUpdateFilter, [.course("c1"), .group("g1")])
    }

    func testForwardsFilterChangesToInteractor() {
        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})

        testee.selectedOptions.send([.make(id: "course_c1")])

        XCTAssertEqual(mockInteractor.receivedContextsForUpdateFilter, [.course("c1")])
    }

    func testShowsSnackBarIfFilterLimitReached() {
        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})
        mockInteractor.filterCountLimit.send(.base)
        let mockUpdatePublisher = PassthroughSubject<Void, Error>()
        mockInteractor.mockUpdateFilteredContextsResult = mockUpdatePublisher.eraseToAnyPublisher()

        // GIVEN
        testee.selectedOptions.send([.make(id: "course_c1")])

        // WHEN
        mockUpdatePublisher.send(completion: .failure(NSError.internalError()))

        // THEN
        XCTAssertEqual(testee.snackbarViewModel.visibleSnack, "You can only select up to 10 calendars.")
    }

    func testForceRefresh() {
        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})

        // WHEN
        testee.refresh {}

        // THEN
        XCTAssertEqual(mockInteractor.receivedIgnoreCacheForLoad, true)
    }

    func testStateTransitionOnData() {
        let courseFilter: CDCalendarFilterEntry = databaseClient.insert()
        courseFilter.context = .course("c1")

        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})
        let statesExpectation = expectation(description: "states received")
        let subscription = testee
            .$state
            .collect(2)
            .sink { states in
                XCTAssertEqual(states, [.loading, .data])
                statesExpectation.fulfill()
            }

        // WHEN
        mockInteractor.filters.send([courseFilter])
        mockInteractor.mockLoadPublisher.send(completion: .finished)

        // THEN
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testStateTransitionOnErrorAndForceRefresh() {
        let courseFilter: CDCalendarFilterEntry = databaseClient.insert()
        courseFilter.context = .course("c1")

        let testee = CalendarFilterViewModel(interactor: mockInteractor, didDismissPicker: {})
        let statesExpectation = expectation(description: "states received")
        let subscription = testee
            .$state
            .collect(3)
            .sink { states in
                XCTAssertEqual(states, [.loading, .error, .data])
                statesExpectation.fulfill()
            }

        // WHEN
        mockInteractor.mockLoadPublisher.send(completion: .failure(NSError.internalError()))
        mockInteractor.mockLoadPublisher = PassthroughSubject<Void, Error>() // Since we finished the previous publisher we need to create a new one
        testee.refresh {}
        mockInteractor.filters.send([courseFilter])
        mockInteractor.mockLoadPublisher.send(completion: .finished)

        // THEN
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }
}

private class MockCalendarFilterInteractor: CalendarFilterInteractor {
    let filters = CurrentValueSubject<[CDCalendarFilterEntry], Never>([])
    let filterCountLimit = CurrentValueSubject<CalendarFilterCountLimit, Never>(.unlimited)
    let selectedContexts = CurrentValueSubject<Set<Context>, Never>(Set())

    var mockLoadPublisher = PassthroughSubject<Void, Error>()
    var receivedIgnoreCacheForLoad: Bool?
    func load(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        receivedIgnoreCacheForLoad = ignoreCache
        return mockLoadPublisher.eraseToAnyPublisher()
    }

    var mockUpdateFilteredContextsResult: AnyPublisher<Void, Error> = Just(())
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    var receivedContextsForUpdateFilter: Set<Context>?
    func updateFilteredContexts(_ contexts: Set<Context>) -> AnyPublisher<Void, any Error> {
        receivedContextsForUpdateFilter = contexts
        return mockUpdateFilteredContextsResult
    }

    func contextsForAPIFiltering() -> [Context] {
        []
    }
}
