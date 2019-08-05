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

public protocol API {
    var accessToken: String? { get }
    var baseURL: URL { get }
    var actAsUserID: String? { get }

    var identifier: String? { get }

    @discardableResult
    func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask?

    @discardableResult
    func makeDownloadRequest(_ url: URL, callback: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTask?

    @discardableResult
    func uploadTask<R: APIRequestable>(_ requestable: R) throws -> URLSessionTask
}

public struct URLSessionAPI: API {
    public let accessToken: String?
    public let actAsUserID: String?
    public let baseURL: URL
    let urlSession: URLSession

    public var identifier: String? {
        return urlSession.configuration.identifier
    }

    public static var cachingURLSession = URLSession.shared
    public static var defaultURLSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
    public static var delegateURLSession = { (configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) -> URLSession in
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
    }

    public init(
        accessToken: String? = nil,
        actAsUserID: String? = nil,
        baseURL: URL? = nil,
        urlSession: URLSession = URLSessionAPI.defaultURLSession
    ) {
        self.accessToken = accessToken
        self.actAsUserID = actAsUserID
        self.baseURL = baseURL ?? URL(string: "https://canvas.instructure.com/")!
        self.urlSession = urlSession
    }

    @discardableResult
    public func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        do {
            let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
            let task = urlSession.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil, !(R.Response.self is APINoContent.Type) else {
                    return callback(nil, response, error)
                }
                do {
                    callback(try requestable.decode(data), response, error)
                } catch let error {
                    #if DEBUG
                    print(response ?? "", String(data: data, encoding: .utf8) ?? "", error)
                    #endif
                    callback(nil, response, APIError.from(data: data, response: response, error: error))
                }
            }
            task.resume()
            return task
        } catch let error {
            callback(nil, nil, error)
            return nil
        }
    }

    @discardableResult
    public func makeDownloadRequest(_ url: URL, callback: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let request = URLRequest(url: url)
        let task = urlSession.downloadTask(with: request, completionHandler: callback)
        task.resume()
        return task
    }

    @discardableResult
    public func uploadTask<R: APIRequestable>(_ requestable: R) throws -> URLSessionTask {
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
        let directory = urlSession.configuration.sharedContainerIdentifier.flatMap(URL.sharedContainer) ?? URL.temporaryDirectory
        let url = directory.appendingPathComponent(UUID.string)
        try request.httpBody?.write(to: url)
        #if DEBUG
        print("uploading", url)
        print("to", request.url ?? "")
        #endif
        return urlSession.uploadTask(with: request, fromFile: url)
    }
}

extension URLSession {
    @objc public static func getDefaultURLSession() -> URLSession {
        return URLSessionAPI.defaultURLSession
    }
}
