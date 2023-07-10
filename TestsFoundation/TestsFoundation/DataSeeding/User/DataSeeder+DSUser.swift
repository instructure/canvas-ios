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

extension DataSeeder {

    public func createUsers(_ count: Int) -> [DSUser] {
        var users: [DSUser] = []

        for _ in 0..<count {
            users.append(createUser())
        }

        return users
    }

    public func createUser(name: String = "DataSeed iOS \(Int(Date().timeIntervalSince1970))", password: String = "password") -> DSUser {
        let requestedUser = CreateDSUserRequest.Body.User(name: name)
        let requestedPseudonym = CreateDSUserRequest.Body.Pseudonym(password: password)
        let request = CreateDSUserRequest(body: CreateDSUserRequest.Body(user: requestedUser, pseudonym: requestedPseudonym))
        var result = makeRequest(request)
        result.password = password
        return result
    }
}
