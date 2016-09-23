//
//  Request.swift
//  Quizzes
//
//  Created by Derrick Hathaway on 12/30/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import Result

import TooLegit

// MARK: Canvas Auth and basic requests

/**
Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.
*/
let defaultHTTPHeaders: [String: String] = {
    // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
    let acceptEncoding: String = "gzip;q=1.0,compress;q=0.5"
    
    // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
    let acceptLanguage: String = {
        var components: [String] = []
        for (index, languageCode) in (NSLocale.preferredLanguages() as [String]).enumerate() {
            let q = 1.0 - (Double(index) * 0.1)
            components.append("\(languageCode);q=\(q)")
            if q <= 0.5 {
                break
            }
        }
        
        return components.joinWithSeparator(",")
        }()
    
    // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
    let userAgent: String = {
        if let info = NSBundle.mainBundle().infoDictionary {
            let executable: AnyObject = info[kCFBundleExecutableKey as String] ?? "Unknown"
            let bundle: AnyObject = info[kCFBundleIdentifierKey as String] ?? "Unknown"
            let version: AnyObject = info[kCFBundleVersionKey as String] ?? "Unknown"
            let os: AnyObject = NSProcessInfo.processInfo().operatingSystemVersionString ?? "Unknown"
            
            var mutableUserAgent = NSMutableString(string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
            let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString
            
            if CFStringTransform(mutableUserAgent, UnsafeMutablePointer<CFRange>(nil), transform, false) {
                return mutableUserAgent as String
            }
        }
        
        return "Alamofire"
        }()
    
    return [
        "Accept-Encoding": acceptEncoding,
        "Accept-Language": acceptLanguage,
        "User-Agent": userAgent
    ]
    }()



/**
HTTP method definitions.

See http://tools.ietf.org/html/rfc7231#section-4.3
*/
enum HTTPMethod: String {
    case OPTIONS = "OPTIONS"
    case GET = "GET"
    case HEAD = "HEAD"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
    case TRACE = "TRACE"
    case CONNECT = "CONNECT"
    
    static func encodesParametersInURL(method: HTTPMethod) -> Bool {
        switch method {
        case .GET, .HEAD, .DELETE:
            return true
        default:
            return false
        }
    }
}


/**
Used to specify the way in which a set of parameters are applied to a URL request.
*/
enum ParameterEncoding {
    case URL
    case JSON
    
    private func encode(request: NSURLRequest, parameters: [String: AnyObject]) -> Result<NSURLRequest, NSError> {
        let mutableURLRequest = request.mutableCopy() as! NSMutableURLRequest
        var encodingError: NSError?
        
        switch self {
        case .URL:
            func query(parameters: [String: AnyObject]) -> String {
                var components: [(String, String)] = []
                for key in Array(parameters.keys).sort(<) {
                    let value = parameters[key]!
                    components += queryComponents(key, value)
                }
                
                return (components.map { "\($0)=\($1)" } as [String]).joinWithSeparator("&")
            }
            
            if let method = HTTPMethod(rawValue: mutableURLRequest.HTTPMethod) where HTTPMethod.encodesParametersInURL(method) {
                if let URLComponents = NSURLComponents(URL: mutableURLRequest.URL!, resolvingAgainstBaseURL: false) {
                    let percentEncodedQuery = (URLComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                    URLComponents.percentEncodedQuery = percentEncodedQuery
                    mutableURLRequest.URL = URLComponents.URL
                }
            } else {
                if mutableURLRequest.valueForHTTPHeaderField("Content-Type") == nil {
                    mutableURLRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                }
                
                mutableURLRequest.HTTPBody = query(parameters).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            }
        case .JSON:
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
                
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = data
            } catch {
                encodingError = error as NSError
            }
        }
        
        if let encodingError = encodingError {
            return Result(error: encodingError)
        } else {
            return Result(value: mutableURLRequest)
        }
    }
    
    // The following 2 functions are ripped out of Alamofire...
    
    /**
    Creates percent-escaped, URL encoded query string components from the given key-value pair using recursion.
    
    - parameter key:   The key of the query component.
    - parameter value: The value of the query component.
    - returns: The percent-escaped, URL encoded query string components.
    */
    func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
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
    func escape(string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
        
        return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? ""
    }
}

/// Encapsulates a single API request.
struct Request<T>: CustomStringConvertible {
    typealias ResultType = Result<T, NSError>
    let auth: Session
    let method: HTTPMethod
    let url: NSURL
    let parameters: [String: AnyObject]?
    let parameterEncoding: ParameterEncoding? // to force a specific encoding, if desired, otherwise inferred from method
    let parseResponse: AnyObject?->ResultType
    
    var description: String{
        var description = "AuthKit.Request<\(T.self)>\n"
        description += "\tauth:\(auth)\n"
        description += "\tmethod:\(method.rawValue)\n"
        description += "\turl:\(url)\n"
        description += "\tparameters:\(parameters)\n"
        description += "\tparameterEncoding:\(parameterEncoding)\n"
        return description
    }
    
    init(auth: Session, method: HTTPMethod, path: String, parameters: [String: AnyObject]? = nil, parameterEncoding: ParameterEncoding? = nil, parseResponse: AnyObject?->ResultType) {
        self.auth = auth
        self.method = method
        self.url = self.auth.baseURL.URLByAppendingPathComponent(path)
        self.parameters = parameters
        self.parameterEncoding = parameterEncoding
        self.parseResponse = parseResponse
    }
    
    init(auth: Session, method: HTTPMethod, url: NSURL, parameters: [String: AnyObject]? = nil, parameterEncoding: ParameterEncoding? = nil, parseResponse: AnyObject?->ResultType) {
        self.auth = auth
        self.method = method
        self.url = url
        self.parameters = parameters
        self.parameterEncoding = parameterEncoding
        self.parseResponse = parseResponse
    }
    
    private var URLRequest: Result<NSURLRequest, NSError> {
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        mutableURLRequest.HTTPMethod = method.rawValue
        if let token = auth.token {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var effectiveParameters = parameters ?? [:]
        if let masqueradeID = auth.masqueradeAsUserID {
            effectiveParameters["as_user_id"] = masqueradeID
        }
        
        if parameterEncoding != nil { // if we are forcing a certain encoding use that
            return parameterEncoding!.encode(mutableURLRequest, parameters: effectiveParameters)
        } else if HTTPMethod.encodesParametersInURL(method) { // otherwise just infer from the method type
            return ParameterEncoding.URL.encode(mutableURLRequest, parameters: effectiveParameters)
        } else {
            return ParameterEncoding.JSON.encode(mutableURLRequest, parameters: effectiveParameters)
        }
    }
    
    private func requestForPageWithURL(url: NSURL) -> Request<T> {
        return Request(auth: auth, method: method, url: url, parameters: nil, parseResponse: parseResponse)
    }
}

let requestDebug = false

/**
Executes a `Request`.

The `Result`'s `NSError` may contain an explanation of the error from the Canvas server. This message will be stored in the `NSLocalizedFailureReasonErrorKey`. In addition, if there is a canvas error report id, it will be provided in the `RequestErrorReportIDKey` key as an `Int`.

:param: request The canvas request to perform
:param: completed The response block that will be called with the `Result`. This will be invoked on the main thread.
:return: A handler that can be used to cancel the request
*/
func makeRequest<T>(request: Request<T>, completed: Result<Page<T>, NSError>->()) -> NSURLSessionDataTask? {
    
    let encodingResult = request.URLRequest
    
    if let urlRequest = encodingResult.value {
        let dataTask = request.auth.URLSession.dataTaskWithRequest(urlRequest) { data, response, error in
            if let data = data, httpURLResponse = response as? NSHTTPURLResponse {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    // validate
                    let validatedResult = validate(httpURLResponse, json: json)
                    
                    // parse
                    let contentResult = validatedResult.flatMap(request.parseResponse)
                    
                    // paginate
                    let paginatedResults: Result<Page<T>, NSError> = contentResult.map { content in
                        let nextPageUrl = nextPageURLFromJSON(json, orFromRequestHeaders: httpURLResponse.allHeaderFields)
                        return Page(content: content, nextPage: nextPageUrl.map { return request.requestForPageWithURL($0) })
                    }
                    
                    #if DEBUG
                        if requestDebug {
                            println("make request: \(request)")
                            println("response: \(resp)")
                            println("json: \(json)")
                            println("error: \(error)")
                        }
                    #endif
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        completed(paginatedResults)
                    }
                } catch let e as NSError {
                    dispatch_async(dispatch_get_main_queue()) {
                        completed(Result(error: e))
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let fallbackError = NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("There was no data!", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "")])
                    completed(Result(error: error ?? fallbackError))
                }
            }
        }
        dataTask.resume()
        return dataTask
    } else if let error = encodingResult.error {
        completed(Result(error: error))
    }
    return nil
}

