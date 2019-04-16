//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import Result
import ReactiveSwift
import Marshal


private let networkErrorTitle = NSLocalizedString("Network Error", tableName: "Localizable", bundle: .core, value: "", comment: "Title for network errors")


extension NSError {
    @objc public static func invalidResponseError(_ url: URL?, _ file: String = #file, _ line: UInt = #line) -> NSError {
        let desc = NSLocalizedString("Unexpected response type", tableName: "Localizable", bundle: .core, value: "", comment: "Unexpected response type")
        return NSError(subdomain: "TooLegit", apiURL: url, title: networkErrorTitle, description: desc, file: file, line: line)
    }

    fileprivate static func invalidResponse(_ response: HTTPURLResponse, data: Data, _ file: String = #file, _ line: UInt = #line) -> NSError {

        let desc = NSLocalizedString("There was an error while communicating with the server.", tableName: "Localizable", bundle: .core, value: "", comment: "Error message for a network fail")
        let reasonTemplate = NSLocalizedString("Expected a response in the 200-299 range. Got %@", tableName: "Localizable", bundle: .core, value: "", comment: "Error message when the server returns a invalid response")
        
        let reason = String.localizedStringWithFormat(reasonTemplate, String(response.statusCode))
        
        return NSError(subdomain: "TooLegit", code: response.statusCode, apiURL: response.url, title: networkErrorTitle, description: desc, failureReason: reason, data: data, file: file, line: line)
    }
}

extension JSONSerialization {
    public static func parseData(_ data: Data, response: HTTPURLResponse) -> Result<(Any, HTTPURLResponse), NSError> {
        do {
            let json = try jsonObject(with: data, options: .allowFragments)
            return .success((json, response))
        } catch let e as NSError {
            if let withoutWhile = dataWithoutWhile(data) {
                return parseData(withoutWhile, response: response)
            }
            return .failure(e)
        }
    }

    private static func dataWithoutWhile(_ data: Data) -> Data? {
        guard let dataString = String(data: data, encoding: .utf8) else {
            return nil
        }
        if dataString.hasPrefix("while(1);") {
            return dataString.dropFirst(9).data(using: .utf8)
        }
        return nil
    }
}

func parseNextPageLinkHeader(_ headers: [AnyHashable: Any]?) -> URL? {
    
    // Link headers look like this:
    // Link: <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=2>; rel="next", <https://api.github.com/search/code?q=addClass+user%3Amozilla&page=34>; rel="last"
    
    if let linkValue = headers?["Link"] as? String {
        let links = linkValue.components(separatedBy: ",")
        
        for link in links {
            let scanner = Scanner(string: link)
            
            // ignore everything up to and including the first <
            scanner.scanString("<", into: nil)
            
            // grab the URL
            var value: NSString?
            scanner.scanUpTo(">", into: &value)
            
            // ignore the trailing >; rel="
            scanner.scanString(">; rel=\"", into: nil)
            
            // now grab the key
            var key: NSString?
            scanner.scanUpTo("\"", into: &key)
            
            if key == "next" {
                if let value = value {
                    return URL(string: value as String)
                }
            }
        }
    }
    
    return nil
}

private func parseNextPageFromJSONAPI(_ JSON: Any, keypath: String? = nil) -> URL? {
    let JSONObject = JSON as? NSDictionary
    let atKeyPath: NSObject? = (keypath.map { JSONObject?.value(forKeyPath: $0) }) as? NSObject ?? JSONObject
    let stringURL = atKeyPath?.value(forKeyPath: "meta.pagination.next") as? String

    return stringURL.flatMap {
        return URL(string: $0)
    }
}

internal func paginateRequest(_ keypath: String? = nil, json: Any, response: HTTPURLResponse) -> (Any, URL?) {
    return (json,
            parseNextPageLinkHeader(response.allHeaderFields) ??
                parseNextPageFromJSONAPI(json, keypath: keypath)
    )
}

public enum JSONObjectResponse {
    case json(JSONObject)
    case error(NSError)
    case interrupted
}

extension Session {
    public func rac_dataWithRequest(_ request: URLRequest) -> SignalProducer<(Data, URLResponse), NSError> {
        return blockProducer { self.URLSession.dataTask(with: request) }
            .promoteError(NSError.self)
            .flatMap(.concat, resumeTask)
    }

    public func resumeTask(_ task: URLSessionTask) -> SignalProducer<(Data, URLResponse), NSError> {
        return SignalProducer { observer, disposable in
            self.completionHandlerByTask[task] = { [weak self] task, error in
                if let data = self?.responseDataByTask[task], let response = task.response {
                    observer.send(value: (data, response))
                    observer.sendCompleted()
                } else {
                    observer.send(error: error ?? NSError.invalidResponseError(task.response?.url))
                }
            }

            disposable.observeEnded {
                task.cancel()
            }

            task.resume()
        }
    }

