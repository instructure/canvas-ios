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
    public let courses = CurrentValueSubject<[APICourse], Never>([])

    // MARK: - Private State
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment

    private var messagesRequest: APITask?
    private let useCase: GetInboxMessageList
    private let messageListStore: Store<GetInboxMessageList>

    public init(env: AppEnvironment) {
        let currentUserId = env.currentSession?.userID ?? ""
        self.env = env
        self.useCase = GetInboxMessageList(currentUserId: currentUserId)
        self.messageListStore = env.subscribe(useCase)

        messageListStore
            .allObjects
            .subscribe(messages)
            .store(in: &subscriptions)

        messageListStore
            .statePublisher
            .subscribe(state)
            .store(in: &subscriptions)
    }

    // MARK: - Inputs

    public func refresh() -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            self?.fetchCoursesFromAPI()
            self?.messageListStore.refresh(force: true) { _ in
                promise(.success(()))
            }
        }
    }

    public func setFilter(_ context: Context?) -> Future<Void, Never> {
        Future<Void, Never> { [useCase, messageListStore, messages, state] promise in
            messages.send([])
            state.send(.loading)
            useCase.contextCode = context?.canvasContextID
            messageListStore.setScope(useCase.scope)
            messageListStore.refresh()
            promise(.success(()))
        }
    }

    public func setScope(_ scope: InboxMessageScope) -> Future<Void, Never> {
        Future<Void, Never> { [useCase, messageListStore, messages, state] promise in
            messages.send([])
            state.send(.loading)
            useCase.messageScope = scope
            messageListStore.setScope(useCase.scope)
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

    private func fetchCoursesFromAPI() {
        let request = GetCurrentUserCoursesRequest(enrollmentState: .active, state: [.current_and_concluded], perPage: 100)
        env.api
            .makeRequest(request)
            .replaceNil(with: [])
            .replaceError(with: [])
            .map { $0.sorted { ($0.name ?? "") < ($1.name ?? "") }}
            .subscribe(courses)
            .store(in: &subscriptions)
    }

    private func uploadWorkflowStateToAPI(messageId: String, state: ConversationWorkflowState) {
        let request = PutConversationRequest(id: messageId, workflowState: state)
        env.api.makeRequest(request, callback: { _, _, _ in })
    }

    private func updateWorkflowStateLocally(message: InboxMessageListItem, state: ConversationWorkflowState) {
//        guard let index = messages.value.firstIndex(of: message) else { return }
//        var newMessages = messages.value
//
//        if message.state == .archived || state == .archived {
//            newMessages.remove(at: index)
//        } else {
//            newMessages[index] = message.makeCopy(withState: state)
//        }
//
//        var messageCount = TabBarBadgeCounts.unreadMessageCount
//
//        if state == .unread {
//            messageCount += 1
//        } else if messageCount > 0 {
//            messageCount -= 1
//        }
//
//        TabBarBadgeCounts.unreadMessageCount = messageCount
//
//        messages.send(newMessages)
//
//        if newMessages.isEmpty {
//            self.state.send(.empty)
//        }
    }
}
