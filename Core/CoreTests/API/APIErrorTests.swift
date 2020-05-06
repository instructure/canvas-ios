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

class APIErrorTests: XCTestCase {
    func from(data: Data? = nil, response: URLResponse? = nil) -> String {
        let error = APIError.from(data: data, response: response, error: NSError.instructureError("default"))
        return error.localizedDescription
    }

    func from(dict: [String: Any], response: URLResponse? = nil) -> String {
        return from(data: try! JSONSerialization.data(withJSONObject: dict), response: response)
    }

    func testCreateAccountErrors() {
        let str = """
        {
            "errors": {
                "user": {},
                "observee": {},
                "pairing_code": {
                    "code": [{
                        "attribute": "code",
                        "type": "invalid",
                        "message": "invalid"
                    }]
                },
            }
        }
        """
        let data = str.data(using: .utf8)
        let error = APIError.from(data: data, response: nil, error: NSError.instructureError("default"))
        XCTAssertEqual(error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines), "code: invalid")
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
