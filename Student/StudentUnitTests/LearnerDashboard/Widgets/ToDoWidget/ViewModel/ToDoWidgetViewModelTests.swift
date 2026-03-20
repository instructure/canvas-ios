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
import CombineSchedulers
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class ToDoWidgetViewModelTests: StudentTestCase {

    private static let testData = (
        today: Date.make(year: 2025, month: 9, day: 10),
        otherDay: Date.make(year: 2025, month: 9, day: 15),
        itemId1: "item-id-1",
        itemId2: "item-id-2"
    )
    private lazy var testData = Self.testData

    private var testee: ToDoWidgetViewModel!
    private var interactor: TodoInteractorMock!
    private var snackBarViewModel: SnackBarViewModel!
    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        Clock.mockNow(testData.today)
        interactor = .init()
        snackBarViewModel = .init()
        scheduler = DispatchQueue.test
        testee = makeViewModel()
    }

    override func tearDown() {
        testee = nil
        interactor = nil
        snackBarViewModel = nil
        scheduler = nil
        Clock.reset()
        super.tearDown()
    }

    // MARK: - Initial state

    func test_init_shouldSelectToday() {
        XCTAssertEqual(testee.selectedDay, testData.today.startOfDay())
    }

    func test_init_shouldSetCurrentWeekDays() {
        XCTAssertEqual(testee.currentWeekDays.first, testData.today.startOfWeek())
        XCTAssertEqual(testee.currentWeekDays.count, 7)
    }

    // MARK: - shouldShowTodayButton

    func test_shouldShowTodayButton() {
        Clock.reset()

        // WHEN selected day is the real system today
        testee.didTapTodayButton()
        // THEN
        XCTAssertEqual(testee.shouldShowTodayButton, false)

        // WHEN selected day is another day
        testee.didTapDay(testData.otherDay)
        // THEN
        XCTAssertEqual(testee.shouldShowTodayButton, true)
    }

    // MARK: - Day selection

    func test_didTapDay_shouldUpdateSelectedDay() {
        testee.didTapDay(testData.otherDay)
        XCTAssertEqual(testee.selectedDay, testData.otherDay.startOfDay())
    }

    func test_didTapDay_shouldUpdateCurrentWeekDays() {
        testee.didTapDay(testData.otherDay)
        XCTAssertEqual(testee.currentWeekDays.first, testData.otherDay.startOfWeek())
    }

    func test_didTapTodayButton_shouldResetSelectedDayToToday() {
        testee.didTapDay(testData.otherDay)
        testee.didTapTodayButton()
        XCTAssertEqual(testee.selectedDay, testData.today.startOfDay())
        XCTAssertEqual(testee.currentWeekDays.first, testData.today.startOfWeek())
    }

    // MARK: - Week navigation

    func test_setWeek_withZeroOffset_shouldSetCurrentWeek() {
        testee.setWeek(absoluteOffset: 0)
        XCTAssertEqual(testee.currentWeekDays.first, testData.today.startOfWeek())
    }

    func test_setWeek_withPositiveOffset_shouldAdvanceWeek() {
        testee.setWeek(absoluteOffset: 2)
        let expected = testData.today.startOfWeek().addWeeks(2)
        XCTAssertEqual(testee.currentWeekDays.first, expected)
    }

    func test_setWeek_shouldTriggerRangedRefresh() {
        let countBefore = interactor.rangedRefreshCallCount
        testee.setWeek(absoluteOffset: 1)
        XCTAssertEqual(interactor.rangedRefreshCallCount, countBefore + 1)
    }

    func test_weekDays_forOffset_shouldReturnSevenDaysStartingFromWeekStart() {
        let days = testee.weekDays(forOffset: 0)
        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(days.first, testData.today.startOfWeek())
    }

    func test_weekDays_withPositiveOffset_shouldReturnCorrectWeek() {
        let days = testee.weekDays(forOffset: 1)
        let expectedStart = testData.today.startOfWeek().addWeeks(1)
        XCTAssertEqual(days.first, expectedStart)
    }

    // MARK: - State transitions from todoGroups subscription

    func test_todoGroupsReceived_withItems_shouldSetDataState() {
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [makeItem()])])
        waitUntil(shouldFail: true) { self.testee.state == .data }
    }

    func test_todoGroupsReceived_whenEmpty_shouldSetEmptyState() {
        interactor.todoGroups.send([])
        waitUntil(shouldFail: true) { self.testee.state == .empty }
    }

    func test_todoGroupsReceived_afterError_shouldClearError() {
        interactor.rangedRefreshResult = .failure(NSError(domain: "TestError", code: 1))
        testee = makeViewModel()
        testee.didTapRetryButton()
        waitUntil(shouldFail: true) { self.testee.state == .error }

        interactor.rangedRefreshResult = .success(())
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [makeItem()])])
        waitUntil(shouldFail: true) { self.testee.state == .data }
    }

    // MARK: - listViewModel.items (dayItems)

    func test_listViewModelItems_shouldReturnItemsForSelectedDay() {
        let item1 = makeItem(plannableId: testData.itemId1, date: testData.today)
        let item2 = makeItem(plannableId: testData.itemId2, date: testData.otherDay)
        interactor.todoGroups.send([
            makeGroup(date: testData.today, items: [item1]),
            makeGroup(date: testData.otherDay, items: [item2])
        ])
        waitUntil(shouldFail: true) { self.testee.state == .data }

        XCTAssertEqual(testee.listViewModel.items.count, 1)
        XCTAssertEqual(testee.listViewModel.items.first?.plannableId, testData.itemId1)
    }

    func test_listViewModelItems_whenShowCompletedFalse_shouldExcludeDoneItems() {
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.state == .empty }

        XCTAssertEqual(testee.listViewModel.items.isEmpty, true)
    }

    func test_listViewModelItems_whenShowCompletedTrue_shouldIncludeDoneItems() {
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        item.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.state == .empty }

        testee.showCompleted = true

        waitUntil(shouldFail: true) { self.testee.listViewModel.items.count == 1 }
    }

    func test_listViewModelItems_shouldKeepDoneItemVisibleWhilePendingRemoval() {
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])
        waitUntil(shouldFail: true) { self.testee.state == .data }

        testee.listViewModel.markItemAsDone(item)
        waitUntil(shouldFail: true) { item.markAsDoneState == .done }

        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item])])

        XCTAssertEqual(testee.listViewModel.items.count, 1)
        XCTAssertEqual(testee.listViewModel.items.first?.plannableId, testData.itemId1)
    }

    // MARK: - itemCountPerDay

    func test_itemCountPerDay_shouldReflectVisibleItemCountsPerDate() {
        let item1 = makeItem(plannableId: testData.itemId1, date: testData.today)
        let item2 = makeItem(plannableId: testData.itemId2, date: testData.today)
        let doneItem = makeItem(plannableId: "done-item", date: testData.today)
        doneItem.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item1, item2, doneItem])])
        waitUntil(shouldFail: true) { self.testee.state == .data }

        let key = testData.today.startOfDay()
        XCTAssertEqual(testee.itemCountPerDay[key], 2)
    }

    func test_itemCountPerDay_whenShowCompletedChanges_shouldUpdate() {
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        let doneItem = makeItem(plannableId: "done-item", date: testData.today)
        doneItem.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item, doneItem])])
        waitUntil(shouldFail: true) { self.testee.state == .data }

        let key = testData.today.startOfDay()
        XCTAssertEqual(testee.itemCountPerDay[key], 1)

        testee.showCompleted = true
        XCTAssertEqual(testee.itemCountPerDay[key], 2)
    }

    // MARK: - showCompleted

    func test_showCompleted_shouldPropagateToListViewModel() {
        XCTAssertEqual(testee.listViewModel.showCompleted, false)

        testee.showCompleted = true
        XCTAssertEqual(testee.listViewModel.showCompleted, true)

        testee.showCompleted = false
        XCTAssertEqual(testee.listViewModel.showCompleted, false)
    }

    func test_showCompleted_shouldToggle() {
        // WHEN false → set true
        XCTAssertEqual(testee.showCompleted, false)
        testee.showCompleted = true
        // THEN
        XCTAssertEqual(testee.showCompleted, true)

        // WHEN true → set false
        testee.showCompleted = false
        // THEN
        XCTAssertEqual(testee.showCompleted, false)
    }

    func test_showCompleted_whenTurningOn_shouldRestoreDoneItemsFromInteractor() {
        let item = makeItem(plannableId: testData.itemId1, date: testData.today)
        let doneItem = makeItem(plannableId: "done-item", date: testData.today)
        doneItem.markAsDoneState = .done
        interactor.todoGroups.send([makeGroup(date: testData.today, items: [item, doneItem])])
        waitUntil(shouldFail: true) { self.testee.state == .data }
        XCTAssertEqual(testee.listViewModel.items.count, 1)

        testee.showCompleted = true

        XCTAssertEqual(testee.listViewModel.items.count, 2)
    }

    // MARK: - plannerItemDidChange notification

    func test_plannerItemDidChange_shouldTriggerRangedRefresh() {
        let countBefore = interactor.rangedRefreshCallCount

        NotificationCenter.default.post(name: .plannerItemDidChange, object: nil)

        waitUntil(shouldFail: true) { self.interactor.rangedRefreshCallCount == countBefore + 1 }
        XCTAssertEqual(interactor.rangedRefreshCallCount, countBefore + 1)
    }

    // MARK: - didTapRetryButton

    func test_didTapRetryButton_shouldSetLoadingState() {
        interactor.todoGroups.send([])
        waitUntil(shouldFail: true) { self.testee.state == .empty }

        testee.didTapRetryButton()

        XCTAssertEqual(testee.state, .loading)
    }

    func test_didTapRetryButton_shouldTriggerRangedRefresh() {
        let countBefore = interactor.rangedRefreshCallCount

        testee.didTapRetryButton()

        XCTAssertEqual(interactor.rangedRefreshCallCount, countBefore + 1)
    }

    // MARK: - refresh

    func test_refresh_shouldCallRangedRefresh() {
        let countBefore = interactor.rangedRefreshCallCount

        _ = testee.refresh(ignoreCache: false)

        XCTAssertEqual(interactor.rangedRefreshCallCount, countBefore + 1)
    }

    func test_refresh_onFailure_shouldSetErrorState() {
        interactor.rangedRefreshResult = .failure(NSError(domain: "TestError", code: 1))

        let publisher = testee.refresh(ignoreCache: false)
        var completed = false
        let cancellable = publisher.sink { completed = true }
        waitUntil(shouldFail: true) { completed }

        XCTAssertEqual(testee.state, .error)
        _ = cancellable
    }

    // MARK: - yearTitle / monthTitle

    func test_monthTitle_shouldReflectSelectedDayMonth() {
        let expected = testData.today.formatted(.dateTime.month(.wide))
        XCTAssertEqual(testee.monthTitle, expected)
    }

    func test_yearTitle_whenCurrentYear_shouldBeNil() {
        XCTAssertEqual(testee.yearTitle, nil)
    }

    // MARK: - Private helpers

    private func makeViewModel() -> ToDoWidgetViewModel {
        ToDoWidgetViewModel(
            config: .make(id: .todo),
            interactor: interactor,
            router: router,
            snackBarViewModel: snackBarViewModel,
            scheduler: scheduler.eraseToAnyScheduler()
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
