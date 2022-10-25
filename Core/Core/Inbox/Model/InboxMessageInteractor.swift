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

public protocol InboxMessageInteractor {
    // MARK: - Outputs
    var state: AnyPublisher<StoreState, Never> { get }
    var messages: AnyPublisher<[InboxMessageModel], Never> { get }
    var courses: AnyPublisher<[APICourse], Never> { get }

    // MARK: - Inputs
    var triggerRefresh: AnySubscriber<() -> Void, Never> { get }
    var setFilter: AnySubscriber<Context?, Never> { get }
    var setScope: AnySubscriber<InboxMessageScope, Never> { get }
    var markAsRead: AnySubscriber<InboxMessageModel, Never> { get }
    var markAsUnread: AnySubscriber<InboxMessageModel, Never> { get }
    var markAsArchived: AnySubscriber<InboxMessageModel, Never> { get }
}