    fileprivate static func validateResponse(_ data: Data, response: URLResponse) -> Result<(Data, HTTPURLResponse), NSError> {
        guard let httpResponse = response as? HTTPURLResponse else { return Result(error:.invalidResponseError(response.url)) }
        guard (200..<300).contains(httpResponse.statusCode) else { return Result(error:.invalidResponse(httpResponse, data: data)) }

        return Result(value: (data, httpResponse))
    }

    public func emptyResponseSignalProducer(_ request: URLRequest) -> SignalProducer<(), NSError> {
        return rac_dataWithRequest(request)
            .attemptMap { Session.validateResponse($0.0, response: $0.1) }
            .flatMap(.concat, { _ in SignalProducer<(), NSError>.empty })
    }

    fileprivate func JSONAndPaginationSignalProducer(_ request: URLRequest, keypath: String? = nil) -> SignalProducer<(Any, URL?), NSError> {
        return rac_dataWithRequest(request)
            .attemptMap(Session.validateResponse)
            .attemptMap(JSONSerialization.parseData)
            .map { paginateRequest(json: $0.0, response: $0.1) }
    }

    fileprivate static func asJSONObject(_ object: Any) -> SignalProducer<JSONObject, NSError> {
        guard let json = object as? JSONObject else { return SignalProducer(error: MarshalError.typeMismatch(expected: JSONObject.self, actual: type(of: object)) as NSError) }

        return SignalProducer(value: json)
    }

    public func JSONSignalProducer(_ request: URLRequest) -> SignalProducer<JSONObject, NSError> {
        return JSONAndPaginationSignalProducer(request)
            .map { $0.0 }
            .flatMap(.concat, Session.asJSONObject)
    }

    public func JSONSignalProducer(_ task: URLSessionTask) -> SignalProducer<JSONObject, NSError> {
        return resumeTask(task)
            .flatMap(.concat, responseJSONSignalProducer)
    }

    public func responseJSONSignalProducer(_ data: Data, response: URLResponse) -> SignalProducer<JSONObject, NSError> {
        return SignalProducer(value: (data, response))
            .attemptMap(Session.validateResponse)
            .attemptMap(JSONSerialization.parseData)
            .map { $0.0 }
            .flatMap(.concat, Session.asJSONObject)
    }

    fileprivate func appendNextPage(_ request: URLRequest, json: Any, nextPageURL: URL?) -> SignalProducer<Any, NSError> {
        let nextPage: SignalProducer<Any, NSError> = nextPageURL.map { nextPage in
            var nextPageRequest = request
            nextPageRequest.url = nextPage

            return self.paginatedJSONSignalProducerAnyObject(nextPageRequest)
        } ?? SignalProducer.empty

        let currentPage = SignalProducer<Any, NSError>(value: json)

        return currentPage.concat(nextPage)
    }

    fileprivate func paginatedJSONSignalProducerAnyObject(_ request: URLRequest, keypath: String? = nil) -> SignalProducer<Any, NSError> {
        return JSONAndPaginationSignalProducer(request, keypath: keypath)
            .flatMap(.merge) { self.appendNextPage(request, json: $0.0, nextPageURL: $0.1) }
    }

    fileprivate func asArray(_ keypath: String?) -> (Any) -> SignalProducer<[JSONObject], NSError> {
        return { any in
            guard let ns = any as? NSObject else {
                let error = NSError(jsonError: MarshalError.typeMismatch(expected: NSObject.self, actual: type(of: any)), parsingObjectOfType: NSObject.self)
                return SignalProducer(error: error)
            }

            let atKeyPath: NSObject = (keypath.map { ns.value(forKeyPath: $0) }) as? NSObject ?? ns
            guard let array = atKeyPath as? [JSONObject] else {
                let error = NSError(jsonError: MarshalError.typeMismatchWithKey(key: keypath ?? "", expected: [JSONObject].self, actual: type(of: atKeyPath)), parsingObjectOfType: [JSONObject].self)
                return SignalProducer(error: error)
            }

            return SignalProducer(value: array)
        }
    }

    public func paginatedJSONSignalProducer(_ request: URLRequest, keypath: String? = nil) -> SignalProducer<[JSONObject], NSError> {
        return paginatedJSONSignalProducerAnyObject(request, keypath: keypath)
            .flatMap(.concat, asArray(keypath))
    }

    @discardableResult
    public func makeRequest<T>(_ request: URLRequest, callback: @escaping (Result<T, NSError>) -> Void) -> URLSessionTask where T: Decodable {
        let task = URLSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                callback(.failure(error as NSError))
                return
            }

            guard let data = data else {
                callback(.failure(.invalidResponseError(request.url)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                callback(.success(result))
            } catch {
                callback(.failure(error as NSError))
            }
        }

        task.resume()
        return task
    }
}