private func nextPageURLFromJSON(json: AnyObject?, orFromRequestHeaders headers: [NSObject: AnyObject]?) -> NSURL? {
    return parseNextPageFromJSONAPI(json) ?? parseNextPageLinkHeader(headers)
}


private let queue = dispatch_queue_create("com.instructure.authkit", DISPATCH_QUEUE_SERIAL)




let RequestErrorReportIDKey = "RequestErrorReportIDKey"
private let RequestErrorDomain = "com.instructure"

private typealias ValidationResult = Result<AnyObject?, NSError>
private func validate(response: NSHTTPURLResponse?, json: AnyObject?) -> ValidationResult {
    let statusCode = response?.statusCode ?? 0
    
    if (200...299).contains(statusCode) {
        return ValidationResult(value: json)
    } else {
        return ValidationResult(error: NSError(domain:RequestErrorDomain , code: statusCode, userInfo: infoForJSON(json)))
    }
}

private func infoForJSON(json: AnyObject?) -> [String: AnyObject] {
    let json = json as? [String: AnyObject]
    
    var info: [String: AnyObject] = [:]
    let localizedDescription = NSLocalizedString("There was a problem with the Canvas request.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.QuizKit")!, value: "", comment: "generic error message")
    
    if let message = json?["message"] as? String {
        info[NSLocalizedFailureReasonErrorKey] = message
    }
    
    if let reportID = json?["error_report_id"] as? Int {
        info[RequestErrorReportIDKey] = reportID
    }
    
    info[NSLocalizedDescriptionKey] = localizedDescription
    
    return info
}