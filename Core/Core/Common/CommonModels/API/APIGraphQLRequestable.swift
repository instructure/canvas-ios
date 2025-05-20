//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public struct GraphQLBody<Variables: Codable & Equatable>: Codable, Equatable {
    let query: String
    let operationName: String
    let variables: Variables
}

public protocol PagedResponse: Codable {
    associatedtype Page: Codable, RangeReplaceableCollection
    var page: Page { get }
}

public protocol APIPagedRequestable: APIRequestable where Response: PagedResponse {
    associatedtype NextRequest = Self
    func nextPageRequest(from response: Response) -> NextRequest?
}

public protocol APIGraphQLRequestable: APIRequestable {
    associatedtype Variables: Codable, Equatable

    static var query: String { get }
    static var operationName: String { get }
    var variables: Variables { get }
}

extension APIGraphQLRequestable {
    public var method: APIMethod {
        .post
    }

    public var path: String {
        "/api/graphql"
    }

    public static var operationName: String {
        "\(self)"
    }

    public var body: GraphQLBody<Variables>? {
        GraphQLBody(query: Self.query, operationName: Self.operationName, variables: variables)
    }
}

typealias APIGraphQLPagedRequestable = APIGraphQLRequestable & APIPagedRequestable
