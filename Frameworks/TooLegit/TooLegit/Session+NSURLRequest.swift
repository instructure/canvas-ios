//
//  RequestBuilder.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/22/15.
//  Copyright © 2015 Instructure. All rights reserved.
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
