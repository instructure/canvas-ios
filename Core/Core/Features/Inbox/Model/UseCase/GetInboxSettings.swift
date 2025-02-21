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

import Foundation

public class GetInboxSettings: APIUseCase {
    public typealias Model = InboxSettings
    public typealias Response = Request.Response

    let userId: String

    public init(userId: String) {
        self.userId = userId
    }

    public var cacheKey: String? {
        return "get-inbox-settings"
    }

    public var scope: Scope {
        return .where(#keyPath(InboxSettings.userId), equals: userId, orderBy: #keyPath(InboxSettings.userId))
    }

    public var request = GetInboxSettingsRequest()
}
