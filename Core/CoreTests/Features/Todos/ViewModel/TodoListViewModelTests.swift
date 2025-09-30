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
        interactor.refreshResult = .success(())

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
        interactor.refreshResult = .success(())

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
        interactor.refreshResult = .success(())
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
        interactor.refreshResult = .success(())
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
        interactor.refreshResult = .success(())
        interactor.todoGroupsSubject.send([TodoGroupViewModel(date: Date(), items: [TodoItemViewModel.make(id: "1", title: "Test")])])
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .data)

        // When - with empty todos
        interactor.refreshResult = .success(())
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
        interactor.refreshResult = .success(())

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
}
