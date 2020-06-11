//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public struct GetUserSettings: APIUseCase {
    public typealias Model = UserSettings

    public let userID: String

    public init (userID: String = "self") {
        self.userID = userID
    }

    public var cacheKey: String? {
        return "get-user-\(userID)-settings"
    }

    public var request: GetUserSettingsRequest {
        return GetUserSettingsRequest(userID: userID)
    }

    public var scope: Scope {
        return Scope(predicate: .all, order: [])
    }
}

public struct UpdateUserSettings: APIUseCase {
    public typealias Model = UserSettings

    public let cacheKey: String? = nil
    public let request: PutUserSettingsRequest
    public let scope = Scope(predicate: .all, order: [])

    public init(manual_mark_as_read: Bool? = nil, collapse_global_nav: Bool? = nil, hide_dashcard_color_overlays: Bool? = nil) {
        request = PutUserSettingsRequest(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays
        )
    }
}
