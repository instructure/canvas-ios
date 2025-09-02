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
        XCTAssertEqual(testee.state, .data)
    }

    func testInitialRefreshCalled() {
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertFalse(interactor.lastIgnoreCache)
    }

    func testItemsUpdateFromInteractor() {
        // Given
        let testItems = [
            TodoItem.make(id: "1", title: "Test Item 1"),
            TodoItem.make(id: "2", title: "Test Item 2")
        ]

        // When
        interactor.todosSubject.send(testItems)

        // Then
        XCTAssertFirstValue(testee.$items) { items in
            XCTAssertEqual(items, testItems)
        }
    }

    func testRefreshWithIgnoreCacheTrue() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success(false)

        // When
        testee.refresh(completion: {
            expectation.fulfill()
        }, ignoreCache: true)

        // Then
        XCTAssertTrue(interactor.refreshCalled)
        XCTAssertTrue(interactor.lastIgnoreCache)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(testee.state, .data)
    }

    func testRefreshWithIgnoreCacheFalse() {
        // Given
        let expectation = expectation(description: "Refresh completion called")
        interactor.refreshResult = .success(false)

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
        interactor.refreshResult = .success(false)

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
        interactor.refreshResult = .success(true)

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
        let todo = TodoItem.make(id: "123", type: .planner_note)
        interactor.todosSubject.send([todo])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNotNil(router.lastViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .detail)
    }

    func testDidTapItemCalendarEvent() {
        // Given
        let todo = TodoItem.make(
            id: "456",
            type: .calendar_event,
            htmlURL: URL(string: "https://canvas.instructure.com/calendar")
        )
        interactor.todosSubject.send([todo])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNotNil(router.lastViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.2, .detail)
    }

    func testDidTapItemOtherTypeWithURL() {
        // Given
        let todo = TodoItem.make(
            id: "789",
            type: .assignment,
            htmlURL: URL(string: "https://canvas.instructure.com/courses/1/assignments/789"))
        interactor.todosSubject.send([todo])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssert(router.lastRoutedTo("https://canvas.instructure.com/courses/1/assignments/789?origin=todo"))
    }

    func testDidTapItemOtherTypeWithoutURL() {
        // Given
        let todo = TodoItem.make(id: "999", type: .assignment, htmlURL: nil as URL?)
        interactor.todosSubject.send([todo])

        // When
        testee.didTapItem(todo, WeakViewController())

        // Then
        XCTAssertNil(router.lastViewController)
    }

    func testStateUpdatesCorrectly() {
        XCTAssertEqual(testee.state, .data)

        // When
        interactor.refreshResult = .success(false)
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .data)

        // When
        interactor.refreshResult = .success(true)
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .empty)

        // When
        interactor.refreshResult = .failure(NSError.internalError())
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(testee.state, .error)
    }

    func testMultipleRefreshCalls() {
        // Given
        interactor.refreshCallCount = 0
        interactor.refreshResult = .success(false)

        // When
        testee.refresh(completion: {}, ignoreCache: false)
        testee.refresh(completion: {}, ignoreCache: true)
        testee.refresh(completion: {}, ignoreCache: false)

        // Then
        XCTAssertEqual(interactor.refreshCallCount, 3)
    }
}
