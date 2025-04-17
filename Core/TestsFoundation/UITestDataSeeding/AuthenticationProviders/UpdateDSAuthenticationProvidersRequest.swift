//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/authentication_providers.html#method.authentication_providers.update
public struct UpdateDSAuthenticationProviderRequest: APIRequestable {
    public typealias Response = DSAuthenticationProvider

    public let method = APIMethod.put
    public var path: String
    public let body: Body?
    private let canvasAuthenticationProviderId: String = "1536"

    public init(body: Body) {
        self.body = body
        self.path = "accounts/self/authentication_providers/\(canvasAuthenticationProviderId)"
    }
}

extension UpdateDSAuthenticationProviderRequest {
    public struct Body: Encodable {
        let self_registration: DSSelfRegistration

        public init(selfRegistration: DSSelfRegistration) {
            self.self_registration = selfRegistration
        }
    }
}

public enum DSSelfRegistration: String, RawRepresentable, Encodable {
    case all
    case none
    case observer
}
