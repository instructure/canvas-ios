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
    private var testee: TodoListViewModel!
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    // MARK: - Setup and teardown

    override func setUp() {
        super.setUp()
        interactor = .init()
        testee = .init(interactor: interactor, router: router, scheduler: testScheduler.eraseToAnyScheduler())
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testInitialState() {
        XCTAssertEqual(testee.items, [])
        XCTAssertEqual(testee.state, .empty)
    }

    func testInitialRefreshCalled() {
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertFalse(interactor.lastIgnoreCache)
    }

    func testItemsUpdateFromInteractor() {
        // Given
        let testItems = [
            TodoItemViewModel.make(plannableId: "1", title: "Test Item 1"),
            TodoItemViewModel.make(plannableId: "2", title: "Test Item 2")
        ]
        let testGroups = [TodoGroupViewModel(date: Date(), items: testItems)]

        // When
        interactor.todoGroups.send(testGroups)

        // Then
        XCTAssertFirstValue(testee.$items) { items in
            XCTAssertEqual(items, testGroups)
        }
    }

    func testRefreshWithIgnoreCacheTrue() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success

        // When
        testee.refresh(completion: {
            expectation.fulfill()
        }, ignoreCache: true)

        // Then
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertTrue(interactor.lastIgnoreCache)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(testee.state, .empty)
    }

    func testRefreshWithIgnoreCacheFalse() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success

        // When
        testee.refresh(completion: {
            expectation.fulfill()
        }, ignoreCache: false)

        // Then
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertFalse(interactor.lastIgnoreCache)

        waitForExpectations(timeout: 1.0)
    }

    func testRefreshSuccessWithNonEmptyData() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [TodoItemViewModel.make(plannableId: "1", title: "Test Item")])])

        // When
        testee.refresh(completion: {
            expectation.fulfill()
        }, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .data)
        waitForExpectations(timeout: 1.0)
    }

    func testRefreshSuccessWithEmptyData() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success
        interactor.todoGroups.send([])

        // When
        testee.refresh(completion: {
            expectation.fulfill()
        }, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .empty)
        waitForExpectations(timeout: 1.0)
    }

    func testRefreshFailure() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .failure(NSError.internalError())

        // When
        testee.refresh(completion: {
            expectation.fulfill()
        }, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .error)
        waitForExpectations(timeout: 1.0)
    }

    func testDidTapItemPlannerNote() {
        // Given
        let todo = TodoItemViewModel.make(plannableId: "123", type: .planner_note)
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNotNil(router.lastViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .detail)
    }

    func testDidTapItemCalendarEvent() {
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

    func testDidTapItemOtherTypeWithURL() {
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

    func testDidTapItemOtherTypeWithoutURL() {
        // Given
        let todo = TodoItemViewModel.make(plannableId: "999", type: .assignment, htmlURL: nil as URL?)
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNil(router.lastViewController)
    }

    func testStateUpdatesCorrectly() {
        XCTAssertEqual(testee.state, .empty)

        // When - with non-empty todos
        interactor.refreshResult = .success
        interactor.todoGroups.send([TodoGroupViewModel(date: Date(), items: [TodoItemViewModel.make(plannableId: "1", title: "Test")])])
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .data)

        // When - with empty todos
        interactor.refreshResult = .success
        interactor.todoGroups.send([])
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .empty)

        // When - with error
        interactor.refreshResult = .failure(NSError.internalError())
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .error)
    }

    func testMultipleRefreshCalls() {
        // Given
        interactor.refreshCallCount = 0
        interactor.refreshResult = .success

        // When
        testee.refresh(completion: {}, ignoreCache: false)
        testee.refresh(completion: {}, ignoreCache: true)
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(interactor.refreshCallCount, 3)
    }

    func testOpenProfile() {
        // Given
        let viewController = WeakViewController()

        // When
        testee.openProfile(viewController)

        // Then
        XCTAssert(router.lastRoutedTo("/profile"))
        XCTAssertEqual(router.calls.last?.2.isModal, true)
    }

    func test_markItemAsDone_startsInNotDoneState() {
        // GIVEN
        let item = TodoItemViewModel.make(plannableId: "1")

        // THEN
        XCTAssertEqual(item.markDoneState, .notDone)
    }

    func test_markItemAsDone_onSuccess_changesStateToDone() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markDoneState, .done)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
        XCTAssertEqual(interactor.lastMarkAsDoneItem?.plannableId, "1")
        XCTAssertEqual(interactor.lastMarkAsDoneDone, true)
    }

    func test_markItemAsDone_onError_changesStateBackToNotDone() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment", overrideId: "override-1")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markDoneState, .notDone)
    }

    func test_markItemAsDone_onError_showsSnackBar() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment", overrideId: "override-1")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertNotNil(testee.snackBar.visibleSnack)
    }

    func test_markItemAsDone_removesItemAfterThreeSeconds() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markDoneState, .done)
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)

        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 0)
    }

    func test_markItemAsDone_whileDone_marksAsUndone() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment", overrideId: "override-1")
        item.markDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markDoneState, .notDone)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
        XCTAssertEqual(interactor.lastMarkAsDoneDone, false)
    }

    func test_markItemAsDone_undoBeforeRemoval_cancelsTimer() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment", overrideId: "override-1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()
        XCTAssertEqual(item.markDoneState, .done)

        testee.markItemAsDone(item)
        testScheduler.advance()
        XCTAssertEqual(item.markDoneState, .notDone)

        // THEN
        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)
    }

    func test_markAsUndone_onError_changesStateBackToDone() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment", overrideId: "override-1")
        item.markDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(item.markDoneState, .done)
    }

    func test_markAsUndone_onError_showsSnackBar() {
        // GIVEN
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment", overrideId: "override-1")
        item.markDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertNotNil(testee.snackBar.visibleSnack)
    }

    func test_removeItem_removesEmptyGroups() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item1 = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")
        let item2 = TodoItemViewModel.make(plannableId: "2")
        let group1 = TodoGroupViewModel(date: Date(), items: [item1])
        let group2 = TodoGroupViewModel(date: Date().addingTimeInterval(86400), items: [item2])
        testee.items = [group1, group2]

        // WHEN
        testee.markItemAsDone(item1)
        testScheduler.advance()
        XCTAssertEqual(item1.markDoneState, .done)

        // THEN
        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.first?.plannableId, "2")
    }

    func test_removeItem_setsStateToEmpty_whenLastItemRemoved() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]
        testee.state = .data

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()
        XCTAssertEqual(item.markDoneState, .done)

        // THEN
        testScheduler.advance(by: .seconds(3))
        XCTAssertEqual(testee.items.count, 0)
        XCTAssertEqual(testee.state, .empty)
    }

    func test_markItemAsDone_whileLoading_ignoresAdditionalTaps() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")

        // WHEN
        testee.markItemAsDone(item)
        XCTAssertEqual(item.markDoneState, .loading)
        XCTAssertEqual(interactor.markItemAsDoneCallCount, 1)

        testee.markItemAsDone(item)
        testee.markItemAsDone(item)
        testee.markItemAsDone(item)

        // THEN
        XCTAssertEqual(interactor.markItemAsDoneCallCount, 1)
        XCTAssertEqual(item.markDoneState, .loading)

        testScheduler.advance()
        XCTAssertEqual(item.markDoneState, .done)
    }

    func test_markItemAsDone_decrementsBadgeCount() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 5
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 4)
        XCTAssertEqual(item.markDoneState, .done)
    }

    func test_markItemAsUndone_incrementsBadgeCount() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 3
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")
        item.markDoneState = .done

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 4)
        XCTAssertEqual(item.markDoneState, .notDone)
    }

    func test_markItemAsDone_doesNotDecrementBadgeCountBelowZero() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 0
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")

        // WHEN
        testee.markItemAsDone(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 0)
        XCTAssertEqual(item.markDoneState, .done)
    }

    // MARK: - Optimistic UI Tests

    func test_markItemAsDoneWithOptimisticUI_removesItemImmediately() {
        // GIVEN
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]

        // WHEN
        testee.markItemAsDoneWithOptimisticUI(item)

        // THEN
        XCTAssertEqual(testee.items.count, 0)
        XCTAssertTrue(interactor.markItemAsDoneCalled)
    }

    func test_markItemAsDoneWithOptimisticUI_onSuccess_staysRemoved() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 5
        interactor.markItemAsDoneResult = .success(())
        let item = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]

        // WHEN
        testee.markItemAsDoneWithOptimisticUI(item)
        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.items.count, 0)
        XCTAssertEqual(TabBarBadgeCounts.todoListCount, 4)
    }

    func test_markItemAsDoneWithOptimisticUI_onFailure_restoresItem() {
        // GIVEN
        TabBarBadgeCounts.todoListCount = 5
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        let item = TodoItemViewModel.make(plannableId: "1", date: Date(), plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date().startOfDay(), items: [item])
        testee.items = [group]
        interactor.todoGroups.send([group])

        // WHEN
        testee.markItemAsDoneWithOptimisticUI(item)
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
        interactor.markItemAsDoneResult = .success(())
        let item1 = TodoItemViewModel.make(plannableId: "1", plannableType: "assignment")
        let item2 = TodoItemViewModel.make(plannableId: "2", plannableType: "assignment")
        let item3 = TodoItemViewModel.make(plannableId: "3", plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date(), items: [item1, item2, item3])
        testee.items = [group]

        // WHEN
        testee.markItemAsDoneWithOptimisticUI(item1)
        testee.markItemAsDoneWithOptimisticUI(item2)
        testee.markItemAsDoneWithOptimisticUI(item3)
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
        let item1 = TodoItemViewModel.make(plannableId: "1", date: Date(), plannableType: "assignment")
        let item2 = TodoItemViewModel.make(plannableId: "2", date: Date(), plannableType: "assignment")
        let item3 = TodoItemViewModel.make(plannableId: "3", date: Date(), plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date().startOfDay(), items: [item1, item2, item3])
        testee.items = [group]
        interactor.todoGroups.send([group])

        // WHEN
        testee.markItemAsDoneWithOptimisticUI(item1)
        testee.markItemAsDoneWithOptimisticUI(item2)
        testee.markItemAsDoneWithOptimisticUI(item3)
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
        let item1 = TodoItemViewModel.make(plannableId: "1", date: Date(), plannableType: "assignment")
        let item2 = TodoItemViewModel.make(plannableId: "2", date: Date(), plannableType: "assignment")
        let item3 = TodoItemViewModel.make(plannableId: "3", date: Date(), plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date().startOfDay(), items: [item1, item2, item3])
        testee.items = [group]
        interactor.todoGroups.send([group])

        interactor.markItemAsDoneResult = .success(())

        // WHEN - swipe all items
        testee.markItemAsDoneWithOptimisticUI(item1)

        // Change result to failure for item2
        interactor.markItemAsDoneResult = .failure(NSError.internalError())
        testee.markItemAsDoneWithOptimisticUI(item2)

        // Change result back to success for item3
        interactor.markItemAsDoneResult = .success(())
        testee.markItemAsDoneWithOptimisticUI(item3)

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

        testee.items = [group1, group2]
        interactor.todoGroups.send([group1, group2])

        // WHEN
        testee.markItemAsDoneWithOptimisticUI(item1)
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

        testee.items = [group1, group2]
        interactor.todoGroups.send([group1, group2])

        // WHEN - remove all items from first group
        testee.markItemAsDoneWithOptimisticUI(item1)
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
        testee.items = [group]
        testee.state = .data
        interactor.todoGroups.send([group])

        // WHEN
        testee.markItemAsDoneWithOptimisticUI(item)
        XCTAssertEqual(testee.state, .empty)

        testScheduler.advance()

        // THEN
        XCTAssertEqual(testee.state, .data)
        XCTAssertEqual(testee.items.count, 1)
    }
}
