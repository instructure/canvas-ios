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

import Foundation

public extension API {
    // TODO: convert to use native async/await
    @discardableResult
    func makeRequest<Request: APIRequestable>(
        _ requestable: Request,
        refreshToken: Bool = true
    ) async throws -> (Request.Response, HTTPURLResponse?) {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(requestable) { response, urlResponse, error in
                if let response {
                    continuation.resume(returning: (response, urlResponse as? HTTPURLResponse))
                } else if let error {
                    continuation.resume(throwing: error)
                } else if Request.Response.self is APINoContent.Type {
                        // swiftlint:disable:next force_cast
                    continuation.resume(returning: (APINoContent() as! Request.Response,
                                                    urlResponse as? HTTPURLResponse))
                } else {
                    continuation.resume(throwing: NSError.instructureError("No response or error received."))
                }
            }
        }
    }

    // TODO: convert to use native async/await
    @discardableResult
    func makeRequest<Request: APIRequestable>(
        _ requestable: Request,
        refreshToken: Bool = true
    ) async throws -> (Request.Response, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(requestable) { response, urlResponse, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let response, let urlResponse {
                    continuation.resume(returning: (response, urlResponse))
                } else {
                    continuation.resume(throwing: NSError.instructureError("No response or error received."))
                }
            }
        }
    }
}
