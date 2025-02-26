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

#if DEBUG

import Combine

class InboxMessageInteractorPreview: InboxMessageInteractor {
    // MARK: - Outputs
    public let state = CurrentValueSubject<StoreState, Never>(.loading)
    public let messages: CurrentValueSubject<[InboxMessageListItem], Never>
    public let courses: CurrentValueSubject<[InboxCourse], Never>
    public let hasNextPage = CurrentValueSubject<Bool, Never>(true)

    // MARK: - Private State
    private var scopeValue: InboxMessageScope = .inbox {
        didSet { update() }
    }

    public init(environment: AppEnvironment, messages: [InboxMessageListItem]) {
        self.messages = CurrentValueSubject<[InboxMessageListItem], Never>(messages)
        self.courses = CurrentValueSubject<[InboxCourse], Never>([
            .save(.make(id: "1", name: "Test Course"), in: environment.database.viewContext)
        ])
    }

    public func refresh() -> Future<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success(()))
            }
        }
    }

    public func setContext(_ context: Context?) -> Future<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            self?.update()
            promise(.success(()))
        }
    }

    public func setScope(_ scope: InboxMessageScope) -> Future<Void, Never> {
        Future<Void, Never> { promise in
            self.scopeValue = scope
            promise(.success(()))
        }
    }

    public func updateState(message: InboxMessageListItem,
                            state: ConversationWorkflowState)
    -> Future<Void, Never> {
        Future<Void, Never> { $0(.success(())) }
    }

    public func loadNextPage() -> Future<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.hasNextPage.send(false)
                promise(.success(()))
            }
        }
    }

    private func update() {
        state.send(.loading)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            switch scopeValue {
            case .inbox, .sent, .archived:
                if messages.value.isEmpty {
                    state.send(.empty)
                } else {
                    state.send(.data)
                }
            case .unread:
                state.send(.empty)
            case .starred:
                state.send(.error)
            }
        }
    }
}

#endif
