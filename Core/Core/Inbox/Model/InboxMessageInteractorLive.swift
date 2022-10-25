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

    // MARK: - Inputs
    public private(set) lazy var triggerRefresh = Subscribers
        .Sink<() -> Void, Never> { [weak self] completion in
            self?.fetchCoursesFromAPI()
            self?.fetchMessagesFromAPI(completion)
        }
        .eraseToAnySubscriber()
    public private(set) lazy var setFilter = Subscribers
        .Sink<Context?, Never> { [weak self] filter in
            self?.filterValue = filter
        }
        .eraseToAnySubscriber()
    public private(set) lazy var setScope = Subscribers
        .Sink<InboxMessageScope, Never> { [weak self] scope in
            self?.scopeValue = scope
        }
        .eraseToAnySubscriber()
    public private(set) lazy var markAsRead = Subscribers
        .Sink<InboxMessageModel, Never> { [weak self] message in
            self?.updateWorkflowStateLocally(message: message, state: .read)
            self?.uploadWorkflowStateToAPI(messageId: message.id, state: .read)
        }
        .eraseToAnySubscriber()
    public private(set) lazy var markAsUnread = Subscribers
        .Sink<InboxMessageModel, Never> { [weak self] message in
            self?.updateWorkflowStateLocally(message: message, state: .unread)
            self?.uploadWorkflowStateToAPI(messageId: message.id, state: .unread)
        }
        .eraseToAnySubscriber()
    public private(set) lazy var markAsArchived = Subscribers
        .Sink<InboxMessageModel, Never> { [weak self] message in
            self?.updateWorkflowStateLocally(message: message, state: .archived)
            self?.uploadWorkflowStateToAPI(messageId: message.id, state: .archived)
        }
        .eraseToAnySubscriber()

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

    private func fetchMessagesFromAPI(_ completion: (() -> Void)? = nil) {
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
                completion?()
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

        messagesSubject.send(newMessages)

        if newMessages.isEmpty {
            stateSubject.send(.empty)
        }
    }
}
