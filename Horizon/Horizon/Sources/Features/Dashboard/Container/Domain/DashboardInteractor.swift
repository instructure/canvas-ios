//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import Foundation

protocol DashboardInteractor {
    func getUnreadInboxMessageCount() -> AnyPublisher<Int, Never>
}

final class DashboardInteractorLive: DashboardInteractor {
    // MARK: - Properties

    private let userId: String
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(userId: String = AppEnvironment.shared.currentSession?.userID ?? "") {
        self.userId = userId
    }

    func getUnreadInboxMessageCount() -> AnyPublisher<Int, Never> {
        ReactiveStore(
            useCase: GetInboxMessageList(currentUserId: userId)
        )
        .getEntities(ignoreCache: true)
        .map { messages in
            messages.reduce(0) { count, message in
                message.state == .unread ? count + 1 : count
            }
        }
        .replaceError(with: 0)
        .eraseToAnyPublisher()
    }
}
