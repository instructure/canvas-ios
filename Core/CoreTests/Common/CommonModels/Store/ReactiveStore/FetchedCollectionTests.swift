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

@testable import Core
import XCTest

class FetchedCollectionTests: CoreTestCase {

    func test_fetch() {
        let secondPageRequest = GetNextRequest<String>(path: "/test?page=2")
        api.mock(secondPageRequest, value: "2", response: HTTPURLResponse())

        let headerFields = [
            "Link": "<\(secondPageRequest.path)>; rel=\"next\"; count=1"
        ]
        let httpResponse = HTTPURLResponse(
            url: URL(string: "/test")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: headerFields
        )!
        api.mock(TestRequest(), value: "1", response: httpResponse)
        let testee = FetchedCollection(
            ofRequest: TestRequest.self,
            transform: { response in
                [Int(response)!]
            }
        )

        // WHEN
        let firstPageFetch = testee.fetch(TestRequest())

        // THEN
        XCTAssertSingleOutputEquals(firstPageFetch, [1], timeout: 1)
        XCTAssertTrue(testee.hasNext)

        // WHEN
        let secondPageFetch = testee.fetchNext()

        // THEN
        XCTAssertSingleOutputEquals(secondPageFetch, [1, 2], timeout: 1)
        XCTAssertFalse(testee.hasNext)
    }
}

private struct TestRequest: APIRequestable {
    typealias Response = String

    var path = "/test"
}
