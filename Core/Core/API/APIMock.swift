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

#if DEBUG

import Foundation

extension API {
    private static var isMocked = false
    static var mocks: [String: APIMock] = [:]
    static var tasks = NSHashTable<MockAPITask>.weakObjects()

    static func resetMocks(useMocks: Bool = true) {
        isMocked = useMocks
        mocks = [:]
        for task in tasks.allObjects {
            task.cancel()
        }
    }

    static func shouldMock(_ request: URLRequest) -> Bool {
        return isMocked && (
            UITestHelpers.shared == nil ||
            request.url?.scheme?.hasPrefix("http") == true ||
            mocks[request.key] != nil
        )
    }

    @discardableResult
    func mock<S: Store<U>, U: APIUseCase>(
        _ store: S,
        value: U.Request.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> APIMock {
        mock(store.useCase, value: value, response: response, error: error)
    }

    @discardableResult
    func mock<U: APIUseCase>(
        _ useCase: U,
        value: U.Request.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> APIMock {
        mock(useCase.request, value: value, response: response, error: error)
    }

    @discardableResult
    func mock<Request: APIRequestable>(
        _ request: Request,
        value: Request.Response? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> APIMock {
        mock(request) { _ in (value, response, error) }
    }

    @discardableResult
    func mock<Request: APIRequestable>(
        _ request: Request,
        dataHandler: @escaping (URLRequest) -> (Request.Response?, URLResponse?, Error?)
    ) -> APIMock {
        // swiftlint:disable:next force_try
        let req = try! request.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: loginSession?.actAsUserID)
        let mock = APIMock { req in
            let (value, response, error) = dataHandler(req)
            return (value.flatMap { try? request.encode(response: $0) }, response, error)
        }
        API.mocks[req.key] = mock
        return mock
    }

    @discardableResult
    func mock<Request: APIRequestable>(
        withData request: Request,
        dataHandler: @escaping (URLRequest) -> (Data?, URLResponse?, Error?)
    ) -> APIMock {
        // swiftlint:disable:next force_try
        let request = try! request.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: nil)
        let mock = APIMock(handler: dataHandler)
        API.mocks[request.key] = mock
        return mock
    }

    @discardableResult
    func mock<Request: APIRequestable>(
        _ request: Request,
        data: Data?,
        response: URLResponse? = nil,
        error: Error? = nil
    ) -> APIMock {
        // swiftlint:disable:next force_try
        let request = try! request.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: nil)
        let mock = APIMock { _ in (data, response, error) }
        API.mocks[request.key] = mock
        return mock
    }

    @discardableResult
    func mock(url: URL, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) -> APIMock {
        // swiftlint:disable:next force_try
        let request = try! url.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: nil)
        let mock = APIMock { _ in (data, response, error) }
        API.mocks[request.key] = mock
        return mock
    }

    @discardableResult
    func mockDownload(_ url: URL, value: URL? = nil, response: URLResponse? = nil, error: Error? = nil) -> APIMock {
        let request = URLRequest(url: url)
        let mock = APIMock { _ in (value?.absoluteString.data(using: .utf8), response, error) }
        API.mocks[request.key] = mock
        return mock
    }
}

class MockAPITask: APITask {
    let api: API
    let callback: ((Data?, URLResponse?, Error?) -> Void)?
    let request: URLRequest
    var state: URLSessionTask.State = .suspended
    var taskID: String?
    var isDownload: Bool

    init(_ api: API, request: URLRequest, callback: ((Data?, URLResponse?, Error?) -> Void)? = nil) {
        self.api = api
        self.callback = callback
        self.request = request
        self.isDownload = false
    }

    init(_ api: API, request: URLRequest, callback: ((URL?, URLResponse?, Error?) -> Void)?) {
        self.api = api
        self.callback = callback.map { callback in { data, response, error in
            let url = data.flatMap { String(data: $0, encoding: .utf8) } .flatMap { URL(string: $0) }
            callback(url, response, error)
        } }
        self.request = request
        self.isDownload = true
    }

    func cancel() {
        guard state == .suspended || state == .running else { return }
        state = .canceling
    }

