//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Horizon
@testable import Core
import Combine
import Foundation

public final class MessageDetailsInteractorMock: MessageDetailsInteractor {

    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.data)
    public var subject = CurrentValueSubject<String, Never>("")
    public var messages = CurrentValueSubject<[ConversationMessage], Never>([])
    public var conversation = CurrentValueSubject<[Conversation], Never>([])
    public var starred = CurrentValueSubject<Bool, Never>(false)
    public var userMap: [String: ConversationParticipant] = [:]

    // MARK: - Tracking
    public var refreshCallCount = 0
    public var updateStarredCallCount = 0
    public var updateStateCallCount = 0
    public var deleteConversationCallCount = 0
    public var deleteConversationMessageCallCount = 0
    public var lastUpdateStarred: Bool?
    public var lastUpdateStateMessageId: String?
    public var lastUpdateStateState: ConversationWorkflowState?
    public var lastDeleteConversationId: String?
    public var lastDeleteConversationMessageIds: (conversationId: String, messageId: String)?

    // MARK: - Response Configuration
    public var updateStarredResult: Result<URLResponse?, Error> = .success(nil)
    public var updateStateResult: Result<URLResponse?, Error> = .success(nil)
    public var deleteConversationResult: Result<URLResponse?, Error> = .success(nil)
    public var deleteConversationMessageResult: Result<URLResponse?, Error> = .success(nil)

    // MARK: - Inputs
    public func refresh() -> Future<Void, Never> {
        refreshCallCount += 1
        return Future { promise in
            promise(.success(()))
        }
    }

    public func updateStarred(starred: Bool) -> Future<URLResponse?, Error> {
        updateStarredCallCount += 1
        lastUpdateStarred = starred
        return Future { promise in
            promise(self.updateStarredResult)
        }
    }

    public func updateState(messageId: String, state: ConversationWorkflowState) -> Future<URLResponse?, Error> {
        updateStateCallCount += 1
        lastUpdateStateMessageId = messageId
        lastUpdateStateState = state
        return Future { promise in
            promise(self.updateStateResult)
        }
    }

    public func deleteConversation(conversationId: String) -> Future<URLResponse?, Error> {
        deleteConversationCallCount += 1
        lastDeleteConversationId = conversationId
        return Future { promise in
            promise(self.deleteConversationResult)
        }
    }

    public func deleteConversationMessage(conversationId: String, messageId: String) -> Future<URLResponse?, Error> {
        deleteConversationMessageCallCount += 1
        lastDeleteConversationMessageIds = (conversationId, messageId)
        return Future { promise in
            promise(self.deleteConversationMessageResult)
        }
    }

    // MARK: - Helper Methods
    public func simulateMessages(_ messageList: [ConversationMessage]) {
        messages.send(messageList)
    }

    public func simulateConversation(_ conversationList: [Conversation]) {
        conversation.send(conversationList)
    }

    public func simulateSubject(_ subjectText: String) {
        subject.send(subjectText)
    }
}
