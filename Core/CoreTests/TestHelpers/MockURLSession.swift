//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class MockURLProtocolSupport: URLProtocol {

    enum ResponseType {
        case error(NSError)
        case success(URLResponse, Any?)
    }

    internal static var lastRequest: URLRequest?
    static var responses = [ResponseType]()

    lazy var session: Foundation.URLSession = {
        let configuration: URLSessionConfiguration = {
            let configuration = URLSessionConfiguration.ephemeral
            return configuration
        }()

        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()

    var activeTask: URLSessionTask?

    // MARK: Class Request Methods

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override class func requestIsCacheEquivalent(_ obj1: URLRequest, to obj2: URLRequest) -> Bool {
        return false
    }

    // MARK: - Loading Methods

    override func startLoading() {

        if let responsType = type(of: self).responses.first {
            switch (responsType) {
            case let ResponseType.error(error):
                client?.urlProtocol(self, didFailWithError: error)
            case let ResponseType.success(response, responseData):
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let responseData = responseData {
                    let data = type(of: self).serializeData(responseData)
                    client?.urlProtocol(self, didLoad: data)
                }
            }
            type(of: self).responses.remove(at: 0)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {
        activeTask?.cancel()
    }
}

extension MockURLProtocolSupport: URLSessionDelegate {

    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        MockURLProtocolSupport.lastRequest = task.currentRequest
        if let responsType = type(of: self).responses.first {
            switch (responsType) {
            case let ResponseType.error(error):
                client?.urlProtocol(self, didFailWithError: error)
            case let ResponseType.success(response, responseData):
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let responseData = responseData {
                    let data = type(of: self).serializeData(responseData)
                    client?.urlProtocol(self, didLoad: data)
                }
            }
            type(of: self).responses.remove(at: 0)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
}

extension MockURLProtocolSupport {
    static func responseWithFailure(code: Int = NSURLErrorFileDoesNotExist) -> ResponseType {
        return ResponseType.error(NSError(domain: NSURLErrorDomain, code: code, userInfo: nil))
    }

    static func responseWithStatusCode(_ code: Int, responseData: Any? = nil) -> ResponseType {
        let URL = Foundation.URL(string: "http://localhost")!
        return ResponseType.success(HTTPURLResponse.init(url: URL, statusCode: code, httpVersion: nil, headerFields: nil)!, responseData)
    }

    static func clearResponseQueue() {
        MockURLProtocolSupport.responses = [ResponseType]()
    }

    static func serializeData(_ data: Any) -> Data {
        if let str = data as? String {
            return str.data(using: .utf8)!
        } else if let dict = data as? [String: Any] {
            do {
                return try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            } catch {}
        } else if let data = data as? Data {
            return data
        }
        return Data()
    }

    class func mockSessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocolSupport.self]
        return config
    }
}

extension URLSession {
    static func mockSession() -> URLSession {
        let config = MockURLProtocolSupport.mockSessionConfiguration()
        let session = URLSession(configuration: config)
        return session
    }
}