    func resume() {
        guard state == .suspended else { return }
        state = .running
        if let helpers = UITestHelpers.shared {
            API.tasks.add(self)
            print("✉️ \(request.key)")
            return helpers.send(.urlRequest(request)) {
                APIMock.handle(self, ipc: $0)
            }
        }
        let mock = API.mocks[request.key] ?? {
            print("⚠️ \(request.key) mock not found")
            return APIMock { _ in (nil, nil, nil) }
        }()
        mock.handle(self)
    }
}

extension URLRequest {
    var key: String { url?.withCanonicalQueryParams?.absoluteString ?? "" }
}

class APIMock {
    let handler: (URLRequest) -> (Data?, URLResponse?, Error?)
    private(set) var isSuspended = false
    var queue: [MockAPITask] = []

    init(handler: @escaping (URLRequest) -> (Data?, URLResponse?, Error?)) {
        self.handler = handler
    }

    /**
     Suspends completing the API task until `resume()` is called. Good to test slow responses.
     */
    func suspend() {
        isSuspended = true
    }

    func resume() {
        isSuspended = false
        for task in queue { handle(task) }
        queue = []
    }

    func handle(_ task: MockAPITask) {
        guard !isSuspended else {
            queue.append(task)
            return
        }

        let (value, response, error) = handler(task.request)
        task.callback?(value, response, error)
    }

    // MARK: Mock delegate methods

    func forEachDownload(_ run: (URLSession, URLSessionDownloadDelegate?, URLSessionDownloadTask) -> Void) {
        for task in queue where task.callback == nil {
            let urlSession = task.api.urlSession
            run(urlSession, urlSession.delegate as? URLSessionDownloadDelegate, urlSession.downloadTask(with: task.request))
        }
    }

    func forEachTask(_ run: (URLSession, URLSessionTaskDelegate?, URLSessionDataTask) -> Void) {
        for task in queue where task.callback == nil {
            let urlSession = task.api.urlSession
            run(urlSession, urlSession.delegate as? URLSessionTaskDelegate, urlSession.dataTask(with: task.request))
        }
    }

    func download(didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        forEachDownload { session, delegate, task in
            delegate?.urlSession?(session, downloadTask: task, didWriteData: bytesWritten,
                totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite
            )
        }
    }

    func download(didFinishDownloadingTo location: URL) {
        forEachDownload { session, delegate, task in
            delegate?.urlSession(session, downloadTask: task, didFinishDownloadingTo: location)
        }
    }

    func complete(withError error: Error?) {
        forEachTask { session, delegate, task in
            delegate?.urlSession?(session, task: task, didCompleteWithError: error)
        }
        resume()
        suspend()
    }

    // MARK: Handle response from IPC-based mocks

    static func handle(_ task: MockAPITask, ipc: Data?) {
        let mock = ipc.flatMap { try? JSONDecoder().decode(MockHTTPResponse.self, from: $0) } ?? MockHTTPResponse()
        if mock.data != nil || mock.http != nil || mock.error != nil {
            print("💌 \(task.request.key)")
        } else {
            print("⚠️ mocked response not set for \(task.request.key)")
        }
        guard !mock.noCallback, task.state == .running else { return }

        if let callback = task.callback {
            let data = task.isDownload ? mock.dataSavedToTemporaryFileURL?.absoluteString.data(using: .utf8) : mock.data
            return callback(data, mock.http, mock.error)
        }

        let session = task.api.urlSession
        let dataTask = session.dataTask(with: task.request)
        dataTask.taskID = task.taskID
        if let delegate = session.delegate as? URLSessionDataDelegate, let data = mock.data {
            delegate.urlSession?(session, dataTask: dataTask, didReceive: data)
        }
        if task.isDownload, let delegate = session.delegate as? URLSessionDownloadDelegate,
            let url = mock.dataSavedToTemporaryFileURL {
            let downloadTask = session.downloadTask(with: task.request)
            delegate.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: url)
        }
        if let delegate = session.delegate as? URLSessionTaskDelegate {
            delegate.urlSession?(session, task: dataTask, didCompleteWithError: mock.error)
        }
        if session.configuration.identifier != nil {
            session.delegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        }
    }
}

#endif
