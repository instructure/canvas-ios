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

enum APIMethod: String {
    case delete, get, post, put
}

enum APIQueryItem {
    case name(String)
    case value(String, String)
    case array(String, [String])

    func toURLQueryItems() -> [URLQueryItem] {
        switch self {
        case .name(let name):
            return [URLQueryItem(name: name, value: nil)]
        case .value(let name, let value):
            return [URLQueryItem(name: name, value: value)]
        case .array(let name, let array):
            return array.map({ value in URLQueryItem(name: "\(name)[]", value: value) })
        }
    }
}

// These errors are all definitely mistakes in our app code
enum APIRequestableError: Error, Equatable {
    case invalidPath(String) // our request path string can't be parsed by URLComponents
    case cannotResolve(URLComponents, URL) // our components can't be resolved against baseURL
}

let APIUserAgent: String = {
    let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
    let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
    return "iCanvas/\(shortVersion) (\(bundleVersion)) \(UIDevice.current.model)/\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
}()

protocol APIRequestable {
    associatedtype Response: Codable
    associatedtype Body: Encodable = String

    var method: APIMethod { get }
    var headers: [String: String?] { get }
    var path: String { get }
    var query: [APIQueryItem] { get }
    var body: Body? { get }

    func urlRequest(relativeTo: URL, accessToken: String) throws -> URLRequest
}

extension APIRequestable {
    var method: APIMethod {
        return .get
    }
    var headers: [String: String?] {
        return [:]
    }
    var query: [APIQueryItem] {
        return []
    }
    var queryItems: [URLQueryItem] {
        return query.flatMap({ q in q.toURLQueryItems() })
    }
    var body: Body? {
        return nil
    }

    func urlRequest(relativeTo baseURL: URL, accessToken: String) throws -> URLRequest {
        guard var components = URLComponents(string: path) else { throw APIRequestableError.invalidPath(path) }

        if components.host == nil {
            components.path = "/api/v1/" + components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }

        let queryItems = self.queryItems
        if !queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }
        // The conditional path prefixing *should* have made this impossible to fail
        guard let url = components.url(relativeTo: baseURL) else { throw APIRequestableError.cannotResolve(components, baseURL) }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue.uppercased()

        if let body = self.body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        }

        request.setValue("application/json+canvas-string-ids", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(APIUserAgent, forHTTPHeaderField: "User-Agent")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    func getNext(from response: URLResponse) -> GetNextRequest<Response>? {
        if let next = response.links?["next"] {
            return GetNextRequest<Response>(path: next.absoluteString)
        }
        return nil
    }
}

struct GetNextRequest<T: Codable>: APIRequestable {
    typealias Response = T
    let path: String
}
