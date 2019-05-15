//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/account_domain_lookups.html#method.account_domain_lookups.search
public struct GetAccountsSearchRequest: APIRequestable {
    public typealias Response = [APIAccountResults]

    public let searchTerm: String

    public let path = "https://canvas.instructure.com/api/v1/accounts/search"
    public var query: [APIQueryItem] {
        return [
            .value("per_page", "50"),
            .value("search_term", searchTerm),
        ]
    }
    public let headers: [String: String?] = [
        HttpHeader.authorization: nil,
    ]
}
