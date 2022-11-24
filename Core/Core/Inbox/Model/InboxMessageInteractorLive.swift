//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class InboxMessageInteractorLive: InboxMessageInteractor {
    // MARK: - Outputs
    public let state = CurrentValueSubject<StoreState, Never>(.loading)
    public let messages = CurrentValueSubject<[InboxMessageListItem], Never>([])
    public let courses = CurrentValueSubject<[InboxCourse], Never>([])

    // MARK: - Private State
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment

    private var messagesRequest: APITask?
    private let messageListUseCase: GetInboxMessageList
    private let messageListStore: Store<GetInboxMessageList>
    private let courseListStore: Store<GetInboxCourseList>

    public init(env: AppEnvironment) {
        let currentUserId = env.currentSession?.userID ?? ""
        self.env = env
        self.messageListUseCase = GetInboxMessageList(currentUserId: currentUserId)
        self.messageListStore = env.subscribe(messageListUseCase)
        self.courseListStore = env.subscribe(GetInboxCourseList())

        messageListStore
            .allObjects
            .subscribe(messages)
            .store(in: &subscriptions)

        messageListStore
            .statePublisher
            .subscribe(state)
            .store(in: &subscriptions)

        courseListStore
            .allObjects
            .subscribe(courses)
            .store(in: &subscriptions)

        messageListStore.refresh()
        courseListStore.exhaust()
    }

    // MARK: - Inputs

    public func refresh() -> Future<Void, Never> {
        Future<Void, Never> { [self] promise in
            self.courseListStore.exhaust(force: true)
            self.messageListStore.refreshWithFuture(force: true)
                .sink { _ in promise(.success(())) }
                .store(in: &self.subscriptions)
        }
    }

    public func setContext(_ context: Context?) -> Future<Void, Never> {
        Future<Void, Never> { [messageListUseCase, messageListStore, messages, state] promise in
            messageListUseCase.contextCode = context?.canvasContextID
            messageListStore.setScope(messageListUseCase.scope)

            if messageListStore.isCachedDataExpired {
                messages.send([])
                state.send(.loading)
            }

            messageListStore.refresh()
            promise(.success(()))
        }
    }

    public func setScope(_ scope: InboxMessageScope) -> Future<Void, Never> {
        Future<Void, Never> { [messageListUseCase, messageListStore, messages, state] promise in
            messageListUseCase.messageScope = scope
            messageListStore.setScope(messageListUseCase.scope)

            if messageListStore.isCachedDataExpired {
                messages.send([])
                state.send(.loading)
            }

            messageListStore.refresh()
            promise(.success(()))
        }
    }

    public func updateState(message: InboxMessageListItem,
                            state: ConversationWorkflowState)
    -> Future<Void, Never> {
        Future<Void, Never> { promise in
            self.updateWorkflowStateLocally(message: message, state: state)
            self.uploadWorkflowStateToAPI(messageId: message.messageId, state: state)
            promise(.success(()))
        }
    }

    // MARK: - Private Helpers

    private func uploadWorkflowStateToAPI(messageId: String, state: ConversationWorkflowState) {
        let request = PutConversationRequest(id: messageId, workflowState: state)
        env.api.makeRequest(request, callback: { _, _, _ in })
    }

    private func updateWorkflowStateLocally(message: InboxMessageListItem, state: ConversationWorkflowState) {
        var messageCount = TabBarBadgeCounts.unreadMessageCount

        if state == .unread {
            messageCount += 1
        } else if message.isUnread, messageCount > 0 {
            messageCount -= 1
        }

        TabBarBadgeCounts.unreadMessageCount = messageCount

        message.state = state
        try? message.managedObjectContext?.save()
    }
}
