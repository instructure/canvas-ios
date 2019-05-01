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

import Foundation
@testable import Core

@objc
class MockURLSession: URLSession {
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
        task.mock = MockURLSession.dataMocks[request.url!]
        if task.mock == nil {
            print("⚠️ mock not found for url: \(request.url?.absoluteString ?? "<n/a>")")
        }
        task.callback = completionHandler
        return task
    }
    @objc dynamic override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockDataTask()
        task.mock = MockURLSession.dataMocks[url]
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
            let mock = MockURLSession.downloadMocks[request.url!]
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
        MockURLSession.uploadMocks[request.url!] = task
        return task
    }

    @objc static func reset() {
        guard isSetup else {
            fatalError("Mock URLSession failed to setup correctly")
        }
        dataMocks = [:]
        downloadMocks = [:]
        uploadMocks = [:]
    }

    static let isSetup: Bool = {
        URLSessionAPI.defaultURLSession = MockURLSession()
        URLSessionAPI.cachingURLSession = MockURLSession()
        URLSessionAPI.delegateURLSession = { _, _ in MockURLSession() }
        NoFollowRedirect.session = MockURLSession()
        AppEnvironment.shared.api = URLSessionAPI()
        return true
    }()
}
