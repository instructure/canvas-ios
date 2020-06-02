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

#if DEBUG

import Foundation

public class MockDistantURLSession: URLSession {
    public typealias DataHandler = (Data?, URLResponse?, Error?) -> Void
    public typealias URLHandler = (URL?, URLResponse?, Error?) -> Void

    struct Defaults {
        let defaultURLSession = URLSessionAPI.defaultURLSession
        let cachingURLSession = URLSessionAPI.cachingURLSession
        let delegateURLSession = URLSessionAPI.delegateURLSession
        let noFollowRedirectSession = URLSessionAPI.noFollowRedirectURLSession
        let api = AppEnvironment.shared.api
    }
    static let defaults = Defaults()
    static let mockSessions = NSHashTable<MockDistantURLSession>.weakObjects()

    @objc public static var isSetup: Bool {
        URLSessionAPI.defaultURLSession is MockDistantURLSession
    }

    static func reset(useMocks: Bool) {
        // force initialization of static lazy variable
        _ = defaults
        for session in mockSessions.allObjects {
            session.invalidateAndCancel()
            mockSessions.remove(session)
        }
        if useMocks {
            let session = MockDistantURLSession()
            mockSessions.add(session)
            URLSessionAPI.defaultURLSession = session
            URLSessionAPI.cachingURLSession = session
            URLSessionAPI.noFollowRedirectURLSession = session
            URLSessionAPI.delegateURLSession = { config, delegate, queue in
                let session = MockDistantURLSession()
                mockSessions.add(session)
                session.mockConfiguration = config
                session.mockDelegate = delegate
                return session
            }
            AppEnvironment.shared.api = URLSessionAPI()
        } else {
            URLSessionAPI.defaultURLSession = defaults.defaultURLSession
            URLSessionAPI.cachingURLSession = defaults.cachingURLSession
            URLSessionAPI.delegateURLSession = defaults.delegateURLSession
            URLSessionAPI.noFollowRedirectURLSession = defaults.noFollowRedirectSession
            AppEnvironment.shared.api = defaults.api
        }
    }

    private var mockConfiguration: URLSessionConfiguration?
    private weak var mockDelegate: URLSessionDelegate?
    var inFlightTasks = NSHashTable<URLSessionTask>.weakObjects()

    public override var configuration: URLSessionConfiguration {
        mockConfiguration ?? super.configuration
    }

