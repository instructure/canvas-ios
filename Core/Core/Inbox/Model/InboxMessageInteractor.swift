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

    // MARK: - Inputs
    var triggerRefresh: AnySubscriber<() -> Void, Never> { get }
    /** In the format of `course\_123`, `group\_123` or `user\_123`. */
    var setFilter: AnySubscriber<String?, Never> { get }
    var setScope: AnySubscriber<InboxMessageScope, Never> { get }
    /** Send the message(conversation)'s id. */
    var toggleReadStatus: AnySubscriber<String, Never> { get }
}
