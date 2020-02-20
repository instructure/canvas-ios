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
    var loginSession: LoginSession? { get }
    var baseURL: URL { get }

    var identifier: String? { get }

    @discardableResult
    func makeRequest<R: APIRequestable>(_ requestable: R, refreshToken: Bool, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask?

    @discardableResult
    func makeDownloadRequest(_ url: URL, callback: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionTask?

    @discardableResult
    func uploadTask<R: APIRequestable>(_ requestable: R) throws -> URLSessionTask
}

extension API {
    @discardableResult
    public func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        return makeRequest(requestable, refreshToken: true, callback: callback)
    }

    public func exhaust<R>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) where R: APIRequestable, R.Response: RangeReplaceableCollection {
        exhaust(requestable, result: nil, callback: callback)
    }

    private func exhaust<R>(_ requestable: R, result: R.Response?, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) where R: APIRequestable, R.Response: RangeReplaceableCollection {
        makeRequest(requestable) { response, urlResponse, error in
            guard let response = response else {
                callback(nil, urlResponse, error)
                return
            }
            let result = result == nil ? response : result! + response
            if let urlResponse = urlResponse, let next = requestable.getNext(from: urlResponse) {
                self.exhaust(next, result: result, callback: callback)
                return
            }
            callback(result, urlResponse, error)
        }
    }
}

public class URLSessionAPI: API {
    public var loginSession: LoginSession?
    public let baseURL: URL
    public let urlSession: URLSession

    var refreshTask: URLSessionTask?
    var refreshQueue: [() -> Void] = []

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
    public static var noFollowRedirectURLSession = {
        return URLSession(configuration: .ephemeral, delegate: NoFollowRedirect(), delegateQueue: nil)
    }()

    public init(
        loginSession: LoginSession? = nil,
        baseURL: URL? = nil,
        urlSession: URLSession = URLSessionAPI.defaultURLSession
    ) {
        self.loginSession = loginSession
        self.baseURL = baseURL ?? loginSession?.baseURL ?? URL(string: "https://canvas.instructure.com/")!
        self.urlSession = urlSession
    }

    public init(session: LoginSession, urlSession: URLSession = URLSessionAPI.defaultURLSession) {
        self.loginSession = session
        self.baseURL = session.baseURL
        self.urlSession = urlSession
    }

    @discardableResult
    public func makeRequest<R: APIRequestable>(_ requestable: R, refreshToken: Bool, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        do {
            guard refreshTask?.state != .running else {
                refreshQueue.append { [weak self] in
                    self?.makeRequest(requestable, callback: callback)
                }
                return nil
            }
            let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: loginSession?.actAsUserID)
            let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                if response?.isUnauthorized == true, refreshToken, ExperimentalFeature.refreshTokens.isEnabled {
                    self?.refreshQueue.append { [weak self] in
                        self?.makeRequest(requestable, refreshToken: false, callback: callback)
                    }
                    if self?.refreshTask?.state != .running {
                        self?.refreshToken()
                    }
                    return
                }
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
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: loginSession?.actAsUserID)
        let directory = URL.temporaryDirectory
        let url = directory.appendingPathComponent(UUID.string)
        try request.httpBody?.write(to: url) // TODO: delete this file after upload completes
        #if DEBUG
        print("uploading", url)
        print("to", request.url ?? "")
        #endif
        return urlSession.uploadTask(with: request, fromFile: url)
    }

    func refreshToken() {
        guard
            let loginSession = loginSession,
            let refreshToken = loginSession.refreshToken,
            let clientID = loginSession.clientID,
            let clientSecret = loginSession.clientSecret
        else {
            return flushRefreshQueue()
        }
        let client = APIVerifyClient(authorized: true, base_url: baseURL, client_id: clientID, client_secret: clientSecret)
        let request = PostLoginOAuthRequest(client: client, refreshToken: refreshToken)
        refreshTask = makeRequest(request, refreshToken: false) { [weak self] response, _, error in
            if let response = response, error == nil {
                let session = loginSession.refresh(accessToken: response.access_token)
                LoginSession.add(session)
                if loginSession == AppEnvironment.shared.currentSession {
                    AppEnvironment.shared.currentSession = session
                }
                self?.loginSession = session
            }
            self?.flushRefreshQueue()
        }
    }

    private func flushRefreshQueue() {
        let tasks = refreshQueue
        tasks.forEach { $0() }
        refreshQueue = []
    }
}

extension URLSession {
    @objc public static func getDefaultURLSession() -> URLSession {
        return URLSessionAPI.defaultURLSession
    }
}

public class NoFollowRedirect: NSObject, URLSessionTaskDelegate {
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }
}
