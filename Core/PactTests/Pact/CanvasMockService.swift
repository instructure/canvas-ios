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
    var api: URLSessionAPI { URLSessionAPI(baseURL: URL(string: baseUrl)!) }

    @discardableResult
    func uponReceiving<R: APIRequestable>(
        _ testDescription: String,
        with apiRequest: R,
        respondWith response: R.Response
    ) throws -> Interaction {
        let urlRequest = try apiRequest.urlRequest(relativeTo: api.baseURL, accessToken: "t", actAsUserID: nil)
        let url = urlRequest.url!

        return uponReceiving(testDescription)
            .withRequest(
                method: PactHTTPMethod(urlRequest.method),
                path: url.path,
                query: url.query,
                headers: apiRequest.headers as [String: Any],
                body: try PactEncoder.encodeToJsonObject(apiRequest.body)
        ).willRespondWith(status: 200, body: try PactEncoder.encodeToJsonObject(response))
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
