//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/users.html#method.users.get_custom_color
public struct GetCustomColorsRequest: APIRequestable {
    public typealias Response = APICustomColors

    public let path = "users/self/colors"
}

// https://canvas.instructure.com/doc/api/users.html#method.users.api_show
struct GetUserRequest: APIRequestable {
    typealias Response = APIUser

    let userID: String

    var path: String {
        return ContextModel(.user, id: userID).pathComponent
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.create
struct CreateUserRequest: APIRequestable {
    typealias Response = APIUser
    struct Body: Codable, Equatable {
        struct User: Codable, Equatable {
            let name: String
        }

        struct Pseudonym: Codable, Equatable {
            let unique_id: String
            let password: String
        }

        let user: User
        let pseudonym: Pseudonym
    }

    let accountID: String

    let body: Body?
    let method = APIMethod.post
    var path: String {
        return "\(ContextModel(.account, id: accountID).pathComponent)/users"
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.update
struct PutUserAvatarRequest: APIRequestable {
    typealias Response = APIUser

    struct Body: Encodable {
        let user: User
    }
    struct User: Encodable {
        let avatar: Avatar
    }
    struct Avatar: Encodable {
        let token: String
    }

    let token: String

    let method = APIMethod.put
    let path = "users/self"
    var body: Body? {
        return Body(user: User(avatar: Avatar(token: token)))
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.set_custom_color
struct UpdateCustomColorRequest: APIRequestable {
    struct Response: Codable {
        let hexcode: String // does include '#'
    }
    struct Body: Codable, Equatable {
        let hexcode: String // does NOT include '#'
    }

    let userID: String
    let context: Context

    let body: Body?
    let method = APIMethod.put
    var path: String {
        return "users/\(userID)/colors/\(context.canvasContextID)"
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.users.settings
public struct GetUserSettingsRequest: APIRequestable {
    public typealias Response = APIUserSettings

    let userID: String

    public let method = APIMethod.get
    public var path: String {
        return "users/\(userID)/settings"
    }
}

// https://canvas.instructure.com/doc/api/users.html#method.profile.settings
public struct GetUserProfileRequest: APIRequestable {
    public typealias Response = APIProfile

    public let userID: String

    public var path: String {
        let context = ContextModel(.user, id: userID)
        return "\(context.pathComponent)/profile"
    }

    public init(userID: String) {
        self.userID = userID
    }
}
