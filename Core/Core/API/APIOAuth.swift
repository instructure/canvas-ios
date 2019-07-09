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

// Not documented in canvas rest api
struct APIVerifyClient: Codable, Equatable {
    let authorized: Bool
    let base_url: URL?
    let client_id: String?
    let client_secret: String?
}

// https://canvas.instructure.com/doc/api/file.oauth_endpoints.html#post-login-oauth2-token
public struct APIOAuthToken: Codable, Equatable {
    let access_token: String
    let refresh_token: String?
    let token_type: String
    let user: APIOAuthUser
    let expires_in: TimeInterval?
}

public struct APIOAuthUser: Codable, Equatable {
    let id: ID
    let name: String
    let effective_locale: String
    let email: String?
}
