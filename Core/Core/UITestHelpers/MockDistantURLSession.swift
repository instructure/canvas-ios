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

    static let defaultURLSession = URLSessionAPI.defaultURLSession
    static let cachingURLSession = URLSessionAPI.cachingURLSession
    static let delegateURLSession = URLSessionAPI.delegateURLSession
    static let noFollowRedirectSession = URLSessionAPI.noFollowRedirectURLSession
    static let api = AppEnvironment.shared.api

    @objc public static var isSetup: Bool {
        return URLSessionAPI.defaultURLSession is MockDistantURLSession
    }

    static func setup() {
        guard !isSetup else { return }
        let session = MockDistantURLSession()
        URLSessionAPI.defaultURLSession = session
        URLSessionAPI.cachingURLSession = session
        URLSessionAPI.noFollowRedirectURLSession = session
        URLSessionAPI.delegateURLSession = { config, delegate, queue in
            let session = MockDistantURLSession()
            session.mockConfiguration = config
            session.mockDelegate = delegate
            return session
        }
        AppEnvironment.shared.api = URLSessionAPI()
    }

    static func reset() {
        URLSessionAPI.defaultURLSession = defaultURLSession
        URLSessionAPI.cachingURLSession = cachingURLSession
        URLSessionAPI.delegateURLSession = delegateURLSession
        URLSessionAPI.noFollowRedirectURLSession = noFollowRedirectSession
        AppEnvironment.shared.api = api

        dataMocks = [:]
        downloadMocks = [:]
    }

    private var mockConfiguration: URLSessionConfiguration?
    private weak var mockDelegate: URLSessionDelegate?

    public override var configuration: URLSessionConfiguration {
        return mockConfiguration ?? super.configuration
    }

    // MARK: data
    struct MockData {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let noCallback: Bool
    }
    static var dataMocks: [URL: MockData] = [:]
    static func mockData(_ message: MockDataMessage) {
        setup()
        var response = message.response?.http
        if response == nil, message.data != nil {
            response = HTTPURLResponse(url: message.request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [
                HttpHeader.contentType: "application/json",
            ])
        }
        dataMocks[message.request.url!.withCanonicalQueryParams!] = MockData(
            data: message.data,
            response: response,
            error: message.error.flatMap { NSError.instructureError($0) },
            noCallback: message.noCallback
        )
    }
    class MockDataTask: URLSessionDataTask {
        let completionHandler: DataHandler?
        weak var session: MockDistantURLSession?
        let url: URL

        init(url: URL, session: MockDistantURLSession?, completionHandler: DataHandler?) {
            self.completionHandler = completionHandler
            self.session = session
            self.url = url.withCanonicalQueryParams!
        }

        var _taskDescription: String?
        override var taskDescription: String? {
            get { return _taskDescription }
            set { _taskDescription = newValue }
        }

        var _taskIdentifier: Int = Int.random(in: Int.min...Int.max)
        override var taskIdentifier: Int {
            get { return _taskIdentifier }
            set { _taskIdentifier = newValue }
        }

        public override var response: URLResponse? {
            return MockDistantURLSession.dataMocks[url]?.response
        }

        override func resume() {
            guard let session = session else { return }
            self.session = nil
            let mock = MockDistantURLSession.dataMocks[url]
            if mock == nil {
                var failReason = "data mock not found for url: \(url.absoluteString)\n"
                for key in MockDistantURLSession.dataMocks.keys {
                    failReason += "  \(key.absoluteString)\n"
                }
                UITestHelpers.shared?.send(.mockNotFound(reason: failReason))
            }
            guard mock?.noCallback != true else { return }
            if let completionHandler = completionHandler {
                return completionHandler(mock?.data, mock?.response, mock?.error)
            }
            if let delegate = session.mockDelegate as? URLSessionDataDelegate, let data = mock?.data {
                delegate.urlSession?(session, dataTask: self, didReceive: data)
            }
            if let delegate = session.mockDelegate as? URLSessionTaskDelegate {
                delegate.urlSession?(session, task: self, didCompleteWithError: mock?.error)
            }
            session.mockDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        }

        override func cancel() {
            self.session = nil
        }
    }
    @objc public dynamic override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        return dataTask(with: request.url!)
    }
    @objc public dynamic override func dataTask(with request: URLRequest, completionHandler: @escaping DataHandler) -> URLSessionDataTask {
        return dataTask(with: request.url!, completionHandler: completionHandler)
    }
    @objc public dynamic override func dataTask(with url: URL) -> URLSessionDataTask {
        return dataTask(with: url, completionHandler: { _, _, _ in })
    }
    @objc public dynamic override func dataTask(with url: URL, completionHandler: @escaping DataHandler) -> URLSessionDataTask {
        if url.scheme == "file" {
            return URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        }
        return MockDataTask(url: url, session: self, completionHandler: completionHandler)
    }

    // MARK: download
    struct MockDownload {
        let url: URL?
        let response: URLResponse?
        let error: Error?
    }
    static var downloadMocks: [URL: MockDownload] = [:]
    static func mockDownload(_ message: MockDownloadMessage) {
        setup()
        var url: URL?
        if let data = message.data {
            url = URL.temporaryDirectory.appendingPathComponent(UUID.string)
            try? data.write(to: url!)
        }
        downloadMocks[message.url.withCanonicalQueryParams!] = MockDownload(
            url: url,
            response: message.response?.http,
            error: message.error.flatMap { NSError.instructureError($0) }
        )
    }
    class MockDownloadTask: URLSessionDownloadTask {
        let completionHandler: URLHandler?
        weak var session: MockDistantURLSession?
        let url: URL

        init(url: URL, session: MockDistantURLSession?, completionHandler: URLHandler?) {
            self.completionHandler = completionHandler
            self.session = session
            self.url = url.withCanonicalQueryParams!
        }

        var _taskDescription: String?
        override var taskDescription: String? {
            get { return _taskDescription }
            set { _taskDescription = newValue }
        }

        var _taskIdentifier: Int = Int.random(in: Int.min...Int.max)
        override var taskIdentifier: Int {
            get { return _taskIdentifier }
            set { _taskIdentifier = newValue }
        }

        public override var response: URLResponse? {
            return MockDistantURLSession.downloadMocks[url]?.response
        }

        override func resume() {
            guard let session = session else { return }
            self.session = nil
            let mock = MockDistantURLSession.downloadMocks[url]
            if mock == nil {
                var failReason = "download mock not found for url: \(url.absoluteString)\n"
                for key in MockDistantURLSession.downloadMocks.keys {
                    failReason += "  \(key.absoluteString)\n"
                }
                UITestHelpers.shared?.send(.mockNotFound(reason: failReason))
            }
            if let completionHandler = completionHandler {
                return completionHandler(mock?.url, mock?.response, mock?.error)
            }
            if let delegate = session.mockDelegate as? URLSessionDownloadDelegate, let url = mock?.url {
                delegate.urlSession(session, downloadTask: self, didFinishDownloadingTo: url)
            }
            if let delegate = session.mockDelegate as? URLSessionTaskDelegate {
                delegate.urlSession?(session, task: self, didCompleteWithError: mock?.error)
            }
            session.mockDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        }

        override func cancel() {
            self.session = nil
        }
    }
    @objc public dynamic override func downloadTask(with request: URLRequest) -> URLSessionDownloadTask {
        return downloadTask(with: request.url!)
    }
    @objc public dynamic override func downloadTask(with request: URLRequest, completionHandler: @escaping URLHandler) -> URLSessionDownloadTask {
        return downloadTask(with: request.url!, completionHandler: completionHandler)
    }
    @objc public dynamic override func downloadTask(with url: URL) -> URLSessionDownloadTask {
        return MockDownloadTask(url: url, session: self, completionHandler: nil)
    }
    @objc public dynamic override func downloadTask(with url: URL, completionHandler: @escaping URLHandler) -> URLSessionDownloadTask {
        return MockDownloadTask(url: url, session: self, completionHandler: completionHandler)
    }

    // MARK: upload
    class MockUploadTask: URLSessionUploadTask {
        let bodyData: Data?
        let completionHandler: DataHandler?
        let fileURL: URL?
        let request: URLRequest
        weak var session: MockDistantURLSession?

        init(bodyData: Data? = nil, fileURL: URL? = nil, request: URLRequest, session: MockDistantURLSession?, completionHandler: DataHandler?) {
            self.bodyData = bodyData
            self.completionHandler = completionHandler
            self.fileURL = fileURL
            self.request = request
            self.session = session
        }

        var _taskDescription: String?
        override var taskDescription: String? {
            get { return _taskDescription }
            set { _taskDescription = newValue }
        }

        var _taskIdentifier: Int = Int.random(in: Int.min...Int.max)
        override var taskIdentifier: Int {
            get { return _taskIdentifier }
            set { _taskIdentifier = newValue }
        }

        public override var response: URLResponse? {
            return MockDistantURLSession.dataMocks[request.url!]?.response
        }

        override func resume() {
            guard let session = session else { return }
            self.session = nil
            let mock = MockDistantURLSession.dataMocks[request.url!]
            if mock == nil {
                var failReason = "upload mock not found for url: \(request.url!.absoluteString)\n"
                for key in MockDistantURLSession.dataMocks.keys {
                    failReason += "  \(key.absoluteString)\n"
                }
                UITestHelpers.shared?.send(.mockNotFound(reason: failReason))
            }
            guard mock?.noCallback != true else { return }
            if let completionHandler = completionHandler {
                return completionHandler(mock?.data, mock?.response, mock?.error)
            }
            if let delegate = session.mockDelegate as? URLSessionDataDelegate, let data = mock?.data {
                delegate.urlSession?(session, dataTask: self, didReceive: data)
            }
            if let delegate = session.mockDelegate as? URLSessionTaskDelegate {
                delegate.urlSession?(session, task: self, didCompleteWithError: mock?.error)
            }
            session.mockDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        }

        override func cancel() {
            self.session = nil
        }
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        return MockUploadTask(fileURL: fileURL, request: request, session: self, completionHandler: nil)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping DataHandler) -> URLSessionUploadTask {
        return MockUploadTask(fileURL: fileURL, request: request, session: self, completionHandler: completionHandler)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, from bodyData: Data?) -> URLSessionUploadTask {
        return MockUploadTask(bodyData: bodyData, request: request, session: self, completionHandler: nil)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping DataHandler) -> URLSessionUploadTask {
        return MockUploadTask(bodyData: bodyData, request: request, session: self, completionHandler: completionHandler)
    }

    @objc public dynamic override func finishTasksAndInvalidate() {}
}

#endif
