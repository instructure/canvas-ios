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
    func makeRequest<Request: APIRequestable>(_ requestable: Request, refreshToken: Bool = true) async throws -> (body: Request.Response, urlResponse: HTTPURLResponse?) {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(requestable, refreshToken: refreshToken) { response, urlResponse, error in
                if let response {
                    continuation.resume(returning: (response, urlResponse as? HTTPURLResponse))
                } else if let error {
                    continuation.resume(throwing: error)
                } else if let noContent = APINoContent() as? Request.Response {
                    continuation.resume(returning: (noContent, urlResponse as? HTTPURLResponse))
                } else {
                    continuation.resume(throwing: NSError.instructureError("No response or error received."))
                }
            }
        }
    }

    func exhaust<Request: APIRequestable>(
        _ requestable: Request
    ) async throws -> (body: Request.Response, urlResponse: HTTPURLResponse?)
    where Request.Response: RangeReplaceableCollection {
        try await withCheckedThrowingContinuation { continuation in
            exhaust(requestable) { response, urlResponse, error in
                if let response {
                    continuation.resume(returning: (response, urlResponse as? HTTPURLResponse))
                } else if let error {
                    continuation.resume(throwing: error)
                } else if let response = APINoContent() as? Request.Response {
                    continuation.resume(returning: (response, urlResponse as? HTTPURLResponse))
                } else {
                    continuation.resume(throwing: NSError.instructureError("No response or error received."))
                }
            }
        }
    }

    func exhaust<Request: APIPagedRequestable>(
        _ requestable: Request
    ) async throws -> (body: Request.Response.Page, urlResponse: HTTPURLResponse?) {
        try await withCheckedThrowingContinuation { continuation in
            exhaust(requestable) { response, urlResponse, error in
                if let response {
                    continuation.resume(returning: (response, urlResponse: urlResponse as? HTTPURLResponse))
                } else {
                    continuation.resume(throwing: error ?? NSError.instructureError("No response or error received."))
                }
            }
        }
    }

    func makeRequest(_ url: URL, method: APIMethod? = nil) async throws -> (URLResponse?) {
        try await withCheckedThrowingContinuation { continuation in
            makeDownloadRequest(url, method: method) { _, response, error in
                if let response {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: error ?? NSError.instructureError("No response or error received."))
                }
            }
        }
    }
}
