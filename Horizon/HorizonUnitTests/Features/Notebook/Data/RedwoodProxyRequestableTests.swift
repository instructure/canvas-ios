//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Horizon
import XCTest

final class RedwoodProxyRequestableTests: XCTestCase {

    func test_query_isCorrectlyFormatted() {
        // Given
        let expectedQuery = """
        mutation ProxyWrapper($input: RedwoodQueryInput!) {
            executeRedwoodQuery(input: $input) {
                data
                errors
            }
        }
        """

        // When
        let query = TestProxyRequest.query

        // Then
        XCTAssertEqual(query, expectedQuery)
    }
}

private struct TestInnerVariables: Codable, Equatable {
    let id: String
}

private struct TestProxyRequest: RedwoodProxyRequestable {
    typealias Response = TestProxyRespone

    typealias InnerVariables = TestInnerVariables

    static let operationName = "ProxyWrapper"
    static let innerOperationName = "InnerQuery"
    static let innerQuery = "query Inner { test }"

    let innerVariables: InnerVariables

    struct TestProxyRespone: Codable { }
}
