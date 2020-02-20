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

class APIGraphQLRequestableTests: XCTestCase {

    struct MockRequest: APIGraphQLRequestable {
        typealias Response = APINoContent

        let operationName: String = "Test"
        var query: String? {
            return "id name foo"
        }
    }

    func testPath() {
        let mock = MockRequest()
        XCTAssertEqual(mock.path, "/api/graphql")
    }

    func testMethod() {
        let mock = MockRequest()
        XCTAssertEqual(mock.method, .post)
    }

    func testBody() {
        let mock = MockRequest()
        let query = "id name foo"
        let operationName = "Test"
        let expectedBody = GraphQLBody(query: query, operationName: operationName)
        XCTAssertEqual(mock.body, expectedBody)
    }

    func testQuery() {
        let mock = MockRequest()
        let query = "id name foo"
        XCTAssertEqual(mock.query, query)
    }

}
