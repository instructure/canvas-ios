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
import SoSeedySwift
@testable import Core

public struct RecordableAPI: API {
    var baseURL: URL {
        let url = Keychain.currentSession?.baseURL ?? "https://canvas.instructure.com/"
        return URL(string: url)!
    }
    var accessToken: String {
        return Keychain.currentSession?.token ?? ""
    }

    private static var defaultUrlSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        return configuration
    }

    var urlSession: URLSession = URLSession(configuration: RecordableAPI.defaultUrlSessionConfiguration)

    public init(urlSession: URLSession? = nil) {
        if let session = urlSession {
            self.urlSession = session
        }

    }

    @discardableResult
    public func makeRequest<R: APIRequestable>(_ requestable: R, callback: @escaping (R.Response?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        do {
            let request: URLRequest = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken)
            let absoluteURL: String = request.url!.absoluteString
            let response = VCR.shared.response(for: absoluteURL)
            if (response != nil) {
                let data = response!.data(using: .utf8)!
                do {
                    callback(try requestable.decode(data), nil, nil)
                } catch {
                    callback(nil, nil, error)
                }
                return nil
            }

            let task = urlSession.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    return callback(nil, response, error)
                }
                let stringResponse = String(data: data, encoding: .utf8)!
                VCR.shared.recordResponse(stringResponse, for: absoluteURL)
                do {
                    callback(try requestable.decode(data), response, error)
                } catch let error {
                    callback(nil, response, error)
                }
            }
            task.resume()
            return task
        } catch {
            callback(nil, nil, error)
            return nil
        }
    }
}
