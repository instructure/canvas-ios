//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public struct PostObserverPairingCodes: APIRequestable {
    public typealias Response = APIPairingCode
    public var method: APIMethod = .post
    public var path: String = "users/self/observer_pairing_codes"
}

public struct APIPairingCode: Codable, Equatable {
    let user_id: ID?
    let code: String
    let expires_at: Date?
    let workflow_state: String?
}

public struct GetAccountTermsOfService: APIRequestable {
    public typealias Response = APIAccountTermsOfService
    public var path: String = "accounts/self/terms_of_service"
}

public struct APIAccountTermsOfService: Codable, Equatable {
    let account_id: ID
    let content: String?
    let id: ID?
    let passive: Bool?
    let terms_type: String?
}

#if DEBUG
extension APIPairingCode {
    public static func make(
        user_id: ID? = "1",
        code: String = "code",
        expires_at: Date? = Clock.now,
        workflow_state: String? = "active"
    ) -> APIPairingCode {
        return APIPairingCode(
            user_id: user_id,
            code: code,
            expires_at: expires_at,
            workflow_state: workflow_state
        )
    }
}

extension APIAccountTermsOfService {
    public static func make(
        account_id: ID = "1",
        content: String? = "content",
        id: ID? = nil,
        passive: Bool? = false,
        terms_type: String? = nil
    ) -> APIAccountTermsOfService {
        return APIAccountTermsOfService(
            account_id: account_id,
            content: content,
            id: id,
            passive: passive,
            terms_type: terms_type
        )
    }
}
#endif
