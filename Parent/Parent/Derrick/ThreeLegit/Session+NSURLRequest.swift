//
//  RequestBuilder.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/22/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    convenience init(method: Method, URL: NSURL, parameters: [String: AnyObject], encoding: ParameterEncoding) throws {
        
        let url = encoding.URLWithURL(URL, method: method, encodingParameters: parameters)
        
        self.init(URL: url)
        
        if let contentType = encoding.contentType(method) {
            setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        HTTPBody = try encoding.body(method, encodingParameters: parameters)
    }
}


extension Session {
    public func GET(path: String, parameters: [String: AnyObject] = [:], encoding: ParameterEncoding = .URLEncodedInURL) throws -> NSURLRequest {
        
        let url = baseURL.URLByAppendingPathComponent(path)
        
        var paramsPlusPagination = parameters
        paramsPlusPagination["per_page"] = 50
        
        return try NSMutableURLRequest(method: .GET, URL: url, parameters: paramsPlusPagination, encoding: encoding)
    }
    
    public func POST(path: String, parameters: [String: AnyObject] = [:], encoding: ParameterEncoding = .JSON) throws -> NSURLRequest {

        let url = baseURL.URLByAppendingPathComponent(path)
        
        return try NSMutableURLRequest(method: .POST, URL: url, parameters: parameters, encoding: encoding)
    }
}