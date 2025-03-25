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

public struct APIPairingCode: Codable, Equatable {
    let user_id: ID?
    let code: String
    let expires_at: Date?
    let workflow_state: String?
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
#endif

public struct PostObserverPairingCodes: APIRequestable {
    public typealias Response = APIPairingCode
    public var method: APIMethod = .post
    public var path: String = "users/self/observer_pairing_codes"
}

//  https://canvas.instructure.com/doc/api/users.html#method.users.create
public struct PostAccountUserRequest: APIRequestable {
    public typealias Response = APIUser
    public let method: APIMethod = .post
    public var body: Body?
    public let shouldAddNoVerifierQuery = false
    let baseURL: URL
    let accountID: String
    public var shouldHandleCookies: Bool = false

    public init(baseURL: URL, accountID: String, pairingCode: String, name: String, email: String, password: String) {
        self.baseURL = baseURL
        self.accountID = accountID
        self.body = Body(
            pseudonym: Body.Pseudonym(unique_id: email, password: password),
            pairing_code: Body.PairingCode(code: pairingCode),
            user: Body.User(name: name, initial_enrollment_type: "observer")
        )
    }

    public let headers: [String: String?] = [
        HttpHeader.accept: "application/json",
        HttpHeader.authorization: nil
    ]

    public var cachePolicy: URLRequest.CachePolicy {
        return .reloadIgnoringLocalAndRemoteCacheData
    }

    public var path: String {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.scheme = "https"
        return components?.url?.appendingPathComponent("/api/v1/accounts/\(accountID)/users").absoluteString ??  ""
    }

    public struct Body: Codable, Equatable {
        public struct Pseudonym: Codable, Equatable {
            let unique_id: String
            let password: String
        }
        public struct PairingCode: Codable, Equatable {
            let code: String
        }
        public struct User: Codable, Equatable {
            let name: String
            let initial_enrollment_type: String
            var terms_of_use: Bool = true
        }
        let pseudonym: Pseudonym
        let pairing_code: PairingCode
        let user: User
    }
}
