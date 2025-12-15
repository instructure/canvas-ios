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
    //    @discardableResult
    //    func makeRequest<Request: APIRequestable>(
    //        _ requestable: Request,
    //        refreshToken: Bool = true
    //    ) async throws -> (Request.Response, HTTPURLResponse?) {
    //        try await withCheckedThrowingContinuation { continuation in
    //            makeRequest(requestable) { response, urlResponse, error in
    //                if let response {
    //                    continuation.resume(returning: (response, urlResponse as? HTTPURLResponse))
    //                } else if let error {
    //                    continuation.resume(throwing: error)
    //                } else if Request.Response.self is APINoContent.Type {
    //                    swiftlint force cast disable
    //                    continuation.resume(returning: (APINoContent() as! Request.Response,
    //                                                    urlResponse as? HTTPURLResponse))
    //                } else {
    //                    continuation.resume(throwing: NSError.instructureError("No response or error received."))
    //                }
    //            }
    //        }
    //    }

    // TODO: convert to use native async/await
    @discardableResult
    func makeRequest<Request: APIRequestable>(
        _ requestable: Request,
        refreshToken: Bool = true
    ) async throws -> (Request.Response, URLResponse?) {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(requestable) { response, urlResponse, error in
                if let response {
                    continuation.resume(returning: (response, urlResponse))
                } else {
                    let error = AsyncAPIError.responseIsMissing(urlResponse: urlResponse, error: error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func exhaustWithHttpResponse<Request: APIRequestable>(_ requestable: Request) async throws ->
    (body: Request.Response, urlResponse: HTTPURLResponse?) where Request.Response: RangeReplaceableCollection {
        let (response, urlResponse) = try await exhaust(requestable)

        return (response, urlResponse as? HTTPURLResponse)
    }

    func exhaust<R>(_ requestable: R) async throws -> (R.Response, URLResponse?)
    where R: APIRequestable, R.Response: RangeReplaceableCollection {
        try await exhaust(requestable, result: nil)
    }

    private func exhaust<R>(_ requestable: R, result: R.Response?) async throws -> (R.Response, URLResponse?) where R: APIRequestable, R.Response: RangeReplaceableCollection {
        let (response, urlResponse) = try await makeRequest(requestable)

        let result = if let result { result + response } else { response }

        if let urlResponse, let next = requestable.getNext(from: urlResponse) {
            return try await exhaust(next, result: result)
        }

        return (result, urlResponse)
    }
}

extension API {
    public enum AsyncAPIError: Error {
        case responseIsMissing(urlResponse: URLResponse?, error: Error?)
    }
}
