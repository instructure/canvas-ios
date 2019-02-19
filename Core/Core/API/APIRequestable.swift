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

public enum APIMethod: String {
    case delete, get, post, put
}

public enum APIQueryItem: Equatable {
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

public protocol APIRequestable {
    associatedtype Response: Codable
    associatedtype Body: Encodable = String

    var method: APIMethod { get }
    var headers: [String: String?] { get }
    var path: String { get }
    var query: [APIQueryItem] { get }
    var body: Body? { get }
    var cachePolicy: URLRequest.CachePolicy { get }

    func urlRequest(relativeTo: URL, accessToken: String?, actAsUserID: String?) throws -> URLRequest
    func decode(_ data: Data) throws -> Response
    func encode(_ body: Body) throws -> Data
}

extension APIRequestable {
    public var method: APIMethod {
        return .get
    }
    public var headers: [String: String?] {
        return [:]
    }
    public var query: [APIQueryItem] {
        return []
    }
    public var queryItems: [URLQueryItem] {
        return query.flatMap({ q in q.toURLQueryItems() })
    }
    public var body: Body? {
        return nil
    }
    public var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    public func urlRequest(relativeTo baseURL: URL, accessToken: String?, actAsUserID: String?) throws -> URLRequest {
        guard var components = URLComponents(string: path) else { throw APIRequestableError.invalidPath(path) }

        if !path.hasPrefix("/") && components.host == nil {
            components.path = "/api/v1/" + components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        }

        var queryItems = self.queryItems
        if let actAsUserID = actAsUserID {
            queryItems.append(URLQueryItem(name: "as_user_id", value: actAsUserID))
        }
        if !queryItems.isEmpty {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }
        // The conditional path prefixing *should* have made this impossible to fail
        guard let url = components.url(relativeTo: baseURL) else { throw APIRequestableError.cannotResolve(components, baseURL) }

        var request: URLRequest
        request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = method.rawValue.uppercased()

        if let body = self.body {
            request.httpBody = try encode(body)
            request.setValue("application/json", forHTTPHeaderField: HttpHeader.contentType)
        }

        request.setValue("application/json+canvas-string-ids", forHTTPHeaderField: HttpHeader.accept)
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization)
        }
        request.setValue(UserAgent.default.description, forHTTPHeaderField: HttpHeader.userAgent)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    public func getNext(from response: URLResponse) -> GetNextRequest<Response>? {
        if let next = response.links?["next"] {
            return GetNextRequest<Response>(path: next.absoluteString)
        }
        return nil
    }

    public func decode(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Response.self, from: data)
    }

    public func encode(_ body: Body) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(body)
    }
}

public struct GetNextRequest<T: Codable>: APIRequestable {
    public typealias Response = T
    public let path: String
}

public struct APINoContent: Codable {}
