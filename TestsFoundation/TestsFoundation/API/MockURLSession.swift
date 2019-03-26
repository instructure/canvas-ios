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

import Foundation
import Core

public class MockURLSession {
    public static func mockData<R: APIRequestable>(
        _ requestable: R,
        value: R.Response? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) throws -> Data {
        let api = URLSessionAPI()
        let request = try requestable.urlRequest(relativeTo: api.baseURL, accessToken: api.accessToken, actAsUserID: api.actAsUserID)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try value.flatMap { try encoder.encode($0) }
        return try mockData(request, data: data, response: response, error: error, noCallback: noCallback)
    }

    public static func mockData(
        _ request: URLRequest,
        data: Data? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil,
        noCallback: Bool = false
    ) throws -> Data {
        return try JSONEncoder().encode(MockDataMessage(
            data: data,
            error: error,
            request: request,
            response: response.flatMap { MockResponse(http: $0) },
            noCallback: noCallback
        ))
    }

    public static func mockDownload(
        _ url: URL,
        data: URL? = nil,
        response: HTTPURLResponse? = nil,
        error: String? = nil
    ) throws -> Data {
        return try JSONEncoder().encode(MockDownloadMessage(
            data: try data.flatMap { try Data(contentsOf: $0) },
            error: error,
            response: response.flatMap { MockResponse(http: $0) },
            url: url
        ))
    }
}
