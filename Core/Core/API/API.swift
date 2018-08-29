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
    func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask?
}

public struct URLSessionAPI: API {
    var baseURL: URL {
        return /* Keychain.currentSession?.baseURL ?? */ URL(string: "https://canvas.instructure.com/")!
    }
    var accessToken: String {
        return /* Keychain.currentSession?.accessToken ?? */ ""
    }

    private static var defaultUrlSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        return configuration
    }

    var urlSession: URLSession = URLSession(configuration: URLSessionAPI.defaultUrlSessionConfiguration)

    public init(urlSession: URLSession? = nil) {
        if let session = urlSession {
            self.urlSession = session
        }

    }

    @discardableResult
    public func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        do {
            let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken)
            let task = urlSession.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else { return callback(nil, response, error) }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    callback(try decoder.decode(R.Response.self, from: data), response, error)
                } catch let error {
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
}
