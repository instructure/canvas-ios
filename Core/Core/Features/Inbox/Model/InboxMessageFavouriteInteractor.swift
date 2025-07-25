//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import Combine

public protocol InboxMessageFavouriteInteractor {
    func updateStarred(to newValue: Bool, messageId: String) -> Future<URLResponse?, Error>
}

public final class InboxMessageFavouriteInteractorLive: InboxMessageFavouriteInteractor {

    let env: AppEnvironment
    public init(env: AppEnvironment) {
        self.env = env
    }

    public func updateStarred(to newValue: Bool, messageId: String) -> Future<URLResponse?, Error> {
        StarConversation(id: messageId, starred: newValue).fetchWithFuture(environment: env)
    }
}
