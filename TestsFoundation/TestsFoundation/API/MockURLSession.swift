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
        AppEnvironment.shared.api = URLSessionAPI()
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
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: nil, actAsUserID: nil)
        var data: Data?
        if let value = value {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            data = try! encoder.encode(value)
        }
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
