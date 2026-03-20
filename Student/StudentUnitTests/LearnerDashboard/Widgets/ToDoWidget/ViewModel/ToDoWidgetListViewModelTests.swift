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

final class ToDoWidgetListViewModelTests: StudentTestCase {

    private static let testData = (
        today: Date.make(year: 2025, month: 9, day: 10),
        title: "some title"
    )
    private lazy var testData = Self.testData

    private var testee: ToDoWidgetListViewModel!
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

    // MARK: - markItemAsDone

    func test_markItemAsDone_whenNotDone_shouldCallInteractorWithDoneTrue() {
        let item = makeItem()

        testee.markItemAsDone(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, true)
        XCTAssertEqual(interactor.lastMarkAsDoneDone, true)
    }

    func test_markItemAsDone_whenAlreadyDone_shouldCallInteractorWithDoneFalse() {
        let item = makeItem()
        item.markAsDoneState = .done

        testee.markItemAsDone(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, true)
        XCTAssertEqual(interactor.lastMarkAsDoneDone, false)
    }

    func test_markItemAsDone_whenLoading_shouldNotCallInteractor() {
        let item = makeItem()
        item.markAsDoneState = .loading

        testee.markItemAsDone(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, false)
    }

    func test_markItemAsDone_onSuccess_shouldSetItemStateToDone() {
        let item = makeItem()
        testee.showCompleted = true

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { item.markAsDoneState == .done }
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    func test_markItemAsDone_onSuccess_whenShowCompleted_shouldNotStartRemovalTimer() {
        let item = makeItem()
        testee.showCompleted = true

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { item.markAsDoneState == .done }
        XCTAssertEqual(testee.markDoneTimers.isEmpty, true)
    }

    func test_markItemAsDone_onFailure_shouldRestoreItemStateAndShowSnack() {
        let item = makeItem()
        interactor.markItemAsDoneResult = .failure(NSError(domain: "TestError", code: 1))

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { item.markAsDoneState == .notDone && self.snackBarViewModel.visibleSnack != nil }
        XCTAssertEqual(item.markAsDoneState, .notDone)
        XCTAssertNotNil(snackBarViewModel.visibleSnack)
    }

    func test_markItemAsDone_afterDelay_whenShowCompletedFalse_shouldRemoveItem() {
        let item = makeItem()
        testee.items = [item]

        testee.markItemAsDone(item)
        waitUntil(shouldFail: true) { item.markAsDoneState == .done }

        scheduler.advance(by: .seconds(3))

        XCTAssertEqual(testee.items.isEmpty, true)
    }

    func test_markItemAsDone_onDoneAlready_onSuccess_shouldSetStateToNotDone() {
        let item = makeItem()
        item.markAsDoneState = .done

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { item.markAsDoneState == .notDone }
        XCTAssertEqual(item.markAsDoneState, .notDone)
    }

    func test_markItemAsDone_onDoneAlready_onFailure_shouldRestoreStateToDone() {
        let item = makeItem()
        item.markAsDoneState = .done
        interactor.markItemAsDoneResult = .failure(NSError(domain: "TestError", code: 1))

        testee.markItemAsDone(item)

        waitUntil(shouldFail: true) { self.snackBarViewModel.visibleSnack != nil }
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    // MARK: - handleSwipeAction

    func test_handleSwipeAction_whenShouldRemoveOptimistically_shouldRemoveItemImmediately() {
        let item = makeItem()
        testee.items = [item]

        testee.handleSwipeAction(item)

        XCTAssertEqual(testee.items.isEmpty, true)
    }

    func test_handleSwipeAction_onApiFailure_shouldRestoreItem() {
        let item = makeItem()
        testee.items = [item]
        interactor.todoGroups.send([TodoGroupViewModel(date: testData.today, items: [item])])
        interactor.markItemAsDoneResult = .failure(NSError(domain: "TestError", code: 1))

        testee.handleSwipeAction(item)

        waitUntil(shouldFail: true) { self.testee.items.isEmpty == false }
        XCTAssertEqual(testee.items.count, 1)
    }

    func test_handleSwipeAction_whenItemIsDone_shouldToggleInPlace() {
        let item = makeItem()
        item.markAsDoneState = .done

        testee.handleSwipeAction(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, true)
    }

    func test_handleSwipeAction_whenShowCompletedTrue_shouldToggleInPlace() {
        let item = makeItem()
        testee.showCompleted = true

        testee.handleSwipeAction(item)

        XCTAssertEqual(interactor.markItemAsDoneCalled, true)
    }

    func test_handleSwipeAction_onSuccess_shouldMarkItemAsDone() {
        let item = makeItem()

        testee.handleSwipeAction(item)

        waitUntil(shouldFail: true) { item.markAsDoneState == .done }
        XCTAssertEqual(item.markAsDoneState, .done)
    }

    // MARK: - handleSwipeCommitted

    func test_handleSwipeCommitted_shouldCancelDelayedRemove() {
        let item = makeItem()
        testee.items = [item]

        testee.markItemAsDone(item)
        waitUntil(shouldFail: true) { item.markAsDoneState == .done }

        testee.handleSwipeCommitted(item)
        scheduler.advance(by: .seconds(3))

        XCTAssertEqual(testee.items.count, 1)
    }

    // MARK: - Private helpers

    private func makeViewModel() -> ToDoWidgetListViewModel {
        ToDoWidgetListViewModel(
            interactor: interactor,
            router: router,
            snackBarViewModel: snackBarViewModel,
            scheduler: scheduler.eraseToAnyScheduler()
        )
    }

    private func makeItem(
        plannableId: String = "item-id",
        title: String = "",
        date: Date = testData.today
    ) -> TodoItemViewModel {
        TodoItemViewModel.make(plannableId: plannableId, type: .planner_note, date: date, title: title)
    }
}
