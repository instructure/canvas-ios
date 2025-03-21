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
            "5": 5
            ] ]).split(separator: "\n").sorted().joined(separator: "\n"),
            "a\nb\nc\nd"
        )
        XCTAssertEqual(from(dict: [:]), "default")
        XCTAssertEqual(from(response: HTTPURLResponse(url: .make(), statusCode: 200, httpVersion: nil, headerFields: nil)), "There was an unexpected error. Please try again.")
        XCTAssertEqual(from(response: HTTPURLResponse(url: .make(), statusCode: 400, httpVersion: nil, headerFields: nil)), "There was an unexpected error. Please try again.")
    }

    func testUnauthorizedAPIError() {
        let stringData = """
        {
            "status": "nicht berechtigt",
            "errors": [{
                "message": "Benutzer ist zu dieser Aktion nicht berechtigt."
            }]
        }
        """
        let data = stringData.data(using: .utf8)
        let response = HTTPURLResponse(url: .make(), statusCode: 401, httpVersion: nil, headerFields: nil)

        let error = APIError.from(data: data, response: response, error: NSError.instructureError("default"))

        guard let apiError = error as? APIError else { XCTFail("Error is not an APIError"); return }
        guard case .unauthorized = apiError else { XCTFail("Error is not an APIError.unauthorized"); return }
        XCTAssertEqual(apiError.localizedDescription, "Benutzer ist zu dieser Aktion nicht berechtigt.")
    }

    func testBadRequest() {
        let response = HTTPURLResponse(url: .make(), statusCode: 400, httpVersion: nil, headerFields: nil)
        let error = APIError.from(data: nil, response: response, error: NSError.instructureError("default"))

        let nsError = error as NSError
        XCTAssertEqual(nsError.code, HttpError.badRequest)
    }

    func testUnauthorized() {
        let response = HTTPURLResponse(url: .make(), statusCode: 401, httpVersion: nil, headerFields: nil)
        let error = APIError.from(data: nil, response: response, error: NSError.instructureError("default"))

        let nsError = error as NSError
        XCTAssertEqual(nsError.code, HttpError.unauthorized)
    }

    func testForbidden() {
        let response = HTTPURLResponse(url: .make(), statusCode: 403, httpVersion: nil, headerFields: nil)
        let error = APIError.from(data: nil, response: response, error: NSError.instructureError("default"))

        let nsError = error as NSError
        XCTAssertEqual(nsError.code, HttpError.forbidden)
    }

    func testNotFound() {
        let response = HTTPURLResponse(url: .make(), statusCode: 404, httpVersion: nil, headerFields: nil)
        let error = APIError.from(data: nil, response: response, error: NSError.instructureError("default"))

        let nsError = error as NSError
        XCTAssertEqual(nsError.code, HttpError.notFound)
    }

    func testUnexpected() {
        let response = HTTPURLResponse(url: .make(), statusCode: 500, httpVersion: nil, headerFields: nil)
        let error = APIError.from(data: nil, response: response, error: NSError.instructureError("default"))

        let nsError = error as NSError
        XCTAssertEqual(nsError.code, HttpError.unexpected)
    }

    func testRefreshTokenError() throws {
        let response = HTTPURLResponse(url: .make(), statusCode: 400, httpVersion: nil, headerFields: nil)
        let responseBody = """
        {
            "error": "invalid_grant",
            "error_description": "refresh_token not found"
        }
        """
        let responseData = try XCTUnwrap(responseBody.data(using: .utf8))
        enum TestCodingKeys: CodingKey {
            case error
        }
        let decodingError = DecodingError.keyNotFound(TestCodingKeys.error, .init(codingPath: [], debugDescription: ""))
        let error = APIError.from(data: responseData, response: response, error: decodingError)

        // WHEN
        let apiError = try XCTUnwrap(error as? APIError)

        // THEN
        guard case APIError.invalidGrant(message: "refresh_token not found") = apiError else {
            return XCTFail()
        }
        XCTAssertEqual(error.localizedDescription, "refresh_token not found")
    }
}
