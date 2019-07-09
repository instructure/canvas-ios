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
    public static var dataMocks: [URLRequest: MockDataTask] = [:]

    public struct MockData {
        public let data: Data?
        public let response: URLResponse?
        public let error: Error?
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
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        accessToken: String? = nil,
        taskID: Int = 0
    ) {
        var data: Data?
        if let value = value {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            data = try! encoder.encode(value)
        }
        mock(requestable, data: data, response: response, error: error, baseURL: baseURL, accessToken: accessToken, taskID: taskID)
    }

    public static func mock<R: APIRequestable>(
        _ requestable: R,
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        accessToken: String? = nil,
        taskID: Int = 0
    ) {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil)
        let task = MockDataTask()
        task.mock = MockData(data: data, response: response, error: error)
        task.taskIdentifier = taskID
        MockURLSession.dataMocks[request] = task
    }

    public static func mockDataTask<R: APIRequestable>(
        _ requestable: R,
        baseURL: URL = URL(string: "https://canvas.instructure.com")!,
        accessToken: String? = nil
    ) -> MockDataTask? {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil)
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

    public override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        let task = MockURLSession.dataMocks[request] ?? MockDataTask()
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        return task
    }

    public override func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        let task = MockURLSession.dataMocks[request] ?? MockDataTask()
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
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
