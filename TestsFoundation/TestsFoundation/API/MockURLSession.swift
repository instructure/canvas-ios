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

import Core

public class MockURLSession: URLSession {
    public static var dataMocks: [URLRequest: MockDataTask] = [:]
    public struct MockData {
        public let data: Data?
        public let response: URLResponse?
        public let error: Error?
    }

    public class MockDataTask: URLSessionDataTask {
        public var callback: ((Data?, URLResponse?, Error?) -> Void)?
        public var mock: MockData?
        public var resumed = false
        public var canceled = false
        public override func resume() {
            callback?(mock?.data, mock?.response, mock?.error)
            resumed = true
        }
        public override func cancel() {
            callback = nil
            canceled = true
        }
    }

    static let isSetup: Bool = {
        URLSessionAPI.defaultURLSession = MockURLSession()
        URLSessionAPI.cachingURLSession = MockURLSession()
        URLSessionAPI.delegateURLSession = { _, _ in MockURLSession() }
        NoFollowRedirect.session = MockURLSession()
        AppEnvironment.shared.api = URLSessionAPI(accessToken: nil, actAsUserID: nil, baseURL: nil, urlSession: MockURLSession())
        return true
    }()

    public static func reset() {
        guard isSetup else {
            fatalError("MockURLSession failed to setup correctly")
        }
        dataMocks = [:]
    }

    public static func mock<R: APIRequestable>(
        _ requestable: R,
        value: R.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!
    ) {
        var data: Data?
        if let value = value {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            data = try! encoder.encode(value)
        }
        mock(requestable, data: data, response: response, error: error, baseURL: baseURL)
    }

    public static func mock<R: APIRequestable>(
        _ requestable: R,
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!
        ) {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: nil, actAsUserID: nil)
        let task = MockDataTask()
        task.mock = MockData(data: data, response: response, error: error)
        MockURLSession.dataMocks[request] = task
    }

    public static func mockDataTask<R: APIRequestable>(
        _ requestable: R,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!
    ) -> MockDataTask? {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: nil, actAsUserID: nil)
        return dataMocks[request]
    }

    public override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSession.dataMocks[request] ?? MockDataTask()
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        task.callback = completionHandler
        return task
    }
}
