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

public enum APISelfRegistrationType: String, Codable {
    case all
    case none
    case observer
}

public struct APIAccountTermsOfService: Codable, Equatable {
    let account_id: ID
    let content: String?
    let id: ID?
    let passive: Bool?
    let terms_type: String?
    let self_registration_type: APISelfRegistrationType?
}

#if DEBUG
extension APIAccountTermsOfService {
    public static func make(
        account_id: ID = "1",
        content: String? = "content",
        id: ID? = nil,
        passive: Bool? = false,
        terms_type: String? = nil,
        self_registration_type: APISelfRegistrationType? = nil
    ) -> APIAccountTermsOfService {
        return APIAccountTermsOfService(
            account_id: account_id,
            content: content,
            id: id,
            passive: passive,
            terms_type: terms_type,
            self_registration_type: self_registration_type
        )
    }
}
#endif

public struct GetAccountTermsOfServiceRequest: APIRequestable {
    public typealias Response = APIAccountTermsOfService
    public let path = "accounts/self/terms_of_service"
}
