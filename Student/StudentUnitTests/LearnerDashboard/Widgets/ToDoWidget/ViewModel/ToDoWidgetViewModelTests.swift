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

import Combine
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class ToDoWidgetViewModelTests: StudentTestCase {

    private static let testData = (
        today: Date.make(year: 2025, month: 9, day: 10),
        otherDay: Date.make(year: 2025, month: 9, day: 15),
        title1: "title 1",
        title2: "title 2",
        itemId1: "item-id-1",
        itemId2: "item-id-2"
    )
    private lazy var testData = Self.testData

    private var testee: ToDoWidgetViewModel!
    private var interactor: TodoInteractorMock!
    private var snackBarViewModel: SnackBarViewModel!

    override func setUp() {
        super.setUp()
        Clock.mockNow(testData.today)
        interactor = TodoInteractorMock()
        snackBarViewModel = SnackBarViewModel()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        snackBarViewModel = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_init_shouldSetLoadingState() {
        makeTestee()
        XCTAssertEqual(testee.state, .loading)
    }

    func test_init_shouldSelectToday() {
        makeTestee()
        XCTAssertEqual(testee.selectedDay, Calendar.current.startOfDay(for: testData.today))
    }

    func test_init_shouldSetCurrentWeekStart() {
        makeTestee()
        XCTAssertEqual(testee.weekStart, ToDoWidgetViewModel.startOfWeek(for: testData.today))
    }

    func test_init_shouldTriggerRangedRefresh() {
        makeTestee()
        XCTAssertEqual(interactor.rangedRefreshCalled, true)
    }

    // MARK: - startOfWeek

    func test_startOfWeek_shouldReturnFirstDayOfWeek() {
        let result = ToDoWidgetViewModel.startOfWeek(for: testData.today)
        let expected = Calendar.current.dateInterval(of: .weekOfYear, for: testData.today)?.start
        XCTAssertEqual(result, expected)
    }

    // MARK: - isShowingToday

    func test_isShowingToday() {
        makeTestee()

        // WHEN selected day is today
        // THEN
        XCTAssertEqual(testee.isShowingToday, true)

        // WHEN selected day is another day
        testee.selectDay(testData.otherDay)
        // THEN
        XCTAssertEqual(testee.isShowingToday, false)
    }

    // MARK: - Day selection

    func test_selectDay_shouldUpdateSelectedDay() {
        makeTestee()
        testee.selectDay(testData.otherDay)
        XCTAssertEqual(testee.selectedDay, Calendar.current.startOfDay(for: testData.otherDay))
    }

    func test_navigateToToday_shouldResetSelectedDayAndWeekStart() {
        makeTestee()
        testee.selectDay(testData.otherDay)
        testee.navigateToToday()
        XCTAssertEqual(testee.selectedDay, Calendar.current.startOfDay(for: testData.today))
        XCTAssertEqual(testee.weekStart, ToDoWidgetViewModel.startOfWeek(for: testData.today))
    }

    // MARK: - Week navigation

    func test_setWeek_withZeroOffset_shouldSetCurrentWeek() {
        makeTestee()
        testee.setWeek(absoluteOffset: 0)
        XCTAssertEqual(testee.weekStart, ToDoWidgetViewModel.startOfWeek(for: testData.today))
    }

    func test_setWeek_withPositiveOffset_shouldAdvanceWeek() {
        makeTestee()
        testee.setWeek(absoluteOffset: 2)
        let expected = Calendar.current.date(
            byAdding: .weekOfYear, value: 2,
            to: ToDoWidgetViewModel.startOfWeek(for: testData.today)
        )
        XCTAssertEqual(testee.weekStart, expected)
    }

    func test_setWeek_shouldTriggerRangedRefresh() {
        makeTestee()
        let countBefore = interactor.rangedRefreshCallCount
        testee.setWeek(absoluteOffset: 1)
        XCTAssertEqual(interactor.rangedRefreshCallCount, countBefore + 1)
    }

    // MARK: - State transitions from todoGroups subscription

    func test_todoGroupsReceived_withItems_shouldSetDataState() {
        makeTestee()
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [makeItem()])])
        waitUntil(shouldFail: true) { self.testee.state == .data }
    }

    func test_todoGroupsReceived_whenEmpty_shouldSetEmptyState() {
        makeTestee()
        interactor.todoGroups.send([])
        waitUntil(shouldFail: true) { self.testee.state == .empty }
    }

    func test_todoGroupsReceived_afterError_shouldClearError() {
        interactor.rangedRefreshResult = .failure(NSError(domain: "TestError", code: 1))
        makeTestee()
        waitUntil(shouldFail: true) { self.testee.state == .error }

        interactor.rangedRefreshResult = .success(())
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [makeItem()])])
        waitUntil(shouldFail: true) { self.testee.state == .data }
    }

    // MARK: - dayItems

    func test_dayItems_shouldReturnItemsForSelectedDay() {
        makeTestee()
        let item1 = makeItem(plannableId: testData.itemId1, date: testData.today)
        let item2 = makeItem(plannableId: testData.itemId2, date: testData.otherDay)
        interactor.todoGroups.send([
            makeGroup(date: testData.today, items: [item1]),
            makeGroup(date: testData.otherDay, items: [item2])
        ])
        waitUntil(shouldFail: true) { self.testee.state == .data }

        XCTAssertEqual(testee.dayItems.count, 1)
        XCTAssertEqual(testee.dayItems.first?.plannableId, testData.itemId1)
    }

    func test_dayItems_whenShowCompletedFalse_shouldExcludeDoneItems() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.state == .empty }

        XCTAssertEqual(testee.dayItems.isEmpty, true)
    }

    func test_dayItems_whenShowCompletedTrue_shouldIncludeDoneItems() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.state == .empty }

        testee.toggleShowCompleted()

        XCTAssertEqual(testee.dayItems.count, 1)
    }

    // MARK: - itemCounts

    func test_itemCounts_shouldReflectVisibleItemCountsPerDate() {
        makeTestee()
        let item1 = makeItem(plannableId: testData.itemId1, date: testData.today)
        let item2 = makeItem(plannableId: testData.itemId2, date: testData.today)
        let doneItem = makeItem(plannableId: "done-item", date: testData.today)
        doneItem.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item1, item2, doneItem])])
        waitUntil(shouldFail: true) { self.testee.state == .data }

        let key = Calendar.current.startOfDay(for: testData.today)
        XCTAssertEqual(testee.itemCounts[key], 2)
    }

    func test_itemCounts_whenShowCompletedChanges_shouldUpdate() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        let doneItem = makeItem(plannableId: "done-item", date: testData.today)
        doneItem.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item, doneItem])])
        waitUntil(shouldFail: true) { self.testee.state == .data }

        let key = Calendar.current.startOfDay(for: testData.today)
        XCTAssertEqual(testee.itemCounts[key], 1)

        testee.toggleShowCompleted()
        XCTAssertEqual(testee.itemCounts[key], 2)
    }

    // MARK: - toggleShowCompleted

    func test_toggleShowCompleted_shouldToggleFlag() {
        makeTestee()

        // WHEN false → toggle
        XCTAssertEqual(testee.showCompleted, false)
        testee.toggleShowCompleted()
        // THEN
        XCTAssertEqual(testee.showCompleted, true)

        // WHEN true → toggle
        testee.toggleShowCompleted()
        // THEN
        XCTAssertEqual(testee.showCompleted, false)
    }

    func test_toggleShowCompleted_whenTurningOn_shouldRestoreDoneItemsFromInteractor() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        let doneItem = makeItem(plannableId: "done-item", date: testData.today)
        doneItem.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item, doneItem])])
        waitUntil(shouldFail: true) { self.testee.state == .data }
        XCTAssertEqual(testee.dayItems.count, 1)

        testee.toggleShowCompleted()

        XCTAssertEqual(testee.dayItems.count, 2)
    }

    // MARK: - markItemAsDone

    func test_markItemAsDone_whenNotDone_shouldCallInteractorWithDoneTrue() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)

        testee.markItemAsDone(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, true)
        XCTAssertEqual(interactor.lastMarkAsDoneDone, true)
    }

    func test_markItemAsDone_whenAlreadyDone_shouldCallInteractorWithDoneFalse() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.markAsDoneState = .done

        testee.markItemAsDone(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, true)
        XCTAssertEqual(interactor.lastMarkAsDoneDone, false)
    }

    func test_markItemAsDone_whenLoading_shouldNotCallInteractor() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.markAsDoneState = .loading

        testee.markItemAsDone(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, false)
    }

    func test_markItemAsDone_onSuccess_shouldSetItemStateToDone() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.shouldKeepCompletedItemsVisible = true

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { item.markAsDoneState == .done }
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    func test_markItemAsDone_onSuccess_shouldShowDoneSnack() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, title: testData.title1, date: testData.today)
        item.shouldKeepCompletedItemsVisible = true

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { self.snackBarViewModel.visibleSnack != nil }
        XCTAssertEqual(snackBarViewModel.visibleSnack?.contains(testData.title1), true)
    }

    func test_markItemAsDone_onFailure_shouldRestoreItemStateAndShowSnack() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        interactor.markItemAsDoneResult = .failure(NSError(domain: "TestError", code: 1))

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { item.markAsDoneState == .notDone && self.snackBarViewModel.visibleSnack != nil }
        XCTAssertEqual(item.markAsDoneState, .notDone)
        XCTAssertNotNil(snackBarViewModel.visibleSnack)
    }

    func test_markItemAsDone_afterDelay_whenShowCompletedFalse_shouldRemoveItem() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.dayItems.count == 1 }

        testee.markItemAsDone(item)

        let expectation = expectation(description: "Item removed after 3-second delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(testee.dayItems.isEmpty, true)
    }

    // MARK: - handleSwipeAction

    func test_handleSwipeAction_whenShouldRemoveOptimistically_shouldRemoveItemImmediately() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.dayItems.count == 1 }

        testee.handleSwipeAction(item)

        XCTAssertEqual(testee.dayItems.isEmpty, true)
    }

    func test_handleSwipeAction_onApiFailure_shouldRestoreItem() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.dayItems.count == 1 }
        interactor.markItemAsDoneResult = .failure(NSError(domain: "TestError", code: 1))

        testee.handleSwipeAction(item)

        waitUntil(shouldFail: true) { self.testee.dayItems.isEmpty == false }
        XCTAssertEqual(testee.dayItems.count, 1)
    }

    func test_handleSwipeAction_whenShouldToggleInPlace_shouldCallInteractor() {
        makeTestee()
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.markAsDoneState = .done
        item.shouldKeepCompletedItemsVisible = true

        testee.handleSwipeAction(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, true)
    }

    // MARK: - retryLoad

    func test_retryLoad_shouldSetLoadingState() {
        makeTestee()
        interactor.todoGroups.send([])
        waitUntil(shouldFail: true) { self.testee.state == .empty }

        testee.retryLoad()

        XCTAssertEqual(testee.state, .loading)
    }

    func test_retryLoad_shouldTriggerRangedRefresh() {
        makeTestee()
        let countBefore = interactor.rangedRefreshCallCount

        testee.retryLoad()

        XCTAssertEqual(interactor.rangedRefreshCallCount, countBefore + 1)
    }

    // MARK: - Private helpers

    private func makeTestee() {
        testee = ToDoWidgetViewModel(
            config: .make(id: .toDo),
            interactor: interactor,
            router: router,
            snackBarViewModel: snackBarViewModel
        )
    }

    private func makeGroup(date: Date, items: [TodoItemViewModel]) -> TodoGroupViewModel {
        TodoGroupViewModel(date: date, items: items)
    }

    private func makeItem(
        plannableId: String = "item-id",
        title: String = "title 1",
        date: Date = Date.make(year: 2025, month: 9, day: 10)
    ) -> TodoItemViewModel {
        TodoItemViewModel.make(plannableId: plannableId, type: .planner_note, date: date, title: title)
    }
}
