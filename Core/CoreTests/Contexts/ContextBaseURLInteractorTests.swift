//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class ContextBaseURLInteractorTests: CoreTestCase {

    func testExtractsBaseURL() {
        let context = Context(.course, id: "testID")
        let testee = ContextBaseURLInteractor(api: api)

        let mockRequest = GetContextHead(context: context)
        let mockResponse = HTTPURLResponse(url: URL(string: "/")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: [
                                            "content-security-policy": "junk.com; frame-ancestors \'self\' test.instructure.com;"
                                           ])
        api.mock(mockRequest, data: nil, response: mockResponse, error: nil)

        XCTAssertSingleOutputEquals(testee.getBaseURL(context: context), URL(string: "https://test.instructure.com")!)
    }

    func testFailsOnAPIError() {
        let context = Context(.course, id: "testID")
        let testee = ContextBaseURLInteractor(api: api)

        let mockRequest = GetContextHead(context: context)
        api.mock(mockRequest, data: nil, response: nil, error: NSError.instructureError("testError"))

        XCTAssertFailure(testee.getBaseURL(context: context))
    }

    func testFailsOnInvalidHeaderFieldContent() {
        let context = Context(.course, id: "testID")
        let testee = ContextBaseURLInteractor(api: api)

        let mockRequest = GetContextHead(context: context)
        let mockResponse = HTTPURLResponse(url: URL(string: "/")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: [
                                            "content-security-policy": "junk.com;"
                                           ])
        api.mock(mockRequest, data: nil, response: mockResponse, error: nil)

        XCTAssertFailure(testee.getBaseURL(context: context))
    }

    func testFailsOnMissingHeader() {
        let context = Context(.course, id: "testID")
        let testee = ContextBaseURLInteractor(api: api)

        let mockRequest = GetContextHead(context: context)
        let mockResponse = HTTPURLResponse(url: URL(string: "/")!,
                                           statusCode: 200,
                                           httpVersion: nil,
                                           headerFields: [:])
        api.mock(mockRequest, data: nil, response: mockResponse, error: nil)

        XCTAssertFailure(testee.getBaseURL(context: context))
    }
}
