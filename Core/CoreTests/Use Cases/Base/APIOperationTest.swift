//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core
import TestsFoundation

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

        XCTAssertEqual(op.errors.first?.localizedDescription, APIOperationTestError.error.localizedDescription)
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
