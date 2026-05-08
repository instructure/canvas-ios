//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData

public struct GetUserProfile: APIUseCase {
    public typealias Model = UserProfile

    public let userID: String

    public init (userID: String = "self") {
        self.userID = userID
    }

    public var cacheKey: String? {
        return "get-user-\(userID)-profile"
    }

    public var request: GetUserProfileRequest {
        return GetUserProfileRequest(userID: userID)
    }

    public var scope: Scope {
        if userID == "self", let userID = AppEnvironment.shared.currentSession?.userID {
            return .where(#keyPath(UserProfile.id), equals: userID)
        }
        return .where(#keyPath(UserProfile.id), equals: userID)
    }
}
