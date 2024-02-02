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
@testable import Core
import XCTest

class MessageDetailsViewModelTests: CoreTestCase {
    private var mockInteractor: MessageDetailsInteractorMock!
    var testee: MessageDetailsViewModel!

    override func setUp() {
        super.setUp()
        mockInteractor = MessageDetailsInteractorMock()
        testee = MessageDetailsViewModel(router: router, interactor: mockInteractor, myID: "1")
    }

    func testInteractorStateMappedToViewModel() {
        XCTAssertEqual(testee.state, mockInteractor.state.value)
        XCTAssertEqual(testee.subject, "Test")
        XCTAssertEqual(testee.messages.count, 1)
        XCTAssertFalse(testee.starred)
    }

    func testRefreshForwardedToInteractor() {
        let refreshCompleted = expectation(description: "refresh callback received")

        testee.refreshDidTrigger.send {
            refreshCompleted.fulfill()
        }

        waitForExpectations(timeout: 2)
        XCTAssertTrue(mockInteractor.refreshCalled)
    }

    func testStarredTap() {
        XCTAssertFalse(testee.starred)

        testee.starDidTap.send(true)

        XCTAssertEqual(mockInteractor.receivedStarred, true)
    }

    func testConversationMoreTapped() {
        let sourceView = UIViewController()

        testee.conversationMoreTapped(viewController: WeakViewController(sourceView))

        let sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertNotNil(sheet)
        XCTAssertEqual(sheet?.actions.count, 6)
    }

    func testMessageMoreTapped() {
        let sourceView = UIViewController()

        testee.messageMoreTapped(message: .init(), viewController: WeakViewController(sourceView))

        let sheet = router.presented as? BottomSheetPickerViewController
        XCTAssertNotNil(sheet)
        XCTAssertEqual(sheet?.actions.count, 4)
    }

    func testMessageDelete() {
        testee.deleteConversationMessageDidTap.send((conversationId: "conversationId", messageId: "messageId"))

        XCTAssertTrue(mockInteractor.deleteMessageCalled)
    }

    func testConversationDelete() {
        let viewController = WeakViewController(UIViewController())
        testee.deleteConversationDidTap.send((conversationId: "conversationId", viewController: viewController))

        XCTAssertTrue(mockInteractor.deleteConversationCalled)
    }

    func testForward() {
        let viewController = WeakViewController(UIViewController())
        testee.forwardTapped(viewController: viewController)

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented

        XCTAssertNotNil(dialog)
    }

    func testReply() {
        let viewController = WeakViewController(UIViewController())
        testee.replyTapped(message: mockInteractor.messages.value.first!, viewController: viewController)

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented

        XCTAssertNotNil(dialog)
    }

    func testReplyAll() {
        let viewController = WeakViewController(UIViewController())
        let message: ConversationMessage = .make()
        testee.replyAllTapped(message: message, viewController: viewController)

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented

        XCTAssertNotNil(dialog)
    }
}

private class MessageDetailsInteractorMock: MessageDetailsInteractor {

    var conversation: CurrentValueSubject<[Core.Conversation], Never>

    var state = CurrentValueSubject<StoreState, Never>(.data)
    var subject = CurrentValueSubject<String, Never>("Test")
    var messages: CurrentValueSubject<[ConversationMessage], Never>
    var starred = CurrentValueSubject<Bool, Never>(false)
    var userMap: [String: ConversationParticipant] = [:]

    private(set) var refreshCalled = false
    private(set) var receivedStarred: Bool?
    private(set) var updateStateCalled = false
    private(set) var deleteConversationCalled = false
    private(set) var deleteMessageCalled = false

    init() {
        self.messages = .init([ .make() ])
        self.conversation = CurrentValueSubject<[Core.Conversation], Never>([
            Conversation.make(from: .make(message_count: 1, messages: [ .make() ]))])

    }

    func refresh() -> Future<Void, Never> {
        refreshCalled = true
        return mockFuture
    }

    func updateStarred(starred: Bool) -> Future<Void, Never> {
        receivedStarred = starred
        return mockFuture
    }

    func updateState(messageId: String, state: Core.ConversationWorkflowState) -> Future<Void, Never> {
        updateStateCalled = true
        return mockFuture
    }

    func deleteConversation(conversationId: String) -> Future<Void, Never> {
        deleteConversationCalled = true
        return mockFuture
    }

    func deleteConversationMessage(conversationId: String, messageId: String) -> Future<Void, Never> {
        deleteMessageCalled = true
        return mockFuture
    }

    private var mockFuture: Future<Void, Never> {
        Future<Void, Never> { promise in
            promise(.success(()))
        }
    }
}
