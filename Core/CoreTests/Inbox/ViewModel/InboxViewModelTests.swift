//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Core
import CoreData
import XCTest

class InboxViewModelTests: CoreTestCase {
    private var mockInteractor: InboxMessageInteractorMock!
    var testee: InboxViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = InboxMessageInteractorMock(context: databaseClient)
        testee = InboxViewModel(interactor: mockInteractor, router: router)
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.messages.count, 1)
        XCTAssertEqual(testee.messages.first?.id, "D34DB33F")
        XCTAssertEqual(testee.courses.count, 1)
        XCTAssertEqual(testee.courses.first?.courseId, "C0453")
        XCTAssertEqual(testee.hasNextPage, true)
    }

    // MARK: - Inputs

    func testRefreshForwardedToInteractor() {
        let refreshCompleted = expectation(description: "refresh callback received")

        testee.refreshDidTrigger.send {
            refreshCompleted.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertTrue(mockInteractor.refreshCalled)
    }

    func testMenuTapRoute() {
        let sourceView = UIViewController()

        testee.menuDidTap.send(WeakViewController(sourceView))

        wait(for: [router.routeExpectation], timeout: 1)
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: "/profile"))
        XCTAssertEqual(router.calls.last?.1, sourceView)
        XCTAssertEqual(router.calls.last?.2, .modal())
    }

    func testMessageTapRoute() {
        let sourceView = UIViewController()

        testee.messageDidTap.send((messageID: "1", controller: WeakViewController(sourceView)))

        wait(for: [router.routeExpectation], timeout: 1)
        XCTAssertEqual(router.calls.last?.0, URLComponents(string: "/conversations/1"))
        XCTAssertEqual(router.calls.last?.1, sourceView)
    }

    func testScopeChangeForwardedToInteractor() {
        XCTAssertEqual(mockInteractor.receivedScope, testee.scope)

        testee.scopeDidChange.send(.starred)

        XCTAssertEqual(mockInteractor.receivedScope, .starred)
    }

    func testContextChangeForwardedToInteractor() {
        let newCourse: InboxCourse = databaseClient.insert()
        newCourse.courseId = "newCourse"
        XCTAssertNil(mockInteractor.receivedContext)

        testee.courseDidChange.send(newCourse)

        XCTAssertEqual(mockInteractor.receivedContext, Context(.course, id: "newCourse"))
    }

    func testStateUpdateForwardedToInteractor() {
        XCTAssertNil(mockInteractor.receivedMessageUpdate)

        testee.updateState.send((messageId: "D34DB33F", state: .archived))

        XCTAssertEqual(mockInteractor.receivedMessageUpdate?.message.messageId, "D34DB33F")
        XCTAssertEqual(mockInteractor.receivedMessageUpdate?.state, .archived)
    }

    func testScrollToBottomEventForwardedToInteractor() {
        XCTAssertFalse(mockInteractor.loadNextPageCalled)

        testee.contentDidScrollToBottom.send()
        RunLoop.main.run(until: Date() + 2)

        XCTAssertTrue(mockInteractor.loadNextPageCalled)
    }
}

private class InboxMessageInteractorMock: InboxMessageInteractor {
    var state = CurrentValueSubject<StoreState, Never>(.data)
    var messages: CurrentValueSubject<[InboxMessageListItem], Never>
    var courses: CurrentValueSubject<[InboxCourse], Never>
    var hasNextPage = CurrentValueSubject<Bool, Never>(true)

    private(set) var refreshCalled = false
    private(set) var loadNextPageCalled = false
    private(set) var receivedContext: Context?
    private(set) var receivedScope: InboxMessageScope?
    private(set) var receivedMessageUpdate: (message: InboxMessageListItem, state: ConversationWorkflowState)?

    init(context: NSManagedObjectContext) {
        let message: InboxMessageListItem = context.insert()
        message.messageId = "D34DB33F"
        let course: InboxCourse = context.insert()
        course.courseId = "C0453"

        self.messages = .init([message])
        self.courses = .init([course])
    }

    func refresh() -> Future<Void, Never> {
        refreshCalled = true
        return mockFuture
    }

    func setContext(_ context: Context?) -> Future<Void, Never> {
        receivedContext = context
        return mockFuture
    }

    func setScope(_ scope: InboxMessageScope) -> Future<Void, Never> {
        receivedScope = scope
        return mockFuture
    }

    func updateState(message: InboxMessageListItem, state: ConversationWorkflowState) -> Future<Void, Never> {
        receivedMessageUpdate = (message: message, state: state)
        return mockFuture
    }

    func loadNextPage() -> Future<Void, Never> {
        loadNextPageCalled = true
        return mockFuture
    }

    private var mockFuture: Future<Void, Never> {
        Future<Void, Never> { promise in
            promise(.success(()))
        }
    }
}
