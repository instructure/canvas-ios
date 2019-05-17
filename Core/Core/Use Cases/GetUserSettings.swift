//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
