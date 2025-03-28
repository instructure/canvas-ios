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

import Foundation

public enum OAuthType: Codable {
    case manual(ManualOAuthAttributes)
    case pkce(PKCEOAuthAttributes)

    var baseURL: URL? {
        switch self {
        case let .manual(attributes):
            return attributes.baseURL
        case let .pkce(attributes):
            return attributes.baseURL
        }
    }
}

public struct ManualOAuthAttributes: Codable {
    let baseURL: URL?
    let clientID: String?
    let clientSecret: String?

    public init(baseURL: URL?, clientID: String?, clientSecret: String?) {
        self.baseURL = baseURL
        self.clientID = clientID
        self.clientSecret = clientSecret
    }

    public init(client: APIVerifyClient) {
        self.baseURL = client.base_url
        self.clientID = client.client_id
        self.clientSecret = client.client_secret
    }
}

public struct PKCEOAuthAttributes: Codable {
    let baseURL: URL
    let clientID: String
    let codeVerifier: String
}
