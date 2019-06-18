//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if DEBUG

import Foundation

struct MockDataMessage: Codable {
    let data: Data?
    let error: String?
    let request: URLRequest
    let response: MockResponse?
    let noCallback: Bool
}

struct MockDownloadMessage: Codable {
    let data: Data?
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

#endif
