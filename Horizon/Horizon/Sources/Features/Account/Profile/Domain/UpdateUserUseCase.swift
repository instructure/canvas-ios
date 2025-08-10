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

import Core
import CoreData

class UpdateUserUseCase: APIUseCase {
    var cacheKey: String?

    public typealias Response = APIUser
    public typealias Model = UserProfile

    private let name: String?
    private let shortName: String?
    private let timeZone: String?

    init(name: String? = nil, shortName: String? = nil, timeZone: String? = nil) {
        self.name = name
        self.shortName = shortName
        self.timeZone = timeZone
    }

    public var request: PutUserInfoRequest {
        .init(name: name, shortName: shortName, timeZone: timeZone)
    }

    func write(response: APIUser?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        UserProfile.save(response, in: client)
    }
}

extension UserProfile {
    @discardableResult
    public static func save(_ item: APIUser, in context: NSManagedObjectContext) -> UserProfile {
        let model: UserProfile = context.first(where: #keyPath(UserProfile.id), equals: item.id.value) ?? context.insert()
        model.id = item.id.value
        model.name = item.name
        model.shortName = item.short_name
        model.email = item.email
        model.locale = item.locale
        model.loginID = item.login_id
        model.avatarURL = item.avatar_url?.rawValue
        model.pronouns = item.pronouns
        model.defaultTimeZone = item.time_zone
        return model
    }
}

struct PutUserInfoRequest: APIRequestable {
    let name: String?
    let shortName: String?
    let timeZone: String?

    typealias Response = APIUser

    struct Body: Encodable {
        let user: User
    }
    struct User: Encodable {
        let name: String?
        let short_name: String?
        let time_zone: String?
    }
    let method = APIMethod.put
    let path = "users/self"
    var body: Body? {
        return Body(user: User(name: name, short_name: shortName, time_zone: timeZone))
    }
}
