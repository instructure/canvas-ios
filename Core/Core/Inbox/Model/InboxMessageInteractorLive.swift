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
    public private(set) lazy var state = stateSubject.eraseToAnyPublisher()
    public private(set) lazy var messages = messagesSubject.eraseToAnyPublisher()
    public private(set) lazy var courses = coursesSubject.eraseToAnyPublisher()

    // MARK: - Private State
    private let stateSubject = CurrentValueSubject<StoreState, Never>(.loading)
    private let messagesSubject = CurrentValueSubject<[InboxMessageModel], Never>([])
    private let coursesSubject = CurrentValueSubject<[APICourse], Never>([])
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment
    private var filterValue: Context? {
        didSet { update() }
    }
    private var scopeValue: InboxMessageScope = .all {
        didSet { update() }
    }
    private var messagesRequest: APITask?

    public init(env: AppEnvironment) {
        self.env = env
        fetchCoursesFromAPI()
    }

    // MARK: - Inputs

    public func refresh() -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            self?.fetchCoursesFromAPI()
            self?.fetchMessagesFromAPI(promise: promise)
        }
    }

    public func setFilter(_ context: Context?) -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            self?.filterValue = context
            promise(.success(()))
        }
    }

    public func setScope(_ scope: InboxMessageScope) -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            self?.scopeValue = scope
            promise(.success(()))
        }
    }

    public func updateState(message: InboxMessageModel,
                            state: ConversationWorkflowState)
    -> Future<Void, Never> {
        Future<Void, Never> { promise in
            self.updateWorkflowStateLocally(message: message, state: state)
            self.uploadWorkflowStateToAPI(messageId: message.id, state: state)
            promise(.success(()))
        }
    }

    // MARK: - Private Helpers

    private func update() {
        stateSubject.send(.loading)
        messagesSubject.send([])
        fetchMessagesFromAPI()
    }

    private func fetchCoursesFromAPI() {
        let request = GetCurrentUserCoursesRequest(enrollmentState: .active, state: [.current_and_concluded], perPage: 100)
        env.api
            .makeRequest(request)
            .replaceNil(with: [])
            .replaceError(with: [])
            .map { $0.sorted { ($0.name ?? "") < ($1.name ?? "") }}
            .subscribe(coursesSubject)
            .store(in: &subscriptions)
    }

    private func fetchMessagesFromAPI(promise: ((Result<Void, Never>) -> Void)? = nil) {
        let request = GetConversationsRequest(include: [.participant_avatars],
                                              perPage: 100,
                                              scope: scopeValue.apiScope,
                                              filter: filterValue?.canvasContextID)
        messagesRequest?.cancel()
        messagesRequest = env.api.makeRequest(request) { [weak self] messages, _, error in
            guard let self = self else { return }
            self.messagesRequest = nil
            let currentUserID = self.env.currentSession?.userID ?? ""
            let messages = (messages ?? []).map {
                InboxMessageModel(conversation: $0, currentUserID: currentUserID)
            }
            performUIUpdate {
                self.handleMessagesResponse(messages: messages, error: error)
                promise?(.success(()))
            }

        }
    }

    private func handleMessagesResponse(messages: [InboxMessageModel], error: Error?) {
        if error != nil {
            stateSubject.send(.error)
        } else if messages.isEmpty {
            stateSubject.send(.empty)
        } else {
            messagesSubject.send(messages)
            stateSubject.send(.data)
        }
    }

    private func uploadWorkflowStateToAPI(messageId: String, state: ConversationWorkflowState) {
        let request = PutConversationRequest(id: messageId, workflowState: state)
        env.api.makeRequest(request, callback: { _, _, _ in })
    }

    private func updateWorkflowStateLocally(message: InboxMessageModel, state: ConversationWorkflowState) {
        guard let index = messagesSubject.value.firstIndex(of: message) else { return }
        var newMessages = messagesSubject.value

        if message.state == .archived || state == .archived {
            newMessages.remove(at: index)
        } else {
            newMessages[index] = message.makeCopy(withState: state)
        }

        var messageCount = TabBarBadgeCounts.unreadMessageCount

        if state == .unread {
            messageCount += 1
        } else if messageCount > 0 {
            messageCount -= 1
        }

        TabBarBadgeCounts.unreadMessageCount = messageCount

        messagesSubject.send(newMessages)

        if newMessages.isEmpty {
            stateSubject.send(.empty)
        }
    }
}
