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

public class MessageDetailsInteractorLive: MessageDetailsInteractor {
    // MARK: - Outputs
    public var state = CurrentValueSubject<StoreState, Never>(.loading)
    public var subject = CurrentValueSubject<String, Never>("")
    public var messages = CurrentValueSubject<[ConversationMessage], Never>([])
    public var starred = CurrentValueSubject<Bool, Never>(false)
    public var userMap: [String: ConversationParticipant] = [:]

    // MARK: - Private
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment
    private let conversationID: String
    private let conversationStore: Store<GetConversation>

    public init(env: AppEnvironment, conversationID: String) {
        self.env = env
        self.conversationID = conversationID
        self.conversationStore = env.subscribe(GetConversation(id: conversationID))

        conversationStore
            .statePublisher
            .subscribe(state)
            .store(in: &subscriptions)

        conversationStore
            .allObjects
            .map {
                $0.first?.subject ?? NSLocalizedString("No Subject", comment: "")
            }
            .subscribe(subject)
            .store(in: &subscriptions)

        conversationStore
            .allObjects
            .map {
                $0.first?.participants.forEach { self.userMap[ $0.id ] = $0 }
                return $0.first?.messages ?? []
            }
            .subscribe(messages)
            .store(in: &subscriptions)

        conversationStore
            .allObjects
            .compactMap { $0.first?.starred }
            .subscribe(starred)
            .store(in: &subscriptions)

        conversationStore.refresh()
    }

    // MARK: - Inputs
    public func refresh() -> Future<Void, Never> {
        conversationStore.refreshWithFuture(force: true)
    }

    public func updateStarred(starred: Bool) -> Future<Void, Never> {
        Future { [weak self] promise in
            guard let self else {
                return promise(.success(()))
            }
            let request = StarConversationRequest(id: self.conversationID, starred: starred)
            self.env.api.makeRequest(request, callback: { _, _, _ in
                self.conversationStore.refresh(force: true) { _ in
                    return promise(.success(()))
                }
            })
        }
    }
}
