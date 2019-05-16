//
// Copyright (C) 2019-present Instructure, Inc.
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

import XCTest
@testable import Core

class APIErrorTests: XCTestCase {
    func from(data: Data? = nil, response: URLResponse? = nil) -> String {
        let error = APIError.from(data: data, response: response, error: NSError.instructureError("default"))
        return error.localizedDescription
    }

    func from(dict: [String: Any], response: URLResponse? = nil) -> String {
        return from(data: try! JSONSerialization.data(withJSONObject: dict), response: response)
    }

    func testFrom() {
        XCTAssertEqual(from(), "default")
        XCTAssertEqual(from(data: Data()), "default")
        XCTAssertEqual(from(dict: [ "message": "msg" ]), "msg")
        XCTAssertEqual(from(dict: [ "errors": [["message": "1"], [:]] ]), "1\n")
        XCTAssertEqual(from(dict: [ "errors": [
            "1": "a",
            "2": [ "b", "z" ],
            "3": [ "message": "c" ],
            "4": [ [ "message": "d" ], [ "message": "y" ] ],
            "5": 5,
            ], ]).split(separator: "\n").sorted().joined(separator: "\n"),
            "a\nb\nc\nd"
        )
        XCTAssertEqual(from(dict: [:]), "default")
        XCTAssertEqual(from(response: HTTPURLResponse(url: URL(string: "/")!, statusCode: 200, httpVersion: nil, headerFields: nil)), "default")
        XCTAssertEqual(from(response: HTTPURLResponse(url: URL(string: "/")!, statusCode: 400, httpVersion: nil, headerFields: nil)), "There was an unexpected error. Please try again.")
    }
}
