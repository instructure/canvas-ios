//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import Foundation
import Core

public class MockAPI: API {
    public var baseURL = URL(string: "https://cgnuonline-eniversity.edu")!
    public var accessToken: String? = "fhwdgads"
    public var actAsUserID: String?

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
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            data = try! encoder.encode(value)
        }
        mocks[request] = (data, response, error)
    }

    public func mock<R: APIRequestable>(_ requestable: R, data: Data, response: URLResponse? = nil, error: Error? = nil) {
        let request = try! requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
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
                value = try? requestable.decode(data)
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

    public func uploadTask<R>(_ requestable: R) throws -> URLSessionTask where R: APIRequestable {
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
