//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

#if DEBUG

import Foundation

extension URLRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case allHTTPHeaderFields, cachePolicy, httpBody, httpMethod, url
    }

    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        self.init(url: try root.decode(URL.self, forKey: .url))
        allHTTPHeaderFields = try root.decodeIfPresent([String: String].self, forKey: .allHTTPHeaderFields)
        cachePolicy = try URLRequest.CachePolicy(rawValue: root.decode(UInt.self, forKey: .cachePolicy)) ?? .useProtocolCachePolicy
        httpBody = try root.decodeIfPresent(Data.self, forKey: .httpBody)
        httpMethod = try root.decodeIfPresent(String.self, forKey: .httpMethod)
    }

    public func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        try root.encode(allHTTPHeaderFields, forKey: .allHTTPHeaderFields)
        try root.encode(cachePolicy.rawValue, forKey: .cachePolicy)
        try root.encode(httpBody, forKey: .httpBody)
        try root.encode(httpMethod, forKey: .httpMethod)
        try root.encode(url, forKey: .url)
    }
}

public class MockHTTPResponse: Codable {
    public let data: Data?
    public let http: HTTPURLResponse?
    public let errorMessage: String?
    public let noCallback: Bool
    public var error: Error? { errorMessage.map { NSError.instructureError($0) } }

    public lazy var dataSavedToTemporaryFileURL: URL? = {
        guard let data = data else { return nil }
        let url = URL.Directories.temporary.appendingPathComponent(Foundation.UUID().uuidString, isDirectory: false)
        (try? data.write(to: url))!
        return url
    }()

    enum CodingKeys: String, CodingKey {
        case data, errorMessage, allHeaderFields, statusCode, url, noCallback
    }

    public init(data: Data? = nil, http: HTTPURLResponse? = nil, errorMessage: String? = nil, noCallback: Bool = false) {
        self.data = data
        self.http = http
        self.errorMessage = errorMessage
        self.noCallback = noCallback
    }

    convenience init?<D: Codable>(value: D) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(value) else {
            return nil
        }

        self.init(data: data,
                  http: HTTPURLResponse(url: .make(), statusCode: 200, httpVersion: nil, headerFields: nil))
    }

    required public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)

        data = try root.decodeIfPresent(Data.self, forKey: .data)
        let allHeaderFields = try root.decodeIfPresent([String: String].self, forKey: .allHeaderFields)
        if let statusCode = try root.decodeIfPresent(Int.self, forKey: .statusCode),
           let url = try root.decodeIfPresent(URL.self, forKey: .url) {
            http = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: allHeaderFields)
        } else {
            http = nil
        }
        errorMessage = try root.decodeIfPresent(String.self, forKey: .errorMessage)
        noCallback = try root.decode(Bool.self, forKey: .noCallback)
    }

    public func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        try root.encode(data, forKey: .data)
        try root.encode(http?.allHeaderFields as? [String: String], forKey: .allHeaderFields)
        try root.encode(http?.statusCode, forKey: .statusCode)
        try root.encode(http?.url, forKey: .url)
        try root.encode(errorMessage, forKey: .errorMessage)
        try root.encode(noCallback, forKey: .noCallback)
    }

    public static var noContent: MockHTTPResponse {
        MockHTTPResponse(http: HTTPURLResponse(url: .make(), statusCode: 204, httpVersion: nil, headerFields: [:]))
    }
}

#endif
