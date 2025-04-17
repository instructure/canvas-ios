//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

extension API {

    @discardableResult
    public func mock<Request: APIRequestable>(
        _ request: Request,
        expectation: XCTestExpectation,
        value: Request.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> APIMock {
        mock(request) { _ in
            expectation.fulfill()
            return (value, response, error)
        }
    }

    @discardableResult
    public func mock<U: APIUseCase>(
        _ useCase: U,
        expectation: XCTestExpectation,
        value: U.Request.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> APIMock {
        mock(useCase.request, expectation: expectation, value: value, response: response, error: error)
    }
}
