
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

public extension NSURLRequest {
    public static func requestWithDefaultHTTPHeaders(url: NSURL) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.addDefaultHTTPHeaders()
        return request
    }
}

extension NSMutableURLRequest {
    public convenience init(method: Method, URL: NSURL, parameters: [String: AnyObject], encoding: ParameterEncoding) throws {
        
        let url = encoding.URLWithURL(URL, method: method, encodingParameters: parameters)
        
        self.init(URL: url)
        
        addDefaultHTTPHeaders()
        
        if let contentType = encoding.contentType(method) {
            setValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        HTTPBody = try encoding.body(method, encodingParameters: parameters)
        HTTPMethod = method.rawValue
    }

    private func authorizeIf(authorize: Bool, withToken token: String?, masqueradeAsUserID: String?) -> NSMutableURLRequest {
        guard let token = token where authorize else { return self }
        setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        guard let masqID = masqueradeAsUserID, url = URL else { return self }
        let stringURL = url.absoluteString
        let separator = stringURL!.rangeOfString("?") == nil ? "?" : "&"
        self.URL = NSURL(string:stringURL! + separator + "as_user_id=\(masqID)")
        
        return self
    }
}


extension Session {
    private func pathByRemovingDuplicateSlash(path: String) -> String {
        if path.hasPrefix("/") {
            return path.stringByReplacingCharactersInRange(path.startIndex..<path.startIndex.advancedBy(1), withString: "")
        } else {
            return path
        }
    }

    public func GET(path: String, parameters: [String: AnyObject] = [:], encoding: ParameterEncoding = .URLEncodedInURL, authorized: Bool = true) throws -> NSURLRequest {

        let url = baseURL.URLByAppendingPathComponent(pathByRemovingDuplicateSlash(path))
        
        var paramsPlusPagination = parameters
        paramsPlusPagination["per_page"] = (parameters["per_page"] as? Int) ?? 99
        
        return try NSMutableURLRequest(method: .GET, URL: url!, parameters: paramsPlusPagination, encoding: encoding)
            .authorizeIf(authorized, withToken: token, masqueradeAsUserID: masqueradeAsUserID)
    }
    
    public func POST(path: String, parameters: [String: AnyObject] = [:], encoding: ParameterEncoding = .JSON, authorized: Bool = true, headers: [String: String] = [:]) throws -> NSURLRequest {

        let url = baseURL.URLByAppendingPathComponent(pathByRemovingDuplicateSlash(path))
        
        return try NSMutableURLRequest(method: .POST, URL: url!, parameters: parameters, encoding: encoding)
            .authorizeIf(authorized, withToken: token, masqueradeAsUserID: masqueradeAsUserID)
    }

    public func PUT(path: String, parameters: [String: AnyObject] = [:], encoding: ParameterEncoding = .JSON, authorized: Bool = true) throws -> NSURLRequest {
        let url = baseURL.URLByAppendingPathComponent(pathByRemovingDuplicateSlash(path))

        return try NSMutableURLRequest(method: .PUT, URL: url!, parameters: parameters, encoding: encoding)
            .authorizeIf(authorized, withToken: token, masqueradeAsUserID: masqueradeAsUserID)
    }

    public func DELETE(path: String, parameters: [String: AnyObject] = [:], encoding: ParameterEncoding = .URLEncodedInURL, authorized: Bool = true) throws -> NSURLRequest {
        let url = baseURL.URLByAppendingPathComponent(pathByRemovingDuplicateSlash(path))

        return try NSMutableURLRequest(method: .DELETE, URL: url!, parameters: parameters, encoding: encoding)
            .authorizeIf(authorized, withToken: token, masqueradeAsUserID: masqueradeAsUserID)
    }
}
