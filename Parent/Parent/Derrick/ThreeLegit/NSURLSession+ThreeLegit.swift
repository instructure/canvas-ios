//
//  NSURLSession+ThreeLegit.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import Result
import ReactiveCocoa
import JaSON

extension NSError {
    private static func invalidResponseError() -> NSError {
        return NSError(domain: "com.instructure", code: -1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Invalid response type. Expected NSHTTPURLResponse", comment: "")])
    }

    private static func invalidResponse(response: NSHTTPURLResponse, data: NSData) -> NSError {
        // Holiday Extravaganza TODO: Make some nice errors
        return NSError(domain: "com.instructure", code: response.statusCode, userInfo: [
            NSLocalizedDescriptionKey: NSLocalizedString("Error ...", comment: "")
        ])
    }
}

extension NSJSONSerialization {
    private static func parseData(data: NSData, response: NSHTTPURLResponse) -> Result<(AnyObject, NSHTTPURLResponse), NSError> {
        return Result() { try JSONObjectWithData(data, options: .AllowFragments) }
            .map { ($0, response) }
    }
}

private func parseNextPageLinkHeader(headers: [NSObject: AnyObject]?) -> NSURL? {
    
    // Link headers look like this:
    // Link: <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=2>; rel="next", <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=34>; rel="last"
    
    if let linkValue = headers?["Link"] as? String {
        let links = linkValue.componentsSeparatedByString(",")
        
        for link in links {
            let scanner = NSScanner(string: link)
            
            // ignore everything up to and including the first <
            scanner.scanString("<", intoString: nil)
            
            // grab the URL
            var value: NSString?
            scanner.scanUpToString(">", intoString: &value)
            
            // ignore the trailing >; rel="
            scanner.scanString(">; rel=\"", intoString: nil)
            
            // now grab the key
            var key: NSString?
            scanner.scanUpToString("\"", intoString: &key)
            
            if key == "next" {
                if let value = value {
                    return NSURL(string: value as String)
                }
            }
        }
    }
    
    return nil
}

private func parseNextPageFromJSONAPI(JSON: AnyObject) -> NSURL? {
    let JSONObject = JSON as? NSDictionary
    let stringURL = JSONObject?.valueForKeyPath("meta.pagination.next") as? String
    
    return stringURL.flatMap {
        return NSURL(string: $0)
    }
}

private func paginateRequest(JSON: AnyObject, response: NSHTTPURLResponse) -> (AnyObject, NSURL?) {
    return (JSON,
        parseNextPageLinkHeader(response.allHeaderFields) ??
        parseNextPageFromJSONAPI(JSON)
    )
}

extension NSURLSession {
    private static func validateResponse(data: NSData, response: NSURLResponse) -> Result<(NSData, NSHTTPURLResponse), NSError> {
        guard let httpResponse = response as? NSHTTPURLResponse else { return Result(error:NSError.invalidResponseError()) }
        guard (200..<300).contains(httpResponse.statusCode) else { return Result(error:NSError.invalidResponse(httpResponse, data: data)) }

        return Result(value: (data, httpResponse))
    }
    
    private func JSONAndPaginationSignalProducer(request: NSURLRequest) -> SignalProducer<(AnyObject, NSURL?), NSError> {
        return rac_dataWithRequest(request)
            .attemptMap(NSURLSession.validateResponse)
            .attemptMap(NSJSONSerialization.parseData)
            .map(paginateRequest)
    }
    
    private static func asJSONObject(object: AnyObject) -> SignalProducer<JSONObject, NSError> {
        guard let json = object as? JSONObject else { return SignalProducer(error: JSONError.TypeMismatch(expected: JSONObject.self, actual: object.dynamicType) as NSError) }
        
        return SignalProducer(value: json)
    }
    
    public func JSONSignalProducer(request: NSURLRequest) -> SignalProducer<JSONObject, NSError> {
        return JSONAndPaginationSignalProducer(request)
            .map { $0.0 }
            .flatMap(.Concat, transform: NSURLSession.asJSONObject)
    }
    
    private func appendNextPage(request: NSURLRequest) -> (JSON: AnyObject, nextPageURL: NSURL?) -> SignalProducer<AnyObject, NSError> {
        return { (JSON: AnyObject, nextPageURL: NSURL?) -> SignalProducer<AnyObject, NSError> in
            let nextPage: SignalProducer<AnyObject, NSError> = nextPageURL.map { nextPage in
                guard let nextPageRequest = request.mutableCopy() as? NSMutableURLRequest else { fatalError("Wut? this is a thing?") }
                nextPageRequest.URL = nextPage
                
                return self.paginatedJSONSignalProducerAnyObject(nextPageRequest)
                } ?? SignalProducer.empty
            
            let currentPage = SignalProducer<AnyObject, NSError>(value: JSON)
            
            return currentPage.concat(nextPage)
        }
    }

    private func paginatedJSONSignalProducerAnyObject(request: NSURLRequest) -> SignalProducer<AnyObject, NSError> {
        return JSONAndPaginationSignalProducer(request)
            .flatMap(.Concat, transform: appendNextPage(request))
    }
    
    private func flattenArray(keypath: String?) -> AnyObject -> SignalProducer<JSONObject, NSError> {
        return { any in
            guard let ns = any as? NSObject else { return SignalProducer(error: JSONError.TypeMismatch(expected: NSObject.self, actual: any.dynamicType) as NSError) }
            
            let atKeyPath: NSObject = (keypath.map { ns.valueForKeyPath($0) }) as? NSObject ?? ns
            print("atKeyPath == \(atKeyPath)")
            guard let array = atKeyPath as? JSONObjectArray else { return SignalProducer(error: JSONError.TypeMismatchWithKey(key: keypath ?? "", expected: JSONObjectArray.self, actual: atKeyPath.dynamicType) as NSError) }
            
            return SignalProducer(values: array)
        }
    }
    
    public func paginatedJSONSignalProducer(request: NSURLRequest, keypath: String? = nil) -> SignalProducer<JSONObject, NSError> {
        return paginatedJSONSignalProducerAnyObject(request)
            .flatMap(.Concat, transform: flattenArray(keypath))
    }
}