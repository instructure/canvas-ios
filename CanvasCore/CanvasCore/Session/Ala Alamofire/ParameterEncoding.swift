// ParameterEncoding.swift
//
// Copyright (c) 2014–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
    HTTP method definitions.

    See https://tools.ietf.org/html/rfc7231#section-4.3
*/
public enum Method: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    
    var defaultEncoding: ParameterEncoding {
        switch self {
        case .GET, .HEAD, .DELETE:
            return .url
        default:
            return .json
        }
    }
}

// MARK: ParameterEncoding

/**
    Used to specify the way in which a set of parameters are applied to a URL request.

    - `URL`:             Creates a query string to be set as or appended to any existing URL query for `GET`, `HEAD`, 
                         and `DELETE` requests, or set as the body for requests with any other HTTP method. The 
                         `Content-Type` HTTP header field of an encoded request with HTTP body is set to
                         `application/x-www-form-urlencoded; charset=utf-8`. Since there is no published specification
                         for how to encode collection types, the convention of appending `[]` to the key for array
                         values (`foo[]=1&foo[]=2`), and appending the key surrounded by square brackets for nested
                         dictionary values (`foo[bar]=baz`).

    - `URLEncodedInURL`: Creates query string to be set as or appended to any existing URL query. Uses the same
                         implementation as the `.url` case, but always applies the encoded result to the URL.

    - `JSON`:            Uses `NSJSONSerialization` to create a JSON representation of the parameters object, which is 
                         set as the body of the request. The `Content-Type` HTTP header field of an encoded request is 
                         set to `application/json`.

*/
public enum ParameterEncoding {
    case url
    case urlEncodedInURL
    case json
    
    func encodesParametersInURL(_ method: Method) -> Bool {
        if case .urlEncodedInURL = self {
            return true
        }
        
        switch (self, method) {
        case (.url, .GET), (.url, .HEAD), (.url, .DELETE):
            return true
        default:
            return false
        }

    }
    
    func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }

    
    public func URLWithURL(_ URL: URL, method: Method, encodingParameters parameters: [String: Any]) -> URL {
        guard parameters.count > 0 else { return URL }
        guard encodesParametersInURL(method) else { return URL }
        
        guard var components = URLComponents(url: URL, resolvingAgainstBaseURL: false) else { return URL }
        
        let percentEncodedQuery = (components.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
        components.percentEncodedQuery = percentEncodedQuery
        return components.url ?? URL
    }
    
    func contentType(_ method: Method) -> String? {
        guard !encodesParametersInURL(method) else { return nil }
        
        switch self {
        case .url:
            return "application/x-www-form-urlencoded; charset=utf-8"
        case .json:
            return "application/json"
        default:
            return nil
        }
    }
    
    func body(_ method: Method, encodingParameters parameters: [String: Any]) throws -> Data? {
        guard !encodesParametersInURL(method) && !parameters.isEmpty else { return nil }

        switch self {
        case .url:
            let encoded = query(parameters)
            return encoded.data(using: String.Encoding.utf8, allowLossyConversion: false)
        case .json:
            let options = JSONSerialization.WritingOptions()
            return try JSONSerialization.data(withJSONObject: parameters, options: options)
        default:
            return nil
        }
    }

    /**
        Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.

        - parameter key:   The key of the query component.
        - parameter value: The value of the query component.

        - returns: The percent-escaped, URL encoded query string components.
    */
    public func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }
    
    /**
        Returns a percent-escaped string following RFC 3986 for a query string key or value.

        RFC 3986 states that the following characters are "reserved" characters.

        - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
        - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="

        In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
        query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
        should be percent-escaped in the query string.

        - parameter string: The string to be percent-escaped.

        - returns: The percent-escaped string.
    */
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)

        var escaped = ""

        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinense characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================

        escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
        return escaped
    }
}


extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
