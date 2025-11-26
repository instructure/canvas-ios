//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import TestsFoundation
import XCTest
import Combine
import CombineSchedulers

class TodoListViewModelTests: CoreTestCase {

    private var interactor: TodoInteractorMock!
    private var sessionDefaults: SessionDefaults!
    private var testee: TodoListViewModel!
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    // MARK: - Setup and teardown

    override func setUp() {
        super.setUp()
        interactor = .init()
        sessionDefaults = SessionDefaults(sessionID: "test")
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        testee = .init(interactor: interactor, router: router, sessionDefaults: sessionDefaults, scheduler: testScheduler.eraseToAnyScheduler())
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        sessionDefaults = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func test_init_setsInitialState() {
        testScheduler.advance()
        XCTAssertEqual(testee.items, [])
        XCTAssertEqual(testee.state, .loading)
    }

    func test_init_callsRefresh() {
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertFalse(interactor.lastIgnoreCache)
    }

    // MARK: - Items Update

    func test_items_updateFromInteractor() {
        // Given
        let testItems = [
            TodoItemViewModel.make(plannableId: "1", title: "Test Item 1"),
            TodoItemViewModel.make(plannableId: "2", title: "Test Item 2")
        ]
        let testGroups = [TodoGroupViewModel(date: Date(), items: testItems)]

        // When
        interactor.todoGroups.send(testGroups)
        testScheduler.advance()

        // Then
        XCTAssertFirstValue(testee.$items) { items in
            XCTAssertEqual(items, testGroups)
        }
    }

    // MARK: - Refresh

    func test_refresh_passesIgnoreCacheTrue() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success(())
        interactor.todoGroups.send([])

        // When
        testee.refresh(ignoreCache: true) {
            expectation.fulfill()
        }
        testScheduler.advance()

        // Then
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertTrue(interactor.lastIgnoreCache)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(testee.state, .empty)
    }

    func test_refresh_passesIgnoreCacheFalse() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success(())

        // When
        testee.refresh(ignoreCache: false) {
            expectation.fulfill()
        }
        testScheduler.advance()

        // Then
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertFalse(interactor.lastIgnoreCache)

