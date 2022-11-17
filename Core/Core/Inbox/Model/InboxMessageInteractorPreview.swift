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
    public private(set) lazy var state = stateSubject.eraseToAnyPublisher()
    public let messages: AnyPublisher<[InboxMessageModel], Never>
    public let courses = Just([APICourse.make(id: "1", name: "Test Course")])
        .eraseToAnyPublisher()

    // MARK: - Inputs
    public private(set) lazy var triggerRefresh = Subscribers
        .Sink<() -> Void, Never> { completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion()
            }
        }
        .eraseToAnySubscriber()
    public private(set) lazy var setFilter = Subscribers
        .Sink<Context?, Never> { [weak self] _ in
            self?.update()
        }
        .eraseToAnySubscriber()
    public private(set) lazy var setScope = Subscribers
        .Sink<InboxMessageScope, Never> { [weak self] scope in
            self?.scopeValue = scope
        }
        .eraseToAnySubscriber()

    // MARK: - Private State
    private let stateSubject = CurrentValueSubject<StoreState, Never>(.loading)
    private var scopeValue: InboxMessageScope = .all {
        didSet { update() }
    }

    public init(messages: [InboxMessageModel]) {
        self.messages = CurrentValueSubject<[InboxMessageModel], Never>(messages).eraseToAnyPublisher()
    }

    public func updateState(message: InboxMessageModel,
                            state: ConversationWorkflowState)
    -> Future<Void, Never> {
        Future<Void, Never> { $0(.success(())) }
    }

    private func update() {
        stateSubject.send(.loading)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            switch scopeValue {
            case .all, .sent, .archived:
                stateSubject.send(.data)
            case .unread:
                stateSubject.send(.empty)
            case .starred:
                stateSubject.send(.error)
            }
        }
    }
}

#endif
