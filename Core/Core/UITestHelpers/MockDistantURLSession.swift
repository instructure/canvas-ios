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
        URLSessionAPI.defaultURLSession is MockDistantURLSession
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
    }

    private var mockConfiguration: URLSessionConfiguration?
    private weak var mockDelegate: URLSessionDelegate?

    public override var configuration: URLSessionConfiguration {
        mockConfiguration ?? super.configuration
    }

    static let mockRequestQueue = DispatchQueue(label: "mockRequestQueue")

    static func requestMock(_ url: URL, uploadData: Data? = nil) -> MockHTTPResponse {
        mockRequestQueue.sync {
            print("MOCK requesting \(url.absoluteString)")
            guard let responseData = UITestHelpers.shared!.send(.urlRequest(url, uploadData: uploadData)),
                let mock = try? JSONDecoder().decode(MockHTTPResponse.self, from: responseData) else {
                    print("MOCK no mock")
                    return MockHTTPResponse()
            }
            print("MOCK got \(mock)")
            return mock
        }
    }

    // MARK: data
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
            get { _taskDescription }
            set { _taskDescription = newValue }
        }

        var _taskIdentifier: Int = Int.random(in: Int.min...Int.max)
        override var taskIdentifier: Int {
            get { _taskIdentifier }
            set { _taskIdentifier = newValue }
        }

        var _response: URLResponse?
        public override var response: URLResponse? {
            get { _response }
            set { _response = newValue }
        }

        override func resume() {
            let mock = requestMock(url)
            _response = mock.http
            guard let session = session else { return }
            self.session = nil

            if mock.noCallback { return }
            if let completionHandler = completionHandler {
                return completionHandler(mock.data, mock.http, mock.error)
            }
            if let delegate = session.mockDelegate as? URLSessionDataDelegate, let data = mock.data {
                delegate.urlSession?(session, dataTask: self, didReceive: data)
            }
            if let delegate = session.mockDelegate as? URLSessionTaskDelegate {
                delegate.urlSession?(session, task: self, didCompleteWithError: mock.error)
            }
            session.mockDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        }

        override func cancel() {
            self.session = nil
        }
    }
    @objc public dynamic override func dataTask(with request: URLRequest) -> URLSessionDataTask {
        dataTask(with: request.url!)
    }
    @objc public dynamic override func dataTask(with request: URLRequest, completionHandler: @escaping DataHandler) -> URLSessionDataTask {
        dataTask(with: request.url!, completionHandler: completionHandler)
    }
    @objc public dynamic override func dataTask(with url: URL) -> URLSessionDataTask {
        dataTask(with: url, completionHandler: { _, _, _ in })
    }
    @objc public dynamic override func dataTask(with url: URL, completionHandler: @escaping DataHandler) -> URLSessionDataTask {
        if url.scheme?.hasPrefix("http") != false {
            return MockDataTask(url: url, session: self, completionHandler: completionHandler)
        } else {
            return URLSession.shared.dataTask(with: url, completionHandler: completionHandler)
        }
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
            get { _taskDescription }
            set { _taskDescription = newValue }
        }

        var _taskIdentifier: Int = Int.random(in: Int.min...Int.max)
        override var taskIdentifier: Int {
            get { _taskIdentifier }
            set { _taskIdentifier = newValue }
        }

        var _response: URLResponse?
        public override var response: URLResponse? {
            get { _response }
            set { _response = newValue }
        }

        override func resume() {
            let mock = requestMock(url)
            _response = mock.http
            guard let session = session else { return }
            self.session = nil

            var url: URL?
            if let data = mock.data {
                url = URL.temporaryDirectory.appendingPathComponent(Foundation.UUID().uuidString, isDirectory: false)
                try? data.write(to: url!)
            }

            if mock.noCallback { return }
            if let completionHandler = completionHandler {
                return completionHandler(url, mock.http, mock.error)
            }
            if let delegate = session.mockDelegate as? URLSessionDownloadDelegate, let url = url {
                delegate.urlSession(session, downloadTask: self, didFinishDownloadingTo: url)
            }
            if let delegate = session.mockDelegate as? URLSessionTaskDelegate {
                delegate.urlSession?(session, task: self, didCompleteWithError: mock.error)
            }
            session.mockDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        }

        override func cancel() {
            self.session = nil
        }
    }
    @objc public dynamic override func downloadTask(with request: URLRequest) -> URLSessionDownloadTask {
        downloadTask(with: request.url!)
    }
    @objc public dynamic override func downloadTask(with request: URLRequest, completionHandler: @escaping URLHandler) -> URLSessionDownloadTask {
        downloadTask(with: request.url!, completionHandler: completionHandler)
    }
    @objc public dynamic override func downloadTask(with url: URL) -> URLSessionDownloadTask {
        MockDownloadTask(url: url, session: self, completionHandler: nil)
    }
    @objc public dynamic override func downloadTask(with url: URL, completionHandler: @escaping URLHandler) -> URLSessionDownloadTask {
        MockDownloadTask(url: url, session: self, completionHandler: completionHandler)
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
            get { _taskDescription }
            set { _taskDescription = newValue }
        }

        var _taskIdentifier: Int = Int.random(in: Int.min...Int.max)
        override var taskIdentifier: Int {
            get { _taskIdentifier }
            set { _taskIdentifier = newValue }
        }

        var _response: URLResponse?
        public override var response: URLResponse? {
            get { _response }
            set { _response = newValue }
        }

        override func resume() {
            let data = bodyData ?? fileURL.flatMap { try? Data(contentsOf: $0) }
            guard let url = request.url else { return }
            let mock = requestMock(url, uploadData: data)
            _response = mock.http
            guard let session = session else { return }
            self.session = nil

            if mock.noCallback { return }
            if let completionHandler = completionHandler {
                return completionHandler(mock.data, mock.http, mock.error)
            }
            if let delegate = session.mockDelegate as? URLSessionDataDelegate, let data = mock.data {
                delegate.urlSession?(session, dataTask: self, didReceive: data)
            }
            if let delegate = session.mockDelegate as? URLSessionTaskDelegate {
                delegate.urlSession?(session, task: self, didCompleteWithError: mock.error)
            }
            session.mockDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
        }

        override func cancel() {
            self.session = nil
        }
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        MockUploadTask(fileURL: fileURL, request: request, session: self, completionHandler: nil)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, fromFile fileURL: URL, completionHandler: @escaping DataHandler) -> URLSessionUploadTask {
        MockUploadTask(fileURL: fileURL, request: request, session: self, completionHandler: completionHandler)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, from bodyData: Data?) -> URLSessionUploadTask {
        MockUploadTask(bodyData: bodyData, request: request, session: self, completionHandler: nil)
    }
    @objc public dynamic override func uploadTask(with request: URLRequest, from bodyData: Data?, completionHandler: @escaping DataHandler) -> URLSessionUploadTask {
        MockUploadTask(bodyData: bodyData, request: request, session: self, completionHandler: completionHandler)
    }

    @objc public dynamic override func finishTasksAndInvalidate() {}
}

#endif
