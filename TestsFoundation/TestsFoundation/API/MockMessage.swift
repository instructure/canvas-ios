//
// Copyright (C) 2019-present Instructure, Inc.
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

struct MockDataMessage: Codable {
    let data: Data?
    let error: String?
    let request: URLRequest
    let response: MockResponse?
    let noCallback: Bool
}

struct MockDownloadMessage: Codable {
    let data: URL?
    let error: String?
    let response: MockResponse?
    let url: URL
}

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

public struct MockResponse: Codable {
    public let http: HTTPURLResponse

    enum CodingKeys: String, CodingKey {
        case allHeaderFields, statusCode, url
    }

    public init(http: HTTPURLResponse) {
        self.http = http
    }

    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: CodingKeys.self)
        let allHeaderFields = try root.decodeIfPresent([String: String].self, forKey: .allHeaderFields)
        let statusCode = try root.decode(Int.self, forKey: .statusCode)
        let url = try root.decode(URL.self, forKey: .url)
        guard let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: allHeaderFields) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: root.codingPath, debugDescription: "Could not instantiate an HTTPURLResponse"))
        }
        http = response
    }

    public func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: CodingKeys.self)
        try root.encode(http.allHeaderFields as? [String: String], forKey: .allHeaderFields)
        try root.encode(http.statusCode, forKey: .statusCode)
        try root.encode(http.url, forKey: .url)
    }
}
