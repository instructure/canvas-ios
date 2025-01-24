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

import XCTest
@testable import Core

extension APIGraphQLRequestable {
    func assertBodyEquals(_ expected: GraphQLBody<Variables>) {
        XCTAssertEqual(body, expected)
    }
}

class APIGraphQLRequestableTests: XCTestCase {

    struct MockRequest: APIGraphQLRequestable {
        typealias Response = APINoContent
        typealias Variables = [String: String]
        static let query = "id name foo"
        let variables: Variables
    }

    func testPath() {
        let mock = MockRequest(variables: [:])
        XCTAssertEqual(mock.path, "/api/graphql")
    }

    func testMethod() {
        let mock = MockRequest(variables: [:])
        XCTAssertEqual(mock.method, .post)
    }

    func testBody() {
        let vars = ["var": "value"]
        let mock = MockRequest(variables: vars)
        let query = "id name foo"
        let operationName = "MockRequest"
        mock.assertBodyEquals(GraphQLBody(query: query, operationName: operationName, variables: vars))
    }
}
