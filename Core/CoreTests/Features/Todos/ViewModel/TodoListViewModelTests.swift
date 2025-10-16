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

class TodoListViewModelTests: CoreTestCase {

    private var interactor: TodoInteractorMock!
    private var testee: TodoListViewModel!

    // MARK: - Setup and teardown

    override func setUp() {
        super.setUp()
        interactor = .init()
        testee = .init(interactor: interactor, env: environment)
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
            TodoItemViewModel.make(id: "1", title: "Test Item 1"),
            TodoItemViewModel.make(id: "2", title: "Test Item 2")
        ]
        let testGroups = [TodoGroupViewModel(date: Date(), items: testItems)]

        // When
        interactor.todoGroupsSubject.send(testGroups)

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
        interactor.todoGroupsSubject.send([TodoGroupViewModel(date: Date(), items: [TodoItemViewModel.make(id: "1", title: "Test Item")])])

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
        interactor.todoGroupsSubject.send([])

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
        let todo = TodoItemViewModel.make(id: "123", type: .planner_note)
        interactor.todoGroupsSubject.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNotNil(router.lastViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .detail)
    }

    func testDidTapItemCalendarEvent() {
        // Given
        let todo = TodoItemViewModel.make(
            id: "456",
            type: .calendar_event,
            htmlURL: URL(string: "https://canvas.instructure.com/calendar")
        )
        interactor.todoGroupsSubject.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNotNil(router.lastViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .detail)
    }

    func testDidTapItemOtherTypeWithURL() {
        // Given
        let todo = TodoItemViewModel.make(
            id: "789",
            type: .assignment,
            htmlURL: URL(string: "https://canvas.instructure.com/courses/1/assignments/789"))
        interactor.todoGroupsSubject.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssert(router.lastRoutedTo("https://canvas.instructure.com/courses/1/assignments/789?origin=todo"))
    }

    func testDidTapItemOtherTypeWithoutURL() {
        // Given
        let todo = TodoItemViewModel.make(id: "999", type: .assignment, htmlURL: nil as URL?)
        interactor.todoGroupsSubject.send([TodoGroupViewModel(date: Date(), items: [todo])])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNil(router.lastViewController)
    }

    func testStateUpdatesCorrectly() {
        XCTAssertEqual(testee.state, .empty)

        // When - with non-empty todos
        interactor.refreshResult = .success
        interactor.todoGroupsSubject.send([TodoGroupViewModel(date: Date(), items: [TodoItemViewModel.make(id: "1", title: "Test")])])
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .data)

        // When - with empty todos
        interactor.refreshResult = .success
        interactor.todoGroupsSubject.send([])
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
        let item = TodoItemViewModel.make(id: "1")

        // THEN
        XCTAssertEqual(item.markDoneState, .notDone)
    }

    func test_markItemAsDone_onSuccess_changesStateToDone() {
        // GIVEN
        Plannable.save(APIPlannable.make(plannable_id: ID("1")), userId: nil, in: databaseClient)
        api.mock(CreatePlannerOverrideRequest(body: .init(plannable_type: "assignment", plannable_id: "1", marked_complete: true)), value: APIPlannerOverride.make(id: "override-1", marked_complete: true))
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment")

        // WHEN
        testee.markItemAsDone(item)

        // THEN
        waitUntil(shouldFail: true) { item.markDoneState == .done }
    }

    func test_markItemAsDone_onError_changesStateBackToNotDone() {
        // GIVEN
        api.mock(UpdatePlannerOverrideRequest(overrideId: "override-1", body: .init(marked_complete: true)), error: NSError.internalError())
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment", overrideId: "override-1")

        // WHEN
        testee.markItemAsDone(item)

        // THEN
        waitUntil(shouldFail: true) { item.markDoneState == .notDone }
    }

    func test_markItemAsDone_onError_showsSnackBar() {
        // GIVEN
        api.mock(UpdatePlannerOverrideRequest(overrideId: "override-1", body: .init(marked_complete: true)), error: NSError.internalError())
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment", overrideId: "override-1")

        // WHEN
        testee.markItemAsDone(item)

        // THEN
        waitUntil(shouldFail: true) { testee.snackBar.visibleSnack != nil }
    }

    func test_markItemAsDone_removesItemAfterThreeSeconds() {
        // GIVEN
        Plannable.save(APIPlannable.make(plannable_id: ID("1")), userId: nil, in: databaseClient)
        api.mock(CreatePlannerOverrideRequest(body: .init(plannable_type: "assignment", plannable_id: "1", marked_complete: true)), value: APIPlannerOverride.make(id: "override-1", marked_complete: true))
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]

        // WHEN
        testee.markItemAsDone(item)

        // THEN
        waitUntil(shouldFail: true) { item.markDoneState == .done }
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items.first?.items.count, 1)

        waitUntil(4, shouldFail: true) { testee.items.count == 0 }
    }

    func test_markItemAsDone_whileDone_marksAsUndone() {
        // GIVEN
        Plannable.save(APIPlannable.make(planner_override: .make(id: "override-1", marked_complete: true), plannable_id: ID("1")), userId: nil, in: databaseClient)
        api.mock(UpdatePlannerOverrideRequest(overrideId: "override-1", body: .init(marked_complete: false)), value: APINoContent())
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment", overrideId: "override-1")
        item.markDoneState = .done

        // WHEN
        testee.markItemAsDone(item)

        // THEN
        waitUntil(shouldFail: true) { item.markDoneState == .notDone }
    }

    func test_markItemAsDone_undoBeforeRemoval_cancelsTimer() {
        // GIVEN
        Plannable.save(APIPlannable.make(plannable_id: ID("1")), userId: nil, in: databaseClient)
        api.mock(CreatePlannerOverrideRequest(body: .init(plannable_type: "assignment", plannable_id: "1", marked_complete: true)), value: APIPlannerOverride.make(id: "override-1", marked_complete: true))
        api.mock(UpdatePlannerOverrideRequest(overrideId: "override-1", body: .init(marked_complete: false)), value: APINoContent())
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment", overrideId: "override-1")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]

        // WHEN
        testee.markItemAsDone(item)
        waitUntil(shouldFail: true) { item.markDoneState == .done }

        testee.markItemAsDone(item)
        waitUntil(shouldFail: true) { item.markDoneState == .notDone }

        // THEN
        waitUntil(4, shouldFail: true) { testee.items.count == 1 && testee.items.first?.items.count == 1 }
    }

    func test_markAsUndone_onError_changesStateBackToDone() {
        // GIVEN
        api.mock(UpdatePlannerOverrideRequest(overrideId: "override-1", body: .init(marked_complete: false)), error: NSError.internalError())
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment", overrideId: "override-1")
        item.markDoneState = .done

        // WHEN
        testee.markItemAsDone(item)

        // THEN
        waitUntil(shouldFail: true) { item.markDoneState == .done }
    }

    func test_markAsUndone_onError_showsSnackBar() {
        // GIVEN
        api.mock(UpdatePlannerOverrideRequest(overrideId: "override-1", body: .init(marked_complete: false)), error: NSError.internalError())
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment", overrideId: "override-1")
        item.markDoneState = .done

        // WHEN
        testee.markItemAsDone(item)

        // THEN
        waitUntil(shouldFail: true) { testee.snackBar.visibleSnack != nil }
    }

    func test_removeItem_removesEmptyGroups() {
        // GIVEN
        let item1 = TodoItemViewModel.make(id: "1", plannableType: "assignment")
        let item2 = TodoItemViewModel.make(id: "2")
        let group1 = TodoGroupViewModel(date: Date(), items: [item1])
        let group2 = TodoGroupViewModel(date: Date().addingTimeInterval(86400), items: [item2])
        testee.items = [group1, group2]
        Plannable.save(APIPlannable.make(plannable_id: ID("1")), userId: nil, in: databaseClient)
        api.mock(CreatePlannerOverrideRequest(body: .init(plannable_type: "assignment", plannable_id: "1", marked_complete: true)), value: APIPlannerOverride.make(id: "override-1", marked_complete: true))

        // WHEN
        testee.markItemAsDone(item1)
        waitUntil(shouldFail: true) { item1.markDoneState == .done }

        // THEN
        waitUntil(4, shouldFail: true) {
            testee.items.count == 1 && testee.items.first?.items.first?.id == "2"
        }
    }

    func test_removeItem_setsStateToEmpty_whenLastItemRemoved() {
        // GIVEN
        Plannable.save(APIPlannable.make(plannable_id: ID("1")), userId: nil, in: databaseClient)
        api.mock(CreatePlannerOverrideRequest(body: .init(plannable_type: "assignment", plannable_id: "1", marked_complete: true)), value: APIPlannerOverride.make(id: "override-1", marked_complete: true))
        let item = TodoItemViewModel.make(id: "1", plannableType: "assignment")
        let group = TodoGroupViewModel(date: Date(), items: [item])
        testee.items = [group]
        testee.state = .data

        // WHEN
        testee.markItemAsDone(item)
        waitUntil(shouldFail: true) { item.markDoneState == .done }

        // THEN
        waitUntil(4, shouldFail: true) {
            testee.items.count == 0 && testee.state == .empty
        }
    }
}
