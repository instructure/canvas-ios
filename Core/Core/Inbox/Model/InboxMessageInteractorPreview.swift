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

    // MARK: - Inputs
    public private(set) lazy var triggerRefresh = AnySubscriber(Subscribers.Sink<() -> Void, Never>(receiveCompletion: { _ in }) { completion in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion()
        }
    })
    public private(set) lazy var setFilter = AnySubscriber(Subscribers.Sink<String?, Never>(receiveCompletion: { _ in }) { [weak self] filter in
        self?.filterValue = filter
    })
    public private(set) lazy var setScope = AnySubscriber(Subscribers.Sink<InboxMessageScope, Never>(receiveCompletion: { _ in }) { [weak self] scope in
        self?.scopeValue = scope
    })

    // MARK: - Private State
    private let stateSubject = CurrentValueSubject<StoreState, Never>(.loading)
    private var filterValue: String? {
        didSet { update() }
    }
    private var scopeValue: InboxMessageScope = .all {
        didSet { update() }
    }

    public init(messages: [InboxMessageModel]) {
        self.messages = CurrentValueSubject<[InboxMessageModel], Never>(messages).eraseToAnyPublisher()
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
