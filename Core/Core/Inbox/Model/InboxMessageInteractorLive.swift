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

    // MARK: - Inputs
    public private(set) lazy var triggerRefresh = Subscribers
        .Sink<() -> Void, Never> { [weak self] completion in
            self?.messagesStore?.refresh(force: true) { _ in
                completion()
            }
        }
        .eraseToAnySubscriber()
    /** In the format of `course\_123`, `group\_123` or `user\_123`. */
    public private(set) lazy var setFilter = Subscribers
        .Sink<String?, Never> { [weak self] filter in
            self?.filterValue = filter
        }
        .eraseToAnySubscriber()
    public private(set) lazy var setScope = Subscribers
        .Sink<InboxMessageScope, Never> { [weak self] scope in
            self?.scopeValue = scope
        }
        .eraseToAnySubscriber()
    public private(set) lazy var toggleReadStatus = Subscribers
        .Sink<String, Never> { [weak self] messageId in
            self?.sendToggledReadStatusToAPI(messageId: messageId)
        }
        .eraseToAnySubscriber()

    // MARK: - Private State
    private let stateSubject = CurrentValueSubject<StoreState, Never>(.loading)
    private let messagesSubject = CurrentValueSubject<[InboxMessageModel], Never>([])
    private var messagesStore: Store<GetConversations>?
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment
    private var filterValue: String? {
        didSet { update() }
    }
    private var scopeValue: InboxMessageScope = .all {
        didSet { update() }
    }

    public init(env: AppEnvironment) {
        self.env = env
    }

    private func update() {
        stateSubject.send(.loading)
        messagesSubject.send([])
        messagesStore = env.subscribe(GetConversations(scope: scopeValue.apiScope, filter: filterValue)) { [weak self] in
            self?.messagesStoreUpdated()
        }
        messagesStore?.refresh(force: true)
    }

    private func messagesStoreUpdated() {
        guard let messagesStore = messagesStore,
              messagesStore.state != .loading
        else {
            return
        }

        switch messagesStore.state {
        case .empty:
            stateSubject.send(.empty)
        case .data:
            let messages = messagesStore.all.map { InboxMessageModel(conversation: $0, currentUserID: env.currentSession?.userID ?? "") }
            messagesSubject.send(messages)
            stateSubject.send(.data)
        case .error, .loading:
            stateSubject.send(.error)
        }
    }

    private func sendToggledReadStatusToAPI(messageId: String) {
        guard let message = messagesStore?.all.first(where: { $0.id == messageId}) else {
            return
        }
        let newReadStatus: ConversationWorkflowState = message.workflowState == .unread ? .read : .unread
        message.workflowState = newReadStatus
        let useCase = UpdateConversation(id: messageId, state: newReadStatus)
        env.subscribe(useCase).refresh()
    }
}
