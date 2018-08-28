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
import XCTest
@testable import Core

class APIOperationTest: CoreTestCase {
    enum APIOperationTestError: Error {
        case error
    }

    func testResponse() {
        let request = MockRequest(path: "/api")
        api.mock(request, value: [])

        let op = APIOperation(api: api, request: request)
        queue.addOperation(op)
        queue.waitUntilAllOperationsAreFinished()

        XCTAssertEqual(op.response, [])
    }

    func testError() {
        let request = MockRequest(path: "/api")
        api.mock(request, value: nil, response: nil, error: APIOperationTestError.error)

        let op = APIOperation(api: api, request: request)
        queue.addOperation(op)
        queue.waitUntilAllOperationsAreFinished()

        XCTAssertEqual(op.error?.localizedDescription, APIOperationTestError.error.localizedDescription)
    }

    func testNext() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        let request = MockRequest(path: "/api")
        api.mock(request, value: nil, response: response, error: nil)

        let op = APIOperation(api: api, request: request)
        queue.addOperation(op)
        queue.waitUntilAllOperationsAreFinished()

        XCTAssertEqual(op.next?.path, next)
    }
}
