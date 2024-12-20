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

// https://canvas.instructure.com/doc/api/account_domain_lookups.html#method.account_domain_lookups.search
public struct APIAccountResult: Codable, Equatable {
    public let name: String
    public let domain: String
    public let authentication_provider: String?

    public init(name: String, domain: String, authentication_provider: String?) {
        self.name = name
        self.domain = domain
        self.authentication_provider = authentication_provider
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name).trimmingCharacters(in: .whitespacesAndNewlines)
        domain = try container.decode(String.self, forKey: .domain)
        var auth = try container.decodeIfPresent(String.self, forKey: .authentication_provider)
        if auth?.isEmpty == true || auth == "Null" {
            auth = nil
        }
        authentication_provider = auth
    }
}

#if DEBUG
extension APIAccountResult {
    public static func make(
        name: String = "Crazy Go Nuts University",
        domain: String = "cgnuonline-eniversity.edu",
        authentication_provider: String? = nil
    ) -> APIAccountResult {
        return APIAccountResult(
            name: name,
            domain: domain,
            authentication_provider: authentication_provider
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/account_domain_lookups.html#method.account_domain_lookups.search
public struct GetAccountsSearchRequest: APIRequestable {
    public typealias Response = [APIAccountResult]

    public let searchTerm: String

    public let path = "https://canvas.instructure.com/api/v1/accounts/search"
    public var query: [APIQueryItem] {
        return [
            .perPage(50),
            .value("search_term", searchTerm)
        ]
    }
    public let headers: [String: String?] = [
        HttpHeader.authorization: nil
    ]
}
