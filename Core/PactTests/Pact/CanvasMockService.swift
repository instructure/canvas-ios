//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Core
import PactConsumerSwift
import TestsFoundation

class CanvasMockService: MockService {
    var user = "Student1"
    var baseHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json+canvas-string-ids",
            "Authorization": "Bearer abcdefghijklmnopqrstuvwxyz01",
            "Auth-User": user,
        ]
    }

    var api: URLSessionAPI {
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.httpAdditionalHeaders = baseHeaders

        let session = URLSession(configuration: sessionConfig)
        return URLSessionAPI(baseURL: URL(string: baseUrl)!, urlSession: session)
    }

    @discardableResult
    func uponReceiving<R: APIRequestable>(
        _ testDescription: String,
        with apiRequest: R
    ) throws -> Interaction {
        let urlRequest = try apiRequest.urlRequest(relativeTo: api.baseURL, accessToken: "t", actAsUserID: nil)
        let url = urlRequest.url!

        var headers = apiRequest.headers as [String: Any]
        for (key, value) in baseHeaders where headers[key] == nil {
            headers[key] = value
        }

        return uponReceiving(testDescription).withRequest(
            method: PactHTTPMethod(apiRequest.method),
            path: url.path,
            query: url.query,
            headers: headers,
            body: try PactEncoder.encodeToJsonObject(apiRequest.body)
        )
    }

    @discardableResult
    func uponReceiving<R: APIRequestable>(
        _ testDescription: String,
        with apiRequest: R,
        respondWith response: R.Response,
        status: Int = 200
    ) throws -> Interaction {
        try uponReceiving(
            testDescription,
            with: apiRequest
        ).willRespondWith(status: status, body: PactEncoder.encodeToJsonObject(response))
    }

    @discardableResult
    func uponReceiving<R: APIRequestable, T>(
        _ testDescription: String,
        with apiRequest: R,
        respondWithArrayLike response: T,
        min: Int = 1,
        status: Int = 200
    ) throws -> Interaction where R.Response == [T] {
        let element = try PactEncoder.encodeToJsonObject(response)
        return try uponReceiving(
            testDescription,
            with: apiRequest
        ).willRespondWith(status: status, body: Matcher.eachLike(element, min: min))
    }
}

extension PactHTTPMethod {
    init(_ method: APIMethod) {
        switch method {
        case .delete: self = .DELETE
        case .get: self = .GET
        case .post: self = .POST
        case .put: self = .PUT
        }
    }
}
