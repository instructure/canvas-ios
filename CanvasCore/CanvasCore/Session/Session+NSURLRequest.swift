//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import Foundation

public extension URLRequest {
    public static func requestWithDefaultHTTPHeaders(_ url: URL) -> URLRequest {
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

    public func authorized(_ authorized: Bool = true, with session: Session) -> URLRequest {
        guard let token = session.token, authorized else { return self }
        
        var authed = self
        authed.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        guard let masqID = session.masqueradeAsUserID, let url = url else { return authed }
        let stringURL = url.absoluteString
        let separator = stringURL.range(of: "?") == nil ? "?" : "&"
        authed.url = URL(string:stringURL + separator + "as_user_id=\(masqID)")
        
        return authed
    }
}


extension Session {
    fileprivate func pathByRemovingDuplicateSlash(_ path: String) -> String {
        if path.hasPrefix("/") { return String(path.dropFirst()) }
        return path
    }

    public func GET(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .urlEncodedInURL, authorized: Bool = true, userAgent: String? = nil) throws -> URLRequest {

        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))
        
        var paramsPlusPagination = parameters
        paramsPlusPagination["per_page"] = (parameters["per_page"] as? Int) ?? 99
        
        var request = try URLRequest(method: .GET, URL: url, parameters: paramsPlusPagination, encoding: encoding)
            .authorized(authorized, with: self)
        
        if let userAgent = userAgent {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        return request
    }
    
    public func POST(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .json, authorized: Bool = true, headers: [String: String] = [:]) throws -> URLRequest {

        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))
        
        return try URLRequest(method: .POST, URL: url, parameters: parameters, encoding: encoding)
            .authorized(authorized, with: self)
    }

    public func PUT(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .json, authorized: Bool = true) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))

        return try URLRequest(method: .PUT, URL: url, parameters: parameters, encoding: encoding)
            .authorized(authorized, with: self)
    }

    public func DELETE(_ path: String, parameters: [String: Any] = [:], encoding: ParameterEncoding = .urlEncodedInURL, authorized: Bool = true) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(pathByRemovingDuplicateSlash(path))

        return try URLRequest(method: .DELETE, URL: url, parameters: parameters, encoding: encoding)
            .authorized(authorized, with: self)
    }
}
