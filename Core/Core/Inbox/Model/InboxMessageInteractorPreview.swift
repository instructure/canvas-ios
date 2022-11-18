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
    public let messages: CurrentValueSubject<[InboxMessageModel], Never>
    public let courses = CurrentValueSubject<[APICourse], Never>([.make(id: "1", name: "Test Course")])

    // MARK: - Private State
    private var scopeValue: InboxMessageScope = .all {
        didSet { update() }
    }

    public init(messages: [InboxMessageModel]) {
        self.messages = CurrentValueSubject<[InboxMessageModel], Never>(messages)
    }

    public func refresh() -> Future<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success(()))
            }
        }
    }

    public func setFilter(_ context: Context?) -> Future<Void, Never> {
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

    public func updateState(message: InboxMessageModel,
                            state: ConversationWorkflowState)
    -> Future<Void, Never> {
        Future<Void, Never> { $0(.success(())) }
    }

    private func update() {
        state.send(.loading)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            switch scopeValue {
            case .all, .sent, .archived:
                state.send(.data)
            case .unread:
                state.send(.empty)
            case .starred:
                state.send(.error)
            }
        }
    }
}

#endif
