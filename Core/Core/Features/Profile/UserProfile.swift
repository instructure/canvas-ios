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
import CoreData

public final class UserProfile: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var email: String?
    @NSManaged public var locale: String?
    @NSManaged public var loginID: String?
    @NSManaged public var avatarURL: URL?
    @NSManaged public var calendarURL: URL?
    @NSManaged public var pronouns: String?
    @NSManaged public var isK5User: Bool
    @NSManaged public var uuid: String?
    @NSManaged public var accountUUID: String?
}

extension UserProfile: WriteableModel {
    @discardableResult
    public static func save(_ item: APIProfile, in context: NSManagedObjectContext) -> UserProfile {
        let model: UserProfile = context.first(where: #keyPath(UserProfile.id), equals: item.id.value) ?? context.insert()
        model.id = item.id.value
        model.name = item.name
        model.email = item.primary_email
        model.locale = item.locale
        model.loginID = item.login_id
        model.avatarURL = item.avatar_url?.rawValue
        model.calendarURL = item.calendar?.ics
        model.pronouns = item.pronouns
        model.isK5User = (item.k5_user == true)
        return model
    }
}

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

public struct GetSelfUser: APIUseCase {
    public typealias Model = UserProfile

    public init () {}

    public var cacheKey: String? {
        return "get-self-user"
    }

    public var request: GetSelfUserRequest {
        return GetSelfUserRequest()
    }
}
