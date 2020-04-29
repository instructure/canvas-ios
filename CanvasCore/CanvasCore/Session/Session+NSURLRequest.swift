//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

public extension URLRequest {
    static func requestWithDefaultHTTPHeaders(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addDefaultHTTPHeaders()
        return request as URLRequest
    }
}

extension URLRequest {
    public init(method: Method, URL: URL, parameters: [String: Any], encoding: ParameterEncoding?) throws {
        
        let encoding = encoding ?? method.defaultEncoding
        
        let url = encoding.URLWithURL(URL, method: method, encodingParameters: parameters)
        
        self.init(url: url)
        
        addDefaultHTTPHeaders()
        
        if let contentType = encoding.contentType(method) {
            setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        httpBody = try encoding.body(method, encodingParameters: parameters)
        httpMethod = method.rawValue
    }
}


extension Session {
    fileprivate func pathByRemovingDuplicateSlash(_ path: String) -> String {
        if path.hasPrefix("/") { return String(path.dropFirst()) }
        return path
    }

    public func GET(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .urlEncodedInURL, authorized: Bool = true, userAgent: String? = nil, paginated: Bool = true) throws -> URLRequest {

        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))
        
        var paramsPlusPagination = parameters
        if paginated {
            paramsPlusPagination["per_page"] = (parameters["per_page"] as? Int) ?? 100
        }
        
        var request = try URLRequest(method: .GET, URL: url, parameters: paramsPlusPagination, encoding: encoding)

        if let userAgent = userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        return request
    }
    
    public func POST(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .json, authorized: Bool = true, headers: [String: String] = [:]) throws -> URLRequest {

        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))
        
        return try URLRequest(method: .POST, URL: url, parameters: parameters, encoding: encoding)
    }

    public func PUT(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .json, authorized: Bool = true) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))

        return try URLRequest(method: .PUT, URL: url, parameters: parameters, encoding: encoding)
    }

    public func DELETE(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .urlEncodedInURL, authorized: Bool = true) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))

        return try URLRequest(method: .DELETE, URL: url, parameters: parameters, encoding: encoding)
    }
}