    func processMockResponse(_ mock: MockHTTPResponse, task: MockSessionTask) {
        guard task.taskData.session != nil else { return }
        inFlightTasks.remove(task)
        task.taskData.response = mock.http
        task.taskData.session = nil

        if mock.noCallback { return }
        switch task.completionHandler {
        case .dataHandler(let dataHandler):
            return dataHandler(mock.data, mock.http, mock.error)
        case .urlHandler(let urlHandler):
            return urlHandler(mock.dataSavedToTemporaryFileURL, mock.http, mock.error)
        default: ()
        }
        if let dataSelf = task as? URLSessionDataTask,
            let delegate = mockDelegate as? URLSessionDataDelegate,
            let data = mock.data {
            delegate.urlSession?(self, dataTask: dataSelf, didReceive: data)
        }
        if let delegate = mockDelegate as? URLSessionTaskDelegate {
            delegate.urlSession?(self, task: task, didCompleteWithError: mock.error)
        }
        if let downloadSelf = task as? URLSessionDownloadTask,
            let delegate = mockDelegate as? URLSessionDownloadDelegate,
            let url = mock.dataSavedToTemporaryFileURL {
            delegate.urlSession(self, downloadTask: downloadSelf, didFinishDownloadingTo: url)
        }
        mockDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: self)
    }

    func resume(task: MockSessionTask) {
        guard valid else { return }
        let request = task.request
        print("\(request.httpMethod ?? "GET") - \(request.url?.absoluteString ?? "nil")")
        UITestHelpers.shared!.send(.urlRequest(request)) { responseData in
            guard self.valid else { return }
            if let data = responseData,
                let mock = try? JSONDecoder().decode(MockHTTPResponse.self, from: data) {
                // print("  \(mock.data.flatMap { String(data: $0, encoding: .utf8) } ?? "<not json>")")
                self.processMockResponse(mock, task: task)
            } else {
                print("No mock response")
                self.processMockResponse(MockHTTPResponse(), task: task)
            }
        }
    }

    internal var valid = true
    public override func invalidateAndCancel() {
        valid = false
        for task in inFlightTasks.allObjects {
            task.cancel()
            inFlightTasks.remove(task)
        }
    }

    // MARK: data
    private typealias MockDataTask = MockUploadTask

    @objc public dynamic override func dataTask(with url: URL) -> URLSessionDataTask {
        dataTask(with: URLRequest(url: url))
    }
    @objc public dynamic override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        dataTask(with: request, completionHandler: { _, _, _ in })
    }
    @objc public dynamic override func dataTask(with url: URL, completionHandler: @escaping DataHandler) -> URLSessionDataTask {
        dataTask(with: URLRequest(url: url), completionHandler: completionHandler)
    }
    @objc public dynamic override func dataTask(with request: URLRequest, completionHandler: @escaping DataHandler) -> URLSessionDataTask {
        if request.url?.scheme?.hasPrefix("http") != false {
            return MockDataTask(request: request, session: self, completionHandler: completionHandler)
        } else {
            return URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        }
    }

    private class MockDownloadTask: URLSessionDownloadTask, MockSessionTask {
        let taskData: MockSessionTaskData

        required init(taskData: MockSessionTaskData) {
            self.taskData = taskData
            super.init()
            taskData.session?.inFlightTasks.add(self)
        }

        override var taskIdentifier: Int { taskData.taskIdentifier }
        override var response: URLResponse? { taskData.response }
        override func resume() { session?.resume(task: self) }
        override func cancel() { taskData.session = nil }
    }

    @objc public dynamic override func downloadTask(with request: URLRequest) -> URLSessionDownloadTask {
        MockDownloadTask(request: request, session: self)
    }
    @objc public dynamic override func downloadTask(with request: URLRequest, completionHandler: @escaping URLHandler) -> URLSessionDownloadTask {
        MockDownloadTask(request: request, session: self, completionHandler: completionHandler)
    }
    @objc public dynamic override func downloadTask(with url: URL) -> URLSessionDownloadTask {
        downloadTask(with: URLRequest(url: url))
    }
    @objc public dynamic override func downloadTask(with url: URL, completionHandler: @escaping URLHandler) -> URLSessionDownloadTask {
        downloadTask(with: URLRequest(url: url), completionHandler: completionHandler)
    }

    // MARK: upload
    private class MockUploadTask: URLSessionUploadTask, MockSessionTask {
        let taskData: MockSessionTaskData
        required init(taskData: MockSessionTaskData) {
            self.taskData = taskData
            super.init()
            taskData.session?.inFlightTasks.add(self)
        }
        private var _taskDescription: String?
        override var taskDescription: String? {
            get { _taskDescription }
            set { _taskDescription = newValue }
        }
        override var taskIdentifier: Int { taskData.taskIdentifier }
        override var response: URLResponse? { taskData.response }
        override func resume() { session?.resume(task: self) }
        override func cancel() { taskData.session = nil }
    }

    @objc public dynamic override func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        var newRequest = request
        newRequest.httpBody = (try? Data(contentsOf: fileURL))!
        return MockUploadTask(request: newRequest, session: self)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping DataHandler) -> URLSessionUploadTask {
        var newRequest = request
        newRequest.httpBody = (try? Data(contentsOf: fileURL))!
        return MockUploadTask(request: request, session: self, completionHandler: completionHandler)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, from bodyData: Data?) -> URLSessionUploadTask {
        var newRequest = request
        newRequest.httpBody = bodyData
        return MockUploadTask(request: newRequest, session: self)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping DataHandler) -> URLSessionUploadTask {
        var newRequest = request
        newRequest.httpBody = bodyData
        return MockUploadTask(request: newRequest, session: self, completionHandler: completionHandler)
    }

    @objc public dynamic override func finishTasksAndInvalidate() {}
}

enum AnyHandler {
    case dataHandler(MockDistantURLSession.DataHandler)
    case urlHandler(MockDistantURLSession.URLHandler)
}

class MockSessionTaskData {
    let completionHandler: AnyHandler?
    weak var session: MockDistantURLSession?
    private(set) var request: URLRequest

    init(request: URLRequest, session: MockDistantURLSession?, completionHandler: AnyHandler?) {
        self.completionHandler = completionHandler
        self.session = session
        self.request = request
        self.request.url = request.url?.withCanonicalQueryParams
    }
    var taskIdentifier: Int = Int.random(in: Int.min...Int.max)
    var response: URLResponse?
}

protocol MockSessionTask: URLSessionTask {
    var taskData: MockSessionTaskData { get }
    init(taskData: MockSessionTaskData)
}

extension MockSessionTask {
    init(request: URLRequest, session: MockDistantURLSession?, completionHandler: MockDistantURLSession.DataHandler?) {
        var canonicalRequest = request
        canonicalRequest.url = request.url?.withCanonicalQueryParams
        self.init(taskData: MockSessionTaskData(
            request: canonicalRequest,
            session: session,
            completionHandler: completionHandler.map { .dataHandler($0) }
        ))
    }

    init(request: URLRequest, session: MockDistantURLSession?, completionHandler: MockDistantURLSession.URLHandler? = nil) {
        var canonicalRequest = request
        canonicalRequest.url = request.url?.withCanonicalQueryParams
        self.init(taskData: MockSessionTaskData(
            request: canonicalRequest,
            session: session,
            completionHandler: completionHandler.map { .urlHandler($0) }
        ))
    }

    var request: URLRequest { taskData.request }
    var session: MockDistantURLSession? { taskData.session }
    var completionHandler: AnyHandler? { taskData.completionHandler }
}

#endif
