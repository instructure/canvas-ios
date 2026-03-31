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
    case delete, get, post, put, head, patch
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

    func toPercentEncodedURLQueryItems() -> [URLQueryItem] {
        switch self {
        case .name(let name):
            return [URLQueryItem(name: name.urlSafePercentEncoded, value: nil)]
        case .value(let name, let value):
            return [URLQueryItem(name: name.urlSafePercentEncoded, value: value.urlSafePercentEncoded)]
        case .optionalValue(let name, let value):
            guard let value = value else { return [] }
            return [URLQueryItem(name: name.urlSafePercentEncoded, value: value.urlSafePercentEncoded)]
        case .array(let name, let array):
            return array.map { value in
                URLQueryItem(
                    name: "\(name)[]".urlSafePercentEncoded,
                    value: value.urlSafePercentEncoded
                )
            }
        case .include(let includes):
            return APIQueryItem.array("include", includes).toPercentEncodedURLQueryItems()
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

extension String {
    var urlSafePercentEncoded: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?
            .replacingOccurrences(of: "+", with: "%2B") ?? ""
    }
}

extension Array where Element == String {
    var urlSafePercentEncoded: [String] {
        self.map { $0.urlSafePercentEncoded }
    }
}

public class APIJSONDecoder: JSONDecoder, @unchecked Sendable {
    private static let standardFormatter = ISO8601DateFormatter()
    private static let extendedFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    public override init() {
        super.init()

        // Setting this as custom to handle more variations of ISO8601 dates, as the default `JSONDecoder`'s `.iso8601`
        // strategy is strict and rejects certain valid ISO8601 dates (like negative years), causing the entire object to
        // fail decoding. This custom strategy uses `ISO8601DateFormatter` directly, which is more lenient and allows such
        // unlikely -but formatting-wise valid- dates to be parsed.
        //
        // To be even more tolerant when parsing date values, like fallback to `nil` in case of malformed values, use
        // `SafeDate` property wrapper with optional date properties on your decodable model.
        dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first (for RN generated dates like "2019-06-02T18:07:28.000Z")
            // This must come BEFORE standard ISO8601 to avoid the extended formatter being too lenient
            if let date = Self.extendedFormatter.date(from: dateString) {
                return date
            }

            // Try standard ISO8601 format (e.g., "2025-01-15T10:30:00Z" or "-3033-05-31T07:51:58Z")
            if let date = Self.standardFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected date string to be ISO8601-formatted"
            )
        }
    }
}

public class APIJSONEncoder: JSONEncoder, @unchecked Sendable {
    public override init() {
        super.init()
        dateEncodingStrategy = .iso8601
        outputFormatting = .sortedKeys
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
    /** If `form` property is set, then the `body` property is ignored. */
    var form: APIFormData? { get }
    /** Only used if `form` property is `nil`. */
    var body: Body? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var shouldHandleCookies: Bool { get }
    /**
     If this parameter is true, then the `urlRequest` method won't set the `httpBody` parameter on the created `URLRequest`.
     Useful if the body would be so big that it wouldn't fit into memory. In such cases it's the caller's responsibility to create the http body
     in an external file and use `URLSession`'s `uploadTask` method that accepts a URL for the request body. Only used for `form` requests.
     */
    var isBodyFromURL: Bool { get }

    /// If this parameter is set to true, then we will use a custom percent encoding for every `URLQueryItem`  where the `"+"` sign is encoded alongside with the `urlHostAllowed` CharacterSet.
    /// Some APIs expect Date strings with the time zone attached where we need to encode the `+` sign.
    var useExtendedPercentEncoding: Bool { get }
    /// This will make the API to omit the file verifier parameter when returning course file links in rich content.
    var shouldAddNoVerifierQuery: Bool { get }

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
        return query.flatMap { $0.toURLQueryItems() }
    }
    public var percentEncodedQueryItems: [URLQueryItem] {
        return query.flatMap { $0.toPercentEncodedURLQueryItems() }
    }
    public var form: APIFormData? {
        return nil
    }
    public var isFormRequest: Bool { form != nil }
    public var body: Body? {
        return nil
    }
    public var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    public var shouldHandleCookies: Bool {
        return true
    }
    public var isBodyFromURL: Bool { false }

    public var useExtendedPercentEncoding: Bool { false }

    public var shouldAddNoVerifierQuery: Bool { true }

    public func urlRequest(relativeTo baseURL: URL, accessToken: String?, actAsUserID: String?) throws -> URLRequest {
        guard var components = URLComponents(string: path) else { throw APIRequestableError.invalidPath(path) }

        if !path.hasPrefix("/") && components.host == nil {
            components.path = "/api/v1/" + components.path
        }

        let extraQueryItems = extraQueryItems(actAsUserID: actAsUserID)

        if useExtendedPercentEncoding, !percentEncodedQueryItems.isEmpty {
            components.percentEncodedQueryItems = percentEncodedQueryItems + extraQueryItems
        } else if (!queryItems.isEmpty || !extraQueryItems.isEmpty) {
            components.queryItems = (components.queryItems ?? []) + queryItems + extraQueryItems
        }

        // The conditional path prefixing *should* have made this impossible to fail
        guard let url = components.url(relativeTo: baseURL) else { throw APIRequestableError.cannotResolve(components, baseURL) }
        var request: URLRequest
        request = URLRequest(url: url, cachePolicy: cachePolicy)
        request.httpMethod = method.rawValue.uppercased()

        if let form = self.form {
            let boundary = UUID.string
            request.setValue("multipart/form-data; charset=utf-8; boundary=\"\(boundary)\"", forHTTPHeaderField: HttpHeader.contentType)

            if !isBodyFromURL {
                request.httpBody = try form.encode(using: boundary)
            }
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
            return GetNextRequest<Response>(path: next.absoluteString, decoder: decode)
        }
        return nil
    }

    public static func defaultDecode<T: Codable>(_ data: Data) throws -> T {
        try APIJSONDecoder().decode(T.self, from: data)
    }

    public func decode(_ data: Data) throws -> Response {
        try Self.defaultDecode(data)
    }

    public func encode(_ body: Body) throws -> Data {
        try APIJSONEncoder().encode(body)
    }

    public func encode(response: Response) throws -> Data {
        try APIJSONEncoder().encode(response)
    }

    private func extraQueryItems(actAsUserID: String?) -> [URLQueryItem] {
        var extraQueryItems: [URLQueryItem] = []

        if let actAsUserID {
            extraQueryItems.append(URLQueryItem(name: "as_user_id", value: actAsUserID))
        }

        if shouldAddNoVerifierQuery {
            extraQueryItems.append(URLQueryItem(name: "no_verifiers", value: "1"))
        }

        return extraQueryItems
    }
}

/// A paginated follow-up request created by `getNext(from:)` on the originating request.
public struct GetNextRequest<T: Codable>: APIRequestable {
    public typealias Response = T
    public let path: String
    private let customDecoder: (Data) throws -> T

    /// - Parameters:
    ///   - path: The URL path for the next page, taken from the `Link` response header.
    ///   - decoder: The decode function of the originating request. Forwarding it ensures paginated
    ///     responses are decoded identically to the first page, which matters for requests that
    ///     override `decode` to unwrap a JSON envelope.
    public init(
        path: String,
        decoder: @escaping (Data) throws -> T = GetNextRequest.defaultDecode
    ) {
        self.path = path
        self.customDecoder = decoder
    }

    public func decode(_ data: Data) throws -> T {
        try customDecoder(data)
    }
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
