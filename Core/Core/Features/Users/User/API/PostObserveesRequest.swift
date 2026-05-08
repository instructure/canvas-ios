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

import Foundation

// Note from PR #1275:
// GetObserveesRequest & GetObserveeRequest does not return manually linked observees.
// https://canvas.instructure.com/doc/api/user_observees.html#method.user_observees.index
// https://canvas.instructure.com/doc/api/user_observees.html#method.user_observees.show

// https://canvas.instructure.com/doc/api/user_observees.html#method.user_observees.create
public struct PostObserveesRequest: APIRequestable {
    public typealias Response = APIUser

    public let userID: String
    public let pairingCode: String?

    public init(userID: String, pairingCode: String? = nil) {
        self.userID = userID
        self.pairingCode = pairingCode
    }

    public let method: APIMethod = .post

    public var path: String {
        let context = Context(.user, id: userID)
        return "\(context.pathComponent)/observees"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        if let pairingCode = pairingCode {
            query.append(.value("pairing_code", pairingCode))
        }
        return query
    }
}
