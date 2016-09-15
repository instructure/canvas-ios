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
import Marshal
import SoLazy

private let networkErrorTitle = NSLocalizedString("Network Error", comment: "Title for network errors")


extension NSError {
    public static func invalidResponseError(url: NSURL?, _ file: String = #file, _ line: UInt = #line) -> NSError {
        let desc = NSLocalizedString("Unexpected response type", comment: "Unexpected response type")
        return NSError(subdomain: "TooLegit", apiURL: url, title: networkErrorTitle, description: desc, file: file, line: line)
    }

    private static func invalidResponse(response: NSHTTPURLResponse, data: NSData, _ file: String = #file, _ line: UInt = #line) -> NSError {
        let desc = NSLocalizedString("There was an error while communicating with the server.", comment: "Error message for a network fail")
        let reason = "Expected a response in the 200-299 range. Got \(response.statusCode) \(String(data: data, encoding: NSUTF8StringEncoding))"
        return NSError(subdomain: "TooLegit", code: response.statusCode, apiURL: response.URL, title: networkErrorTitle, description: desc, failureReason: reason, data: data, file: file, line: line)
    }
}

extension NSJSONSerialization {
    public static func parseData(data: NSData, response: NSHTTPURLResponse) -> Result<(AnyObject, NSHTTPURLResponse), NSError> {
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

private func parseNextPageFromJSONAPI(JSON: AnyObject, keypath: String? = nil) -> NSURL? {
    let JSONObject = JSON as? NSDictionary
    let atKeyPath: NSObject? = (keypath.map { JSONObject?.valueForKeyPath($0) }) as? NSObject ?? JSONObject
    let stringURL = atKeyPath?.valueForKeyPath("meta.pagination.next") as? String

    return stringURL.flatMap {
        return NSURL(string: $0)
    }
}

internal func paginateRequest(keypath: String? = nil) -> (JSON: AnyObject, response: NSHTTPURLResponse) -> (AnyObject, NSURL?) {
    return { JSON, response in
        return (JSON,
                parseNextPageLinkHeader(response.allHeaderFields) ??
                    parseNextPageFromJSONAPI(JSON, keypath: keypath)
        )
    }
}

public enum JSONObjectResponse {
    case JSON(JSONObject)
    case Error(NSError)
    case Interrupted
}

extension Session {
    public func rac_dataWithRequest(request: NSURLRequest) -> SignalProducer<(NSData, NSURLResponse), NSError> {
        return blockProducer { self.URLSession.dataTaskWithRequest(request) }
            .flatMapError { _ in .empty }
            .flatMap(.Concat, transform: resumeTask)
    }

    public func resumeTask(task: NSURLSessionTask) -> SignalProducer<(NSData, NSURLResponse), NSError> {
        return SignalProducer { observer, disposable in
            self.completionHandlerByTask[task] = { [weak self] task, error in
                if let data = self?.responseDataByTask[task], response = task.response {
                    observer.sendNext((data, response))
                    observer.sendCompleted()
                } else {
                    observer.sendFailed(error ?? NSError.invalidResponseError(task.response?.URL))
                }
            }

            disposable.addDisposable {
                task.cancel()
            }

            task.resume()
        }
    }

    private static func validateResponse(data: NSData, response: NSURLResponse) -> Result<(NSData, NSHTTPURLResponse), NSError> {
        guard let httpResponse = response as? NSHTTPURLResponse else { return Result(error:.invalidResponseError(response.URL)) }
        guard (200..<300).contains(httpResponse.statusCode) else { return Result(error:.invalidResponse(httpResponse, data: data)) }

        return Result(value: (data, httpResponse))
    }

    public func emptyResponseSignalProducer(request: NSURLRequest) -> SignalProducer<(), NSError> {
        return rac_dataWithRequest(request)
            .attemptMap(Session.validateResponse)
            .flatMap(.Concat, transform: { _ in SignalProducer.empty })
    }

    private func JSONAndPaginationSignalProducer(request: NSURLRequest, keypath: String? = nil) -> SignalProducer<(AnyObject, NSURL?), NSError> {
        return rac_dataWithRequest(request)
            .attemptMap(Session.validateResponse)
            .attemptMap(NSJSONSerialization.parseData)
            .map(paginateRequest(keypath))
    }

    private static func asJSONObject(object: AnyObject) -> SignalProducer<JSONObject, NSError> {
        guard let json = object as? JSONObject else { return SignalProducer(error: Error.TypeMismatch(expected: JSONObject.self, actual: object.dynamicType) as NSError) }

        return SignalProducer(value: json)
    }

    public func JSONSignalProducer(request: NSURLRequest) -> SignalProducer<JSONObject, NSError> {
        return JSONAndPaginationSignalProducer(request)
            .map { $0.0 }
            .flatMap(.Concat, transform: Session.asJSONObject)
    }

    public func JSONSignalProducer(task: NSURLSessionTask) -> SignalProducer<JSONObject, NSError> {
        return resumeTask(task)
            .flatMap(.Concat, transform: responseJSONSignalProducer)
    }

    public func responseJSONSignalProducer(data: NSData, response: NSURLResponse) -> SignalProducer<JSONObject, NSError> {
        return SignalProducer(value: (data, response))
            .attemptMap(Session.validateResponse)
            .attemptMap(NSJSONSerialization.parseData)
            .map { $0.0 }
            .flatMap(.Concat, transform: Session.asJSONObject)
    }

    private func appendNextPage(request: NSURLRequest) -> (JSON: AnyObject, nextPageURL: NSURL?) -> SignalProducer<AnyObject, NSError> {
        return { (JSON: AnyObject, nextPageURL: NSURL?) -> SignalProducer<AnyObject, NSError> in
            let nextPage: SignalProducer<AnyObject, NSError> = nextPageURL.map { nextPage in
                guard let nextPageRequest = request.mutableCopy() as? NSMutableURLRequest else { ❨╯°□°❩╯⌢"Wut? this is a thing?" }
                nextPageRequest.URL = nextPage

                return self.paginatedJSONSignalProducerAnyObject(nextPageRequest)
                } ?? SignalProducer.empty

            let currentPage = SignalProducer<AnyObject, NSError>(value: JSON)

            return currentPage.concat(nextPage)
        }
    }

    private func paginatedJSONSignalProducerAnyObject(request: NSURLRequest, keypath: String? = nil) -> SignalProducer<AnyObject, NSError> {
        return JSONAndPaginationSignalProducer(request, keypath: keypath)
            .flatMap(.Merge, transform: appendNextPage(request))
    }

    private func asArray(keypath: String?) -> AnyObject -> SignalProducer<[JSONObject], NSError> {
        return { any in
            guard let ns = any as? NSObject else { return SignalProducer(error: Error.TypeMismatch(expected: NSObject.self, actual: any.dynamicType) as NSError) }

            let atKeyPath: NSObject = (keypath.map { ns.valueForKeyPath($0) }) as? NSObject ?? ns
            guard let array = atKeyPath as? [JSONObject] else { return SignalProducer(error: Error.TypeMismatchWithKey(key: keypath ?? "", expected: [JSONObject].self, actual: atKeyPath.dynamicType) as NSError) }

            return SignalProducer(value: array)
        }
    }

    public func paginatedJSONSignalProducer(request: NSURLRequest, keypath: String? = nil) -> SignalProducer<[JSONObject], NSError> {
        return paginatedJSONSignalProducerAnyObject(request, keypath: keypath)
            .flatMap(.Concat, transform: asArray(keypath))
    }
}
