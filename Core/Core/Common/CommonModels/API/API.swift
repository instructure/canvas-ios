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

public class API {
    public var loginSession: LoginSession?
    public let baseURL: URL
    public let urlSession: URLSession

    internal lazy var refreshTokenInteractor = TokenRefreshInteractor(api: self)

    public init(_ loginSession: LoginSession? = nil, baseURL: URL? = nil, urlSession: URLSession = .ephemeral) {
        self.loginSession = loginSession
        self.baseURL = baseURL ?? loginSession?.baseURL ?? URL(string: "https://canvas.instructure.com/")!
        self.urlSession = urlSession
    }

    @discardableResult
    public func makeRequest<Request: APIRequestable>(
        _ requestable: Request,
        refreshToken: Bool = true,
        callback: @escaping (Request.Response?, URLResponse?, Error?) -> Void
    ) -> APITask? {
        do {
            if refreshTokenInteractor.isTokenRefreshInProgress(), !(requestable is PostLoginOAuthRequest) {
                refreshTokenInteractor.addRequestWaitingForToken { [weak self] in
                    self?.makeRequest(requestable, callback: callback)
                }
                return nil
            }

            let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: loginSession?.actAsUserID)
            let handler = { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                if response?.isUnauthorized == true, refreshToken {
                    if let self {
                        if refreshTokenInteractor.isTokenRefreshInProgress() == false {
                            refreshTokenInteractor.refreshToken()
                        }
                        refreshTokenInteractor.addRequestWaitingForToken { [weak self] in
                            self?.makeRequest(requestable, refreshToken: false, callback: callback)
                        }
                        return
                    }
                }

                // If the request is rejected due to the rate limit being exhausted we retry and hope that the quota is restored in the meantime
                if response?.exceededLimit(responseData: data) == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                        self?.makeRequest(requestable, callback: callback)
                    }
                    return
                }

                guard let data = data, error == nil, !(Request.Response.self is APINoContent.Type) else {
                    return callback(nil, response, error)
                }
                do {
                    callback(try requestable.decode(data), response, error)
                } catch let error {
                    #if DEBUG
                    print(request, response ?? "", String(data: data, encoding: .utf8) ?? "", error)
                    #endif
                    callback(nil, response, APIError.from(data: data, response: response, error: error))
                }
            }
            let task: APITask
            #if DEBUG
            task = API.shouldMock(request) ? MockAPITask(self, request: request, callback: handler) :
                urlSession.dataTask(with: request, completionHandler: handler)
            #else
            task = urlSession.dataTask(with: request, completionHandler: handler)
            #endif
            task.resume()
            return task
        } catch let error {
            callback(nil, nil, error)
            return nil
        }
    }

    @discardableResult
    public func makeRequest<Request: APIRequestable>(
        _ requestable: Request,
        refreshToken: Bool = true
    ) async throws -> Request.Response {
        return try await withCheckedThrowingContinuation { continuation in
            makeRequest(requestable) { result, response, error in
                if let error {
                    continuation.resume(throwing: APIError.from(data: nil, response: response, error: error))
                } else if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: APIAsyncError.invalidResponse)
                }
            }
        }
    }

    @discardableResult
    public func makeDownloadRequest(_ url: URL,
                                    method: APIMethod? = nil,
                                    callback: ((URL?, URLResponse?, Error?) -> Void)? = nil)
    -> APITask? {
        var request = URLRequest(url: url)

        if AppEnvironment.shared.app == .horizon {
            let token = AppEnvironment.shared.currentSession?.accessToken ?? ""
            request.setValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization)
        }

        if let method {
            request.httpMethod = method.rawValue.uppercased()
        }

        let task: APITask
        #if DEBUG
        if API.shouldMock(request) {
            task = MockAPITask(self, request: request, callback: callback)
            task.resume()
            return task
        }
        #endif
        if let callback = callback {
            task = urlSession.downloadTask(with: request, completionHandler: callback)
        } else {
            task = urlSession.downloadTask(with: request)
        }
        task.resume()
        return task
    }

    @discardableResult
    public func uploadTask<Request: APIRequestable>(_ requestable: Request) throws -> APITask {
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: loginSession?.accessToken, actAsUserID: loginSession?.actAsUserID)

        #if DEBUG
        if API.shouldMock(request) {
            return MockAPITask(self, request: request)
        }
        #endif

        if requestable.isBodyFromURL, let form = requestable.form {
            guard let boundary = request.boundary else {
                throw NSError.instructureError("Failed to extract boundary from HTTP header.")
            }
            let bodyFileURL: URL = try form.encode(using: boundary) // TODO: delete this file after upload completes
            return urlSession.uploadTask(with: request, fromFile: bodyFileURL)
        } else {
            let url = URL.Directories.temporary.appendingPathComponent(UUID.string)
            try request.httpBody?.write(to: url) // TODO: delete this file after upload completes
            return urlSession.uploadTask(with: request, fromFile: url)
        }
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

    public func exhaust<R>(_ requestable: R, callback: @escaping (R.Response.Page?, URLResponse?, Error?) -> Void) where R: APIPagedRequestable {
        exhaust(requestable, result: nil, callback: callback)
    }

    private func exhaust<R>(_ requestable: R, result: R.Response.Page?, callback: @escaping (R.Response.Page?, URLResponse?, Error?) -> Void) where R: APIPagedRequestable {
        makeRequest(requestable) { response, urlResponse, error in
            guard let response = response else {
                callback(nil, urlResponse, error)
                return
            }
            let result = result == nil ? response.page : result! + response.page
            if let next = requestable.nextPageRequest(from: response) as? R {
                self.exhaust(next, result: result, callback: callback)
                return
            }
            callback(result, urlResponse, error)
        }
    }
}

public protocol APITask {
    var state: URLSessionTask.State { get }
    var taskID: String? { get set }

    func cancel()
    func resume()
}

extension URLSessionTask: APITask {
    public var taskID: String? {
        get { taskDescription }
        set { taskDescription = newValue }
    }
}

public extension URLSession {
    static var ephemeral: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        return URLSession(configuration: configuration, delegate: FollowRedirect(), delegateQueue: nil)
    }()
    static var noFollowRedirect = URLSession(configuration: .ephemeral, delegate: NoFollowRedirect(), delegateQueue: nil)
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

public class FollowRedirect: NSObject, URLSessionTaskDelegate {
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest,
                           completionHandler: @escaping (URLRequest?) -> Void) {
        var newRequest = request
        if let authorizationHeader = task.originalRequest?.value(forHTTPHeaderField: HttpHeader.authorization), request.url?.host == AppEnvironment.shared.currentSession?.baseURL.host {
            newRequest.addValue(authorizationHeader, forHTTPHeaderField: HttpHeader.authorization)
        }
        completionHandler(newRequest)
    }
}

public enum APIAsyncError: Error {
    case invalidResponse
}
