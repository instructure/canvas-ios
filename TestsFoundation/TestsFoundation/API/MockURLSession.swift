//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
            data: data,
            error: error,
            response: response.flatMap { MockResponse(http: $0) },
            url: url
        ))
    }
}
