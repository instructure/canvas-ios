//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Core

public class MockURLSession: URLSession {
    public static var dataMocks: [String: MockDataTask] = [:]
    public static var downloadMocks: [String: MockDownloadTask] = [:]

    public typealias MockData = MockResponse<Data>
    public typealias MockDownload = MockResponse<URL>

    public struct MockResponse<T> {
        public let data: T?
        public let response: URLResponse?
        public let error: Error?

        public init(data: T?, response: URLResponse?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
    }

    public class MockDataTask: URLSessionUploadTask {
        public var callback: ((Data?, URLResponse?, Error?) -> Void)?

        private var id: Int = 0
        public override var taskIdentifier: Int {
            get { return id }
            set { id = newValue }
        }

        private var desc: String?
        public override var taskDescription: String? {
            get { return desc }
            set { desc = newValue }
        }

        public override var response: URLResponse? {
            return mock?.response
        }

        public var mock: MockData?
        public var resumed = false
        public var canceled = false

        public var paused = false {
            didSet {
                if !paused && state == .running {
                    resume()
                }
            }
        }

        public var _state: URLSessionTask.State = .suspended
        public override var state: URLSessionTask.State {
            return _state
        }

        public override func resume() {
            _state = .running
            resumed = true
            if paused {
                return
            }
            callback?(mock?.data, mock?.response, mock?.error)
            _state = .completed
        }

        public override func cancel() {
            callback = nil
            canceled = true
        }
    }

    public class MockDownloadTask: URLSessionDownloadTask {
        public var callback: ((URL?, URLResponse?, Error?) -> Void)?

        private var id: Int = 0
        public override var taskIdentifier: Int {
            get { return id }
            set { id = newValue }
        }

        private var desc: String?
        public override var taskDescription: String? {
            get { return desc }
            set { desc = newValue }
        }

        public override var response: URLResponse? {
            return mock?.response
        }

        public var mock: MockDownload?
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

    public static func reset() {
        URLSessionAPI.defaultURLSession = MockURLSession()
        URLSessionAPI.cachingURLSession = MockURLSession()
        URLSessionAPI.delegateURLSession = { _, _, _ in MockURLSession() }
        URLSessionAPI.noFollowRedirectURLSession = MockURLSession()
        AppEnvironment.shared.api = URLSessionAPI(loginSession: nil, urlSession: MockURLSession())
        dataMocks = [:]
    }

    @discardableResult
    public static func mock<R: APIRequestable>(
        _ requestable: R,
        value: R.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        accessToken: String? = nil,
        taskID: Int = 0
    ) -> MockDataTask {
        var data: Data?
        if let value = value {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            data = try! encoder.encode(value)
        }
        return mock(requestable, data: data, response: response, error: error, baseURL: baseURL, accessToken: accessToken, taskID: taskID)
    }

    @discardableResult
    public static func mock<R: APIRequestable>(
        _ requestable: R,
        response: URLResponse? = nil,
        error: Error?,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        accessToken: String? = nil,
        taskID: Int = 0
    ) -> MockDataTask {
        return mock(requestable, value: nil, response: response, error: error, baseURL: baseURL, accessToken: accessToken, taskID: taskID)
    }

    @discardableResult
    public static func mock<R: APIRequestable>(
        _ requestable: R,
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        accessToken: String? = nil,
        taskID: Int = 0
    ) -> MockDataTask {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil)
        return mock(request, data: data, response: response, error: error, taskID: taskID)
    }

    @discardableResult
    public static func mock(_ request: URLRequest, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, taskID: Int = 0) -> MockDataTask {
        let task = MockDataTask()
        task.mock = MockData(data: data, response: response, error: error)
        task.taskIdentifier = taskID
        MockURLSession.dataMocks[request.url!.absoluteString] = task
        return task
    }

    @discardableResult
    public static func mock<S, U>(
        _ store: S,
        value: U.Request.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> MockDataTask where S: Store<U>, U: APIUseCase {
        return mock(store.useCase, value: value, response: response, error: error)
    }

    @discardableResult
    public static func mock<U>(
        _ useCase: U,
        value: U.Request.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> MockDataTask where U: APIUseCase {
        return mock(useCase.request, value: value, response: response, error: error)
    }

    public static func mockDataTask<R: APIRequestable>(
        _ requestable: R,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        accessToken: String? = nil
    ) -> MockDataTask? {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil)
        return dataMocks[request.url!.absoluteString]
    }

    @discardableResult
    public static func mockDownload(_ url: URL, value: URL? = nil, response: URLResponse? = nil, error: Error? = nil) -> MockDownloadTask {
        let request = URLRequest(url: url)
        let task = MockDownloadTask()
        task.mock = MockDownload(data: value, response: response, error: error)
        MockURLSession.downloadMocks[request.url!.absoluteString] = task
        return task
    }

    public override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSession.dataMocks[request.url!.absoluteString] ?? MockDataTask()
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        task.callback = completionHandler
        return task
    }

    public override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        let task = MockURLSession.dataMocks[request.url!.absoluteString] ?? MockDataTask()
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        return task
    }

    public override func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        let task = MockURLSession.dataMocks[request.url!.absoluteString] ?? MockDataTask()
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        return task
    }

    public override func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        let task = MockURLSession.downloadMocks[request.url!.absoluteString] ?? MockDownloadTask()
        if task.mock == nil {
            print("⚠️ download mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        task.callback = completionHandler
        return task
    }

    public override func getAllTasks(completionHandler: @escaping ([URLSessionTask]) -> Void) {
        let tasks = MockURLSession.dataMocks.values.map { $0 }
        completionHandler(tasks)
    }

    public var finishedTasksAndInvalidated: Bool = false
    public override func finishTasksAndInvalidate() {
        finishedTasksAndInvalidated = true
    }

    public var config: URLSessionConfiguration = .default
    public override var configuration: URLSessionConfiguration {
        return config
    }
}
