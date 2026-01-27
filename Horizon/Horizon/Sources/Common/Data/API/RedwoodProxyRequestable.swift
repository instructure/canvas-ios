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

import Core
import Foundation

protocol RedwoodProxyRequestable: APIGraphQLRequestable where Variables == RedwoodProxyInput<InnerVariables> {
    associatedtype InnerVariables: Codable, Equatable
    static var innerQuery: String { get }
    static var innerOperationName: String { get }
    var innerVariables: InnerVariables { get }
}

extension RedwoodProxyRequestable {
    static var query: String {
        """
        mutation \(operationName)($input: RedwoodQueryInput!) {
            executeRedwoodQuery(input: $input) {
                data
                errors
            }
        }
        """
    }

    var variables: RedwoodProxyInput<InnerVariables> {
        RedwoodProxyInput(
            input: RedwoodProxyPayload(
                query: Self.innerQuery,
                variables: innerVariables,
                operationName: Self.innerOperationName
            )
        )
    }
}

struct RedwoodProxyInput<InnerVars: Codable & Equatable>: Codable, Equatable {
    let input: RedwoodProxyPayload<InnerVars>
}

struct RedwoodProxyPayload<InnerVars: Codable & Equatable>: Codable, Equatable {
    let query: String
    let variables: InnerVars
    let operationName: String
}
