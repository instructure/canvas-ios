//
// Copyright (C) 2016-present Instructure, Inc.
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
@testable import Core

class MockAPI: API {
    let baseURL = URL(string: "https://cgnuonline-eniversity.edu")!
    let accessToken = "fhwdgads"

    var mocks: [URLRequest: (Data?, URLResponse?, Error?)] = [:]

    func mock<R: APIRequestable>(_ requestable: R, value: R.Response? = nil, response: URLResponse? = nil, error: Error? = nil) {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken)
        var data: Data? = nil
        if let value = value {
            data = try! JSONEncoder().encode(value)
        }
        mocks[request] = (data, response, error)
    }

    @discardableResult
    func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken)
        if let (data, response, error) = mocks[request] {
            var value: R.Response? = nil
            if let data = data {
                value = try! JSONDecoder().decode(R.Response.self, from: data)
            }
            callback(value, response, error)
            return nil
        }
        callback(nil, nil, nil)
        return nil
    }
}
