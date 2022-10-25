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
    public let courses = Just([GetCurrentUserCoursesRequest.CourseEntry(id: "1", name: "Test Course")])
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
        .Sink<String?, Never> { [weak self] filter in
            self?.filterValue = filter
        }
        .eraseToAnySubscriber()
    public private(set) lazy var setScope = Subscribers
        .Sink<InboxMessageScope, Never> { [weak self] scope in
            self?.scopeValue = scope
        }
        .eraseToAnySubscriber()
    public private(set) lazy var markAsRead = Subscribers
        .Sink<InboxMessageModel, Never> { _ in }
        .eraseToAnySubscriber()
    public private(set) lazy var markAsUnread = Subscribers
        .Sink<InboxMessageModel, Never> { _ in }
        .eraseToAnySubscriber()
    public private(set) lazy var markAsArchived = Subscribers
        .Sink<InboxMessageModel, Never> { _ in }
        .eraseToAnySubscriber()

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
