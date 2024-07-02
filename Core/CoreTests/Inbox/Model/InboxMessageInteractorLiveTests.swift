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

class InboxMessageInteractorLiveTests: CoreTestCase {
    private var testee: InboxMessageInteractorLive!
    private var tabBarUpdaterMock: TabBarMessageCountUpdaterMock!
    private var messageListStateUpdaterMock: MessageListStateUpdaterMock!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        tabBarUpdaterMock = TabBarMessageCountUpdaterMock()
        messageListStateUpdaterMock = MessageListStateUpdaterMock()
        testee = InboxMessageInteractorLive(env: environment,
                                            tabBarCountUpdater: tabBarUpdaterMock,
                                            messageListStateUpdater: messageListStateUpdaterMock)
    }

    override func tearDown() {
        super.tearDown()
        subscriptions.removeAll()
    }

    func testReadsMessagesFromUseCase() {
        mockMessageList(entities: [
                            .make(id: "3",
                                  workflow_state: .read,
                                  starred: true,
                                  properties: [.attachments])
                        ],
                        scope: .starred,
                        context: Context(.course, id: "3"))

        testee
            .setContext(Context(.course, id: "3"))
            .sink()
            .store(in: &subscriptions)
        testee
            .setScope(.starred)
            .sink()
            .store(in: &subscriptions)

        waitForState()
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.messages.value.count, 1)
        XCTAssertEqual(testee.messages.value.first?.id, "3")
    }

    func testRefreshesMessagesList() {
        // There was no mock at the initialization of the interactor
        // so it stays in the loading state
        XCTAssertEqual(testee.state.value, .loading)
        XCTAssertEqual(testee.messages.value.count, 0)
        mockMessageList(entities: [.make(id: "1")],
                        scope: .inbox,
                        context: nil)

        testee
            .refresh()
            .sink()
            .store(in: &subscriptions)

        waitForState()
        XCTAssertEqual(testee.state.value, .data)
        XCTAssertEqual(testee.messages.value.count, 1)
        XCTAssertEqual(testee.messages.value.first?.id, "1")
    }

    func testUpdatesMessageState() {
        // MARK: - GIVEN
        mockMessageList(entities: [.make(id: "1")],
                        scope: .unread,
                        context: nil)
        testee
            .setScope(.unread)
            .sink()
            .store(in: &subscriptions)
        waitForState()
        let messages: [InboxMessageListItem] = databaseClient.fetch(scope: .all)
        XCTAssertEqual(messages.count, 1)

        let stateUploadExpectation = expectation(description: "state uploaded to API")
        api.mock(withData: PutConversationRequest(id: "1", workflowState: .read)) { _ in
            stateUploadExpectation.fulfill()
            return (nil, nil, nil)
        }

        // MARK: - WHEN
        testee
            .updateState(message: messages.first!, state: .read)
            .sink()
            .store(in: &subscriptions)

        // MARK: - THEN
        waitForExpectations(timeout: 1)
        XCTAssertEqual(tabBarUpdaterMock.receivedNewState, .read)
        XCTAssertEqual(tabBarUpdaterMock.receivedOldState, .unread)
        XCTAssertEqual(messageListStateUpdaterMock.receivedMessage, messages.first!)
        XCTAssertEqual(messageListStateUpdaterMock.receivedState, .read)
    }

    func testUpdatesNextPageFlag() {
        // MARK: - GIVEN
        mockMessageListWithNextPage()

        // MARK: - WHEN
        testee
            .refresh()
            .sink()
            .store(in: &subscriptions)

        // MARK: - THEN
        waitForState()
        XCTAssertTrue(testee.hasNextPage.value)
    }

    func testRequestsNextPage() {
        // MARK: - GIVEN
        mockMessageListWithNextPage()
        testee
            .refresh()
            .sink()
            .store(in: &subscriptions)
        waitForState()
        api.mock(url: URL(string: "https://next.url")!, error: NSError.instructureError("2nd page error"))

        // MARK: - WHEN
        testee
            .loadNextPage()
            .sink()
            .store(in: &subscriptions)

        // MARK: - THEN
        waitForState(.error)
    }

    private func waitForState(_ expectedState: StoreState = .data) {
        let stateReached = expectation(description: "state reached")
        testee
            .state
            .sink { state in
                if state == expectedState {
                    stateReached.fulfill()
                }
            }
            .store(in: &subscriptions)
        wait(for: [stateReached], timeout: 3)
    }

    private func mockMessageListWithNextPage() {
        let request = GetConversationsRequest(include: [.participant_avatars],
                                              perPage: 20,
                                              scope: InboxMessageScope.inbox.apiScope,
                                              filter: nil)
        api.mock(request) { _ in
            let responseHeaders: [String: String] = [
                "Link": "<https://next.url>; rel=\"next\""
            ]
            let urlResponse = HTTPURLResponse(url: URL(string: "/")!,
                                              statusCode: 200,
                                              httpVersion: nil,
                                              headerFields: responseHeaders)
            return ([.make(id: "1")], urlResponse, nil)
        }
    }

    private func mockMessageList(entities: [APIConversation],
                                 scope: InboxMessageScope,
                                 context: Context?) {
        let messageListUseCase = GetInboxMessageList(currentUserId: "1")
        messageListUseCase.messageScope = scope
        messageListUseCase.context = context

        api.mock(messageListUseCase, value: entities)
    }
}

private class TabBarMessageCountUpdaterMock: TabBarMessageCountUpdater {
    private(set) var receivedOldState: ConversationWorkflowState?
    private(set) var receivedNewState: ConversationWorkflowState?

    override func updateBadgeCount(oldState: ConversationWorkflowState,
                                   newState: ConversationWorkflowState) {
        receivedOldState = oldState
        receivedNewState = newState
    }
}

private class MessageListStateUpdaterMock: MessageListStateUpdater {
    private(set) var receivedMessage: InboxMessageListItem?
    private(set) var receivedState: ConversationWorkflowState?

    override func update(message: InboxMessageListItem,
                         newState: ConversationWorkflowState) {
        receivedMessage = message
        receivedState = newState
    }
}
