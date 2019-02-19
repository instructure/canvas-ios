//
// Copyright (C) 2018-present Instructure, Inc.
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
    func uploadTask<R: APIRequestable>(_ requestable: R, fromFile file: URL) throws -> URLSessionTask
}

public struct URLSessionAPI: API {
    public let accessToken: String?
    public let actAsUserID: String?
    public let baseURL: URL
    let urlSession: URLSession

    public var identifier: String? {
        return urlSession.configuration.identifier
    }

    public static var defaultUrlSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        return configuration
    }

    public init(
        accessToken: String? = nil,
        actAsUserID: String? = nil,
        baseURL: URL? = nil,
        urlSession: URLSession = URLSession(configuration: URLSessionAPI.defaultUrlSessionConfiguration)
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
                    callback(nil, response, error)
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
    public func uploadTask<R>(_ requestable: R, fromFile file: URL) throws -> URLSessionTask where R: APIRequestable {
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
        return urlSession.uploadTask(with: request, fromFile: file)
    }
}
