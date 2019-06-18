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

#if DEBUG

import Foundation

@objc
class MockDistantURLSession: URLSession {
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
    @objc static func mockData(_ data: Data) {
        guard isSetup else {
            fatalError("Mock URLSession failed to setup correctly")
        }
        guard let message = try? JSONDecoder().decode(MockDataMessage.self, from: data) else {
            fatalError("Could not decode mocking request")
        }
        dataMocks[message.request.url!] = MockData(
            data: message.data,
            response: message.response?.http,
            error: message.error.flatMap { NSError.instructureError($0) },
            noCallback: message.noCallback
        )
    }
    @objc dynamic override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockDataTask()
        task.mock = MockDistantURLSession.dataMocks[request.url!]
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        task.callback = completionHandler
        return task
    }
    @objc dynamic override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
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
    @objc static func mockDownload(_ data: Data) {
        guard isSetup else {
            fatalError("Mock URLSession failed to setup correctly")
        }
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
    @objc dynamic override func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
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
    @objc dynamic override func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        let task = MockUploadTask(request: request, fileURL: fileURL)
        MockDistantURLSession.uploadMocks[request.url!] = task
        return task
    }

    @objc static func reset() {
        dataMocks = [:]
        downloadMocks = [:]
        uploadMocks = [:]
    }

    static let isSetup: Bool = {
        URLSessionAPI.defaultURLSession = MockDistantURLSession()
        URLSessionAPI.cachingURLSession = MockDistantURLSession()
        URLSessionAPI.delegateURLSession = { _, _ in MockDistantURLSession() }
        NoFollowRedirect.session = MockDistantURLSession()
        AppEnvironment.shared.api = URLSessionAPI()
        return true
    }()
}

#endif
