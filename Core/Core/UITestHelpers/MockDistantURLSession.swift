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
        URLSessionAPI.delegateURLSession = { config, delegate, queue in session }
        URLSessionAPI.noFollowRedirectURLSession = session
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
        uploadMocks = [:]
    }

    // MARK: data
    struct MockData {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let noCallback: Bool
    }
    class MockDataTask: URLSessionDataTask {
        var callback: ((Data?, URLResponse?, Error?) -> Void)?
        var mock: MockData?
        override func resume() {
            if mock?.noCallback != true {
                callback?(mock?.data, mock?.response, mock?.error)
            }
            callback = nil
        }
        override func cancel() {
            callback = nil
        }
    }
    static var dataMocks: [URL: MockData] = [:]
    static func mockData(_ data: Data) {
        setup()
        guard let message = try? JSONDecoder().decode(MockDataMessage.self, from: data) else {
            fatalError("Could not decode mocking request")
        }
        var response = message.response?.http
        if response == nil, message.data != nil {
            response = HTTPURLResponse(url: message.request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [
                HttpHeader.contentType: "application/json",
            ])
        }
        dataMocks[message.request.url!] = MockData(
            data: message.data,
            response: response,
            error: message.error.flatMap { NSError.instructureError($0) },
            noCallback: message.noCallback
        )
    }
    @objc dynamic override public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockDataTask()
        task.mock = MockDistantURLSession.dataMocks[request.url!]
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
            print(MockDistantURLSession.dataMocks.keys)
        }
        task.callback = completionHandler
        return task
    }
    @objc dynamic override public func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockDataTask()
        task.mock = MockDistantURLSession.dataMocks[url]
        if task.mock == nil {
            print("⚠️ mock not found for url: \(url.absoluteString)")
        }
        task.callback = completionHandler
        return task
    }

    // MARK: download
    struct MockDownload {
        let url: URL?
        let response: URLResponse?
        let error: Error?
    }
    class MockDownloadTask: URLSessionDownloadTask {
        var handler: (() -> Void)?
        override func resume() {
            handler?()
            handler = nil
        }
        override func cancel() {
            handler = nil
        }
    }
    static var downloadMocks: [URL: MockDownload] = [:]
    static func mockDownload(_ data: Data) {
        setup()
        guard let message = try? JSONDecoder().decode(MockDownloadMessage.self, from: data) else {
            fatalError("Could not decode mocking request")
        }
        var url: URL?
        if let data = message.data {
            url = URL.temporaryDirectory.appendingPathComponent(UUID.string)
            try? data.write(to: url!)
        }
        downloadMocks[message.url] = MockDownload(
            url: url,
            response: message.response?.http,
            error: message.error.flatMap { NSError.instructureError($0) }
        )
    }
    @objc dynamic override public func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        let task = MockDownloadTask()
        task.handler = {
            let mock = MockDistantURLSession.downloadMocks[request.url!]
            completionHandler(mock?.url, mock?.response, mock?.error)
        }
        return task
    }

    // MARK: upload
    class MockUploadTask: URLSessionUploadTask {
        let request: URLRequest
        let fileURL: URL
        init(request: URLRequest, fileURL: URL) {
            self.request = request
            self.fileURL = fileURL
        }
        override func resume() {}
        override func cancel() {}
    }
    static var uploadMocks: [URL: MockUploadTask] = [:]
    @objc dynamic override public func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        let task = MockUploadTask(request: request, fileURL: fileURL)
        MockDistantURLSession.uploadMocks[request.url!] = task
        return task
    }
}

#endif
