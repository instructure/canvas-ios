//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct CreateDSUserRequest: APIRequestable {
    public typealias Response = DSUser

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(body: Body?, isK5: Bool = false) {
        self.body = body
        let accountId = isK5 ? Secret.k5SubAccountId.string! : "self"
        self.path = "accounts/\(accountId)/users"
    }
}

extension CreateDSUserRequest {
    public struct Body: Encodable, Equatable {
        struct User: Encodable, Equatable {
            let name: String
            let time_zone: String = "Europe/Budapest"
        }

        struct Pseudonym: Encodable, Equatable {
            let unique_id = UUID().uuidString
            let password: String
        }

        let user: User
        let pseudonym: Pseudonym
    }
}
