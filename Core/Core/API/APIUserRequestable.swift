//
// Copyright (C) 2018-present Instructure, Inc.
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
