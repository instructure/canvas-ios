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

public enum APIMethod: String {
    case delete, get, post, put
}

public enum APIQueryItem: Equatable {
    case name(String)
    case value(String, String)
    case array(String, [String])
    case include([String])
    case perPage(Int?)
    case bool(String, Bool)
    case optionalValue(String, String?)
    case optionalBool(String, Bool?)

    func toURLQueryItems() -> [URLQueryItem] {
        switch self {
        case .name(let name):
            return [URLQueryItem(name: name, value: nil)]
        case .value(let name, let value):
            return [URLQueryItem(name: name, value: value)]
        case .optionalValue(let name, let value):
            guard let value = value else { return [] }
            return [URLQueryItem(name: name, value: value)]
        case .array(let name, let array):
            return array.map({ value in URLQueryItem(name: "\(name)[]", value: value) })
        case .include(let includes):
            return APIQueryItem.array("include", includes).toURLQueryItems()
        case .perPage(let perPage):
            guard let perPage = perPage else { return [] }
            return APIQueryItem.value("per_page", String(perPage)).toURLQueryItems()
        case .bool(let name, let value):
            return APIQueryItem.value(name, value ? "1" : "0").toURLQueryItems()
        case .optionalBool(let name, let value):
            guard let value = value else { return [] }
            return APIQueryItem.value(name, value ? "1" : "0").toURLQueryItems()
        }
    }
}

public class APIJSONDecoder: JSONDecoder {
    public override init() {
        super.init()
        dateDecodingStrategy = .iso8601
    }

    // Can decode dates like "2019-06-02T18:07:28.000Z" that RN generates
    public static var extendedPrecisionDecoder: APIJSONDecoder {
        let decoder = APIJSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected date string to be ISO8601-formatted"
                )
            }
            return date
        }
        return decoder
    }
}

public class APIJSONEncoder: JSONEncoder {
    public override init() {
        super.init()
        dateEncodingStrategy = .iso8601
    }
}

public typealias APIFormData = [(key: String, value: APIFormDatum)]

public enum APIFormDatum: Equatable {
    case string(String)
    case data(filename: String, type: String, data: Data)
    case file(filename: String, type: String, at: URL)

    public static func bool(_ value: Bool) -> APIFormDatum {
        return .string(value ? "1" : "0")
    }
    public static func date(_ value: Date?) -> APIFormDatum {
        return .string(value?.isoString() ?? "")
    }
}

// These errors are all definitely mistakes in our app code
enum APIRequestableError: Error, Equatable {
    case invalidPath(String) // our request path string can't be parsed by URLComponents
    case cannotResolve(URLComponents, URL) // our components can't be resolved against baseURL
}

public typealias APICodable = Codable & Equatable

public protocol APIRequestable {
    associatedtype Response: Codable
    associatedtype Body: Encodable = String

    var method: APIMethod { get }
    var headers: [String: String?] { get }
    var path: String { get }
    var query: [APIQueryItem] { get }
    var form: APIFormData? { get }
    var body: Body? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var shouldHandleCookies: Bool { get }

    func urlRequest(relativeTo: URL, accessToken: String?, actAsUserID: String?) throws -> URLRequest
    func decode(_ data: Data) throws -> Response
    func encode(_ body: Body) throws -> Data
    func encode(response: Response) throws -> Data
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
    public var form: APIFormData? {
        return nil
    }
    public var body: Body? {
        return nil
    }
    public var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    public var shouldHandleCookies: Bool {
        return true
    }
    public func urlRequest(relativeTo baseURL: URL, accessToken: String?, actAsUserID: String?) throws -> URLRequest {
        guard var components = URLComponents(string: path) else { throw APIRequestableError.invalidPath(path) }

        if !path.hasPrefix("/") && components.host == nil {
            components.path = "/api/v1/" + components.path
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

        if let form = self.form {
            let boundary = UUID.string
            request.httpBody = try encodeFormData(boundary: boundary, form: form)
            request.setValue("multipart/form-data; charset=utf-8; boundary=\"\(boundary)\"", forHTTPHeaderField: HttpHeader.contentType)
        } else if let body = self.body {
            request.httpBody = try encode(body)
            request.setValue("application/json", forHTTPHeaderField: HttpHeader.contentType)
        }

        request.setValue("application/json+canvas-string-ids", forHTTPHeaderField: HttpHeader.accept)
        if let token = accessToken, request.url?.host == baseURL.host {
            request.setValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization)
        }
        request.setValue(UserAgent.default.description, forHTTPHeaderField: HttpHeader.userAgent)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.httpShouldHandleCookies = shouldHandleCookies

        return request
    }

    public func getNext(from response: URLResponse) -> GetNextRequest<Response>? {
        if let next = response.links?["next"] {
            return GetNextRequest<Response>(path: next.absoluteString)
        }
        return nil
    }

    public func decode(_ data: Data) throws -> Response {
        try APIJSONDecoder().decode(Response.self, from: data)
    }

    public func encode(_ body: Body) throws -> Data {
        try APIJSONEncoder().encode(body)
    }

    public func encode(response: Response) throws -> Data {
        try APIJSONEncoder().encode(response)
    }

    public func encodeFormData(boundary: String, form: APIFormData) throws -> Data {
        var data = Data()
        let delimiter = "--\(boundary)\r\n".data(using: .utf8)!

        for (key, value) in form {
            data += delimiter
            data += "Content-Disposition: form-data; name=\"\(key)\"".data(using: .utf8)!
            switch value {
            case .string(let string):
                data += "\r\n\r\n\(string)".data(using: .utf8)!
            case .data(filename: let filename, type: let type, data: let contents):
                data += "; filename=\"\(filename)\"\r\nContent-Type: \(type)\r\n\r\n".data(using: .utf8)!
                data += contents
            case .file(filename: let filename, type: let type, at: let url):
                data += "; filename=\"\(filename)\"\r\nContent-Type: \(type)\r\n\r\n".data(using: .utf8)!
                data += try Data(contentsOf: url)
            }
            data += "\r\n".data(using: .utf8)!
        }

        data += "--\(boundary)--\r\n".data(using: .utf8)!
        return data
    }
}

public struct GetNextRequest<T: Codable>: APIRequestable {
    public typealias Response = T
    public let path: String
}

public struct APINoContent: Codable {
    public init() {}
}

extension URLRequest: APIRequestable {
    public typealias Response = Data

    public var path: String { "" }
    public func decode(_ data: Data) throws -> Data { data }

    public func urlRequest(relativeTo baseURL: URL, accessToken: String?, actAsUserID: String?) throws -> URLRequest {
        guard let url = url else { throw NSError.internalError() }
        var request = self
        if let token = accessToken, url.host == baseURL.host {
            request.setValue("Bearer \(token)", forHTTPHeaderField: HttpHeader.authorization)
        }
        if let actAsUserID = actAsUserID {
            request.url = url.appendingQueryItems(URLQueryItem(name: "as_user_id", value: actAsUserID))
        }
        return request
    }
}

extension URL: APIRequestable {
    public typealias Response = Data

    public func decode(_ data: Data) throws -> Data { data }
    public func urlRequest(relativeTo baseURL: URL, accessToken: String?, actAsUserID: String?) throws -> URLRequest {
        try URLRequest(url: self).urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: actAsUserID)
    }
}