        waitForExpectations(timeout: 1.0)
    }

    func test_refresh_onSuccessWithData_setsStateToData() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success(())
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [TodoItemViewModel.make(plannableId: "1", title: "Test Item")])])
        testScheduler.advance()

        // When
        testee.refresh(ignoreCache: false) {
            expectation.fulfill()
        }
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.state, .data)
        waitForExpectations(timeout: 1.0)
    }

    func test_refresh_onSuccessWithEmptyData_setsStateToEmpty() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success(())
        interactor.todoGroups.send([])

        // When
        testee.refresh(ignoreCache: false) {
            expectation.fulfill()
        }
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.state, .empty)
        waitForExpectations(timeout: 1.0)
    }

    func test_refresh_onFailure_setsStateToError() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .failure(NSError.internalError())

        // When
        testee.refresh(ignoreCache: false) {
            expectation.fulfill()
        }
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.state, .error)
        waitForExpectations(timeout: 1.0)
    }

    // MARK: - User Actions

    func test_didTapItem_withPlannerNote_showsDetails() {
        // Given
        let todo = TodoItemViewModel.make(plannableId: "123", type: .planner_note)
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNotNil(router.lastViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .detail)
    }

    func test_didTapItem_withCalendarEvent_showsDetails() {
        // Given
        let todo = TodoItemViewModel.make(
            plannableId: "456",
            type: .calendar_event,
            htmlURL: URL(string: "https://canvas.instructure.com/calendar")
        )
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNotNil(router.lastViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .detail)
    }

    func test_didTapItem_withURL_routesToURL() {
        // Given
        let todo = TodoItemViewModel.make(
            plannableId: "789",
            type: .assignment,
            htmlURL: URL(string: "https://canvas.instructure.com/courses/1/assignments/789"))
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssert(router.lastRoutedTo("https://canvas.instructure.com/courses/1/assignments/789?origin=todo"))
    }

    func test_didTapItem_withoutURL_doesNothing() {
        // Given
        let todo = TodoItemViewModel.make(plannableId: "999", type: .assignment, htmlURL: nil as URL?)
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNil(router.lastViewController)
    }

    func test_didTapItem_withAccountContext_doesNothing() {
        // Given
        let todo = TodoItemViewModel(
            plannableId: "123",
            type: .assignment,
            date: Date(),
            title: "Account level assignment",
            subtitle: nil,
            contextName: "Account",
            htmlURL: URL(string: "https://canvas.instructure.com/accounts/1/assignments/123"),
            color: .red,
            icon: .assignmentLine,
            isTappable: false
        )
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNil(router.lastViewController)
        XCTAssertFalse(router.lastRoutedTo("https://canvas.instructure.com/accounts/1/assignments/123?origin=todo"))
    }

    func test_didTapItem_withNonTappableItem_showsSnackBar() {
        // Given
        let todo = TodoItemViewModel(
            plannableId: "123",
            type: .assignment,
            date: Date(),
            title: "Account level assignment",
            subtitle: nil,
            contextName: "Account",
            htmlURL: URL(string: "https://canvas.instructure.com/accounts/1/assignments/123"),
            color: .red,
            icon: .assignmentLine,
            isTappable: false
        )
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertEqual(testee.snackBar.visibleSnack, "No additional details available.")
    }

    // MARK: - State Management

    func test_state_updatesBasedOnRefreshResults() {
        testScheduler.advance()
        XCTAssertEqual(testee.state, .loading)

        // When - with non-empty todos
        interactor.refreshResult = .success(())
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [TodoItemViewModel.make(plannableId: "1", title: "Test")])])
        testScheduler.advance()
        testee.refresh(ignoreCache: false)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.state, .data)

        // When - with empty todos
        interactor.refreshResult = .success(())
        interactor.todoGroups.send([])
        testScheduler.advance()
        testee.refresh(ignoreCache: false)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.state, .empty)

        // When - with error
        interactor.refreshResult = .failure(NSError.internalError())
        testee.refresh(ignoreCache: false)
        testScheduler.advance()

        // Then
        XCTAssertEqual(testee.state, .error)
    }

    func test_refresh_handlesMultipleCalls() {
        // Given
        interactor.refreshCallCount = 0
        interactor.refreshResult = .success(())

        // When
        testee.refresh(ignoreCache: false)
        testee.refresh(ignoreCache: true)
        testee.refresh(ignoreCache: false)

        // Then
        XCTAssertEqual(interactor.refreshCallCount, 3)
    }

    func test_openProfile_routesToProfile() {
        // Given
        let viewController = WeakViewController()

        // When
        testee.openProfile(viewController)

        // Then
        XCTAssert(router.lastRoutedTo("/profile"))
        XCTAssertEqual(router.calls.last?.2.isModal, true)
    }

    // MARK: - App Foreground Handling

    func test_appWillEnterForeground_checksCacheAndRefreshes() {
        // Given
        testScheduler.advance()
        XCTAssertEqual(testee.state, .loading)
        interactor.isCacheExpiredResult = true
        interactor.refreshResult = .success(())
        interactor.refreshCallCount = 0

        // When
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        testScheduler.advance()

        // Then
        XCTAssertTrue(interactor.isCacheExpiredCalled)
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertEqual(interactor.refreshCallCount, 1)
        XCTAssertFalse(interactor.lastIgnoreCache)
    }

    // MARK: - Mark Item As Done (Checkbox)

    func test_markItemAsDone_startsInNotDoneState() {
        // GIVEN
        let item = TodoItemViewModel.make(plannableId: "1")

        // THEN
        XCTAssertEqual(item.markAsDoneState, .notDone)
    }

    func test_markItemAsDone_onSuccess_changesStateToDone() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .done)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
        XCTAssertEqual(interactor.lastMarkAsDoneItem?.plannableId, "1")
        XCTAssertEqual(interactor.lastMarkAsDoneDone, true)
    }

    func test_markItemAsDone_onError_changesStateBackToNotDone() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", overrideId: "override-1")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .notDone)
    }

    func test_markItemAsDone_onError_showsSnackBar() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", overrideId: "override-1")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertNotNil(testee.snackBar.visibleSnack)
    }

    func test_markItemAsDone_removesItemAfterThreeSeconds() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .done)
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)

        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 0)
    }

    func test_markItemAsDone_keepsItemVisible_whenShowCompletedFilterEnabled() {
        // GIVEN
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [.showCompleted],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .done)
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)

        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)
    }

    func test_markItemAsDone_whileDone_marksAsUndone() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1", overrideId: "override-1")
        item.markAsDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .notDone)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
        XCTAssertEqual(interactor.lastMarkAsDoneDone, false)
    }

    func test_markItemAsDone_undoBeforeRemoval_cancelsTimer() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1", overrideId: "override-1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()
        XCTAssertEqual(item.markAsDoneState, .done)

        testee.markItemAsDone(item)
        testScheduler.advance()
        XCTAssertEqual(item.markAsDoneState, .notDone)

        // THEN
        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)
    }

    // MARK: - Mark As Undone (Checkbox)

    func test_markAsUndone_onError_changesStateBackToDone() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", overrideId: "override-1")
        item.markAsDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    func test_markAsUndone_onError_showsSnackBar() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", overrideId: "override-1")
        item.markAsDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertNotNil(testee.snackBar.visibleSnack)
    }

    // MARK: - Item Removal

    func test_removeItem_removesEmptyGroups() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item1 = TodoItemViewModel.make(plannableId: "1")
        let item2 = TodoItemViewModel.make(plannableId: "2")
        let group1 = TodoGroupViewModel(date: Date(), items: [item1])
        let group2 = TodoGroupViewModel(date: Date().addingTimeInterval(86400), items: [item2])
        interactor.todoGroups.send([group1, group2])

        // WHEN
        testee.markItemAsDone(item1)
        testScheduler.advance()
        XCTAssertEqual(item1.markAsDoneState, .done)

        // THEN
        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.first?.plannableId, "2")
    }

    func test_removeItem_setsStateToEmpty_whenLastItemRemoved() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()
        XCTAssertEqual(item.markAsDoneState, .done)

        // THEN
        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 0)
        XCTAssertEqual(testee.state, .empty)
    }

    func test_markItemAsDone_whileLoading_ignoresAdditionalTaps() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")

        // WHEN
        testee.markItemAsDone(item)
        XCTAssertEqual(item.markAsDoneState, .loading)
        XCTAssertEqual(interactor.markItemAsDoneCallCount, 1)

        testee.markItemAsDone(item)
        testee.markItemAsDone(item)
        testee.markItemAsDone(item)

        // THEN
        XCTAssertEqual(interactor.markItemAsDoneCallCount, 1)
        XCTAssertEqual(item.markAsDoneState, .loading)

        testScheduler.advance()
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    // MARK: - Badge Count

    func test_markItemAsDone_decrementsBadgeCount() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 5
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 4)
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    func test_markItemAsUndone_incrementsBadgeCount() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 3
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        item.markAsDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 4)
        XCTAssertEqual(item.markAsDoneState, .notDone)
    }

    func test_markItemAsDone_doesNotDecrementBadgeCountBelowZero() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 0
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 0)
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    // MARK: - Handle Swipe Action

    func test_handleSwipeAction_whenNotDone_andFilterHidesCompleted_removesItemImmediately() {
        // GIVEN
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        let viewModel = TodoListViewModel(
            interactor: interactor,
            router: router,
            sessionDefaults: sessionDefaults,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // WHEN
        viewModel.handleSwipeAction(item)

        // THEN
        XCTAssertEqual(viewModel.items.count, 0)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
    }

    func test_handleSwipeAction_whenNotDone_andFilterShowsCompleted_togglesInPlace() {
        // GIVEN
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [.showCompleted],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        let viewModel = TodoListViewModel(
            interactor: interactor,
            router: router,
            sessionDefaults: sessionDefaults,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        item.shouldKeepCompletedItemsVisible = true
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // WHEN
        viewModel.handleSwipeAction(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(item.markAsDoneState, .done)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
    }

    func test_handleSwipeAction_whenDone_alwaysTogglesInPlace() {
        // GIVEN
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        let viewModel = TodoListViewModel(
            interactor: interactor,
            router: router,
            sessionDefaults: sessionDefaults,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        item.markAsDoneState = .done
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // WHEN
        viewModel.handleSwipeAction(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(item.markAsDoneState, .notDone)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
    }

    func test_handleSwipeAction_whenDone_cancelsDelayedRemoval() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 1
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        let viewModel = TodoListViewModel(
            interactor: interactor,
            router: router,
            sessionDefaults: sessionDefaults,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])

        // Mark as done via checkbox (which schedules delayed removal)
        viewModel.markItemAsDone(item)
        testScheduler.advance()
        XCTAssertEqual(item.markAsDoneState, .done)

        // WHEN - undo via swipe before removal timer fires
        viewModel.handleSwipeCommitted(item)
        viewModel.handleSwipeAction(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .notDone)
        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(viewModel.items.count, 1)
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 1)
    }

    // MARK: - Toggle Item State In Place

    func test_toggleItemStateInPlace_success_updatesState() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 5
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [.showCompleted],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        let viewModel = TodoListViewModel(
            interactor: interactor,
            router: router,
            sessionDefaults: sessionDefaults,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        item.shouldKeepCompletedItemsVisible = true

        // WHEN
        viewModel.handleSwipeAction(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .done)
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 4)
    }

    func test_toggleItemStateInPlace_failure_showsError() {
        // GIVEN
        sessionDefaults.todoFilterOptions = TodoFilterOptions(
            visibilityOptions: [.showCompleted],
            dateRangeStart: .lastWeek,
            dateRangeEnd: .nextWeek
        )
        let viewModel = TodoListViewModel(
            interactor: interactor,
            router: router,
            sessionDefaults: sessionDefaults,
            scheduler: testScheduler.eraseToAnyScheduler()
        )
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1")
        item.shouldKeepCompletedItemsVisible = true

        // WHEN
        viewModel.handleSwipeAction(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markAsDoneState, .notDone)
        XCTAssertNotNil(viewModel.snackBar.visibleSnack)
    }

    // MARK: - Optimistic UI

    func test_markItemAsDoneWithOptimisticUI_removesItemImmediately() {
        // GIVEN
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])
        testScheduler.advance()

        // WHEN
        testee.handleSwipeAction(item)

        // THEN
        XCTAssertEqual(testee.items.count, 0)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
    }

    func test_markItemAsDoneWithOptimisticUI_onSuccess_staysRemoved() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 5
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item = TodoItemViewModel.make(plannableId: "1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        interactor.todoGroups.send([group])
        testScheduler.advance()

        // WHEN
        testee.handleSwipeAction(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.items.count, 0)
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 4)
    }

    func test_markItemAsDoneWithOptimisticUI_onFailure_restoresItem() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 5
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", date: Date())
        let group = TodoGroupViewModel(date: Date().startOfDay(), items: [item])
        interactor.todoGroups.send([group])
        testScheduler.advance()

        // WHEN
        testee.handleSwipeAction(item)
        XCTAssertEqual(testee.items.count, 0)

        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.first?.plannableId, "1")
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 5)
        XCTAssertNotNil(testee.snackBar.visibleSnack)
    }

    func test_markItemAsDoneWithOptimisticUI_multipleConcurrentSwipes_allSucceed() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 3
        interactor.markItemAsDoneResult = .success("mock-override-id")
        let item1 = TodoItemViewModel.make(plannableId: "1")
        let item2 = TodoItemViewModel.make(plannableId: "2")
        let item3 = TodoItemViewModel.make(plannableId: "3")
        let group = TodoGroupViewModel(date: Date(), items: [item1, item2, item3])
        interactor.todoGroups.send([group])
        testScheduler.advance()

        // WHEN
        testee.handleSwipeAction(item1)
        testee.handleSwipeAction(item2)
        testee.handleSwipeAction(item3)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.items.count, 0)
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 0)
        XCTAssertEqual(interactor.markItemAsDoneCallCount, 3)
    }

    func test_markItemAsDoneWithOptimisticUI_multipleConcurrentSwipes_allFail() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 3
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item1 = TodoItemViewModel.make(plannableId: "1", date: Date())
        let item2 = TodoItemViewModel.make(plannableId: "2", date: Date())
        let item3 = TodoItemViewModel.make(plannableId: "3", date: Date())
        let group = TodoGroupViewModel(date: Date().startOfDay(), items: [item1, item2, item3])
        interactor.todoGroups.send([group])
        testScheduler.advance()

        // WHEN
        testee.handleSwipeAction(item1)
        testee.handleSwipeAction(item2)
        testee.handleSwipeAction(item3)
        XCTAssertEqual(testee.items.count, 0)

        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 3)
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 3)
        XCTAssertNotNil(testee.snackBar.visibleSnack)
    }

    func test_markItemAsDoneWithOptimisticUI_multipleConcurrentSwipes_mixedResults() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 3
        let item1 = TodoItemViewModel.make(plannableId: "1", date: Date())
        let item2 = TodoItemViewModel.make(plannableId: "2", date: Date())
        let item3 = TodoItemViewModel.make(plannableId: "3", date: Date())
        let group = TodoGroupViewModel(date: Date().startOfDay(), items: [item1, item2, item3])
        interactor.todoGroups.send([group])
        testScheduler.advance()

        interactor.markItemAsDoneResult = .success("mock-override-id")

        // WHEN - swipe all items
        testee.handleSwipeAction(item1)

        // Change result to failure for item2
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        testee.handleSwipeAction(item2)

        // Change result back to success for item3
        interactor.markItemAsDoneResult = .success("mock-override-id")
        testee.handleSwipeAction(item3)

        XCTAssertEqual(testee.items.count, 0)

        testScheduler.advance()

        // THEN - only item2 should be restored
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.first?.plannableId, "2")
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 1)
    }

    func test_markItemAsDoneWithOptimisticUI_restoresToCorrectGroup() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let today = Date().startOfDay()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let item1 = TodoItemViewModel.make(plannableId: "1", date: today)
        let item2 = TodoItemViewModel.make(plannableId: "2", date: tomorrow)
        let group1 = TodoGroupViewModel(date: today, items: [item1])
        let group2 = TodoGroupViewModel(date: tomorrow, items: [item2])

        interactor.todoGroups.send([group1, group2])
        testScheduler.advance()

        // WHEN
        testee.handleSwipeAction(item1)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.items.first?.date, today)
        XCTAssertEqual(testee.items.first?.items.first?.plannableId, "1")
        XCTAssertEqual(testee.items.last?.date, tomorrow)
        XCTAssertEqual(testee.items.last?.items.first?.plannableId, "2")
    }

    func test_markItemAsDoneWithOptimisticUI_recreatesGroupIfNeeded() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let today = Date().startOfDay()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let item1 = TodoItemViewModel.make(plannableId: "1", date: today)
        let item2 = TodoItemViewModel.make(plannableId: "2", date: tomorrow)
        let group1 = TodoGroupViewModel(date: today, items: [item1])
        let group2 = TodoGroupViewModel(date: tomorrow, items: [item2])

        interactor.todoGroups.send([group1, group2])
        testScheduler.advance()

        // WHEN - remove all items from first group
        testee.handleSwipeAction(item1)
        XCTAssertEqual(testee.items.count, 1)

        testScheduler.advance()

        // THEN - first group should be recreated
        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.items.first?.date, today)
    }

    func test_markItemAsDoneWithOptimisticUI_stateTransition_emptyToData() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", date: Date())
        let group = TodoGroupViewModel(date: Date().startOfDay(), items: [item])
        interactor.todoGroups.send([group])
        testScheduler.advance()

        // WHEN
        testee.handleSwipeAction(item)
        XCTAssertEqual(testee.state, .empty)

        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.items.count, 1)
    }
}
