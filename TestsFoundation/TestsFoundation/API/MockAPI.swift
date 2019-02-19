//
// Copyright (C) 2016-present Instructure, Inc.
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

import Foundation
import Core

public class MockAPI: API {
    public var baseURL = URL(string: "https://cgnuonline-eniversity.edu")!
    public var accessToken: String? = "fhwdgads"
    public var actAsUserID: String? = nil

    public var identifier: String? {
        return "mock-api"
    }

    public init() {}

    //  swiftlint:disable large_tuple
    public var mocks: [URLRequest: (Data?, URLResponse?, Error?)] = [:]
    public var downloadMocks: [URLRequest: (URL?, URLResponse?, Error?)] = [:]
    public var uploadMocks: [URLRequest: MockAPITask] = [:]
    //  swiftlint:enable large_tuple

    public func mock<R: APIRequestable>(_ requestable: R, value: R.Response? = nil, response: URLResponse? = nil, error: Error? = nil) {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
        var data: Data?
        if let value = value {
            data = try! JSONEncoder().encode(value)
        }
        mocks[request] = (data, response, error)
    }

    public func mockDownload(_ url: URL, value: URL? = nil, response: URLResponse? = nil, error: Error? = nil) {
        let request = URLRequest(url: url)
        downloadMocks[request] = (value, response, error)
    }

    @discardableResult
    public func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
        if let (data, response, error) = mocks[request] {
            var value: R.Response?
            if let data = data {
                value = try! JSONDecoder().decode(R.Response.self, from: data)
            }
            callback(value, response, error)
            return nil
        }
        callback(nil, nil, nil)
        return nil
    }

    @discardableResult
    public func makeDownloadRequest(_ url: URL, callback: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let request = URLRequest(url: url)
        if let (url, response, error) = downloadMocks[request] {
            callback(url, response, error)
            return nil
        }
        callback(nil, nil, nil)
        return nil
    }

    public func uploadTask<R>(_ requestable: R, fromFile file: URL) throws -> URLSessionTask where R: APIRequestable {
        let task = MockAPITask(taskIdentifier: uploadMocks.values.count + 1)
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
        uploadMocks[request] = task
        return task
    }
}

public struct MockRequest: APIRequestable {
    public typealias Response = [String]

    public let path: String

    public init(path: String) {
        self.path = path
    }
}

public class MockAPITask: URLSessionDataTask {
    private let _taskIdentifier: Int

    public override var taskIdentifier: Int {
        return _taskIdentifier
    }
    public var resumeCount = 0
    public var cancelCount = 0

    public init(taskIdentifier: Int) {
        self._taskIdentifier = taskIdentifier
    }

    public override func resume() {
        resumeCount += 1
    }

    public override func cancel() {
        cancelCount += 1
    }
}
