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
    
    

import UIKit
import Result



// MARK: Canvas Auth and basic requests

/// Encapsulates a single API request.
struct Request<T>: CustomStringConvertible {
    typealias ResultType = Result<T, NSError>
    let auth: Session
    let method: Method
    let url: URL
    let parameters: [String: Any]?
    let parameterEncoding: ParameterEncoding? // to force a specific encoding, if desired, otherwise inferred from method
    let parseResponse: (Any?)->ResultType
    
    var description: String{
        var description = "AuthKit.Request<\(T.self)>\n"
        description += "\tauth:\(auth)\n"
        description += "\tmethod:\(method.rawValue)\n"
        description += "\turl:\(url)\n"
        description += "\tparameters:\(String(describing: parameters))\n"
        description += "\tparameterEncoding:\(String(describing: parameterEncoding))\n"
        return description
    }
    
    init(auth: Session, method: Method, path: String, parameters: [String: Any]? = nil, parameterEncoding: ParameterEncoding? = nil, parseResponse: @escaping (Any?)->ResultType) {
        self.auth = auth
        self.method = method
        self.url = self.auth.baseURL.appendingPathComponent(path)
        self.parameters = parameters
        self.parameterEncoding = parameterEncoding
        self.parseResponse = parseResponse
    }
    
    init(auth: Session, method: Method, url: URL, parameters: [String: Any]? = nil, parameterEncoding: ParameterEncoding? = nil, parseResponse: @escaping (Any?)->ResultType) {
        self.auth = auth
        self.method = method
        self.url = url
        self.parameters = parameters
        self.parameterEncoding = parameterEncoding
        self.parseResponse = parseResponse
    }
    
    fileprivate var request: Result<URLRequest, NSError> {
        return Result() {
            try URLRequest(method: method, URL: url, parameters: parameters ?? [:], encoding: parameterEncoding)
                .authorized(with: auth)
        }
    }
    
    fileprivate func requestForPageWithURL(_ url: URL) -> Request<T> {
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
func makeRequest<T>(_ request: Request<T>, completed: @escaping (Result<ResponsePage<T>, NSError>)->()) -> URLSessionDataTask? {
    
    let encodingResult = request.request
    
    if let urlRequest = encodingResult.value {
        let dataTask = request.auth.URLSession.dataTask(with: urlRequest as URLRequest) { data, response, error in
            if let data = data, let httpURLResponse = response as? HTTPURLResponse {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                    // validate
                    let validatedResult = validate(httpURLResponse, json: json)
                    
                    // parse
                    let contentResult = validatedResult.flatMap(request.parseResponse)
                    
                    // paginate
                    let paginatedResults: Result<ResponsePage<T>, NSError> = contentResult.map { content in
                        let nextPageUrl = nextPageURLFromJSON(json, orFromRequestHeaders: httpURLResponse.allHeaderFields)
                        return ResponsePage(content: content, nextPage: nextPageUrl.map { return request.requestForPageWithURL($0) })
                    }
                    
                    DispatchQueue.main.async {
                        completed(paginatedResults)
                    }
                } catch let e as NSError {
                    DispatchQueue.main.async {
                        completed(Result(error: e))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let fallbackError = NSError(domain: "com.instructure", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("There was no data!", tableName: "Localizable", bundle: .core, value: "", comment: "")])
                    let error = (error as NSError?) ?? fallbackError
                    completed(Result<ResponsePage<T>, NSError>(error: error))
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

private func nextPageURLFromJSON(_ json: Any?, orFromRequestHeaders headers: [AnyHashable: Any]?) -> URL? {
    return parseNextPageFromJSONAPI(json) ?? parseNextPageLinkHeader(headers)
}


private let queue = DispatchQueue(label: "com.instructure.authkit", attributes: [])




let RequestErrorReportIDKey = "RequestErrorReportIDKey"
private let RequestErrorDomain = "com.instructure"

private typealias ValidationResult = Result<Any?, NSError>
private func validate(_ response: HTTPURLResponse?, json: Any?) -> ValidationResult {
    let statusCode = response?.statusCode ?? 0
    
    if (200...299).contains(statusCode) {
        return ValidationResult(value: json)
    } else {
        return ValidationResult(error: NSError(domain:RequestErrorDomain , code: statusCode, userInfo: infoForJSON(json)))
    }
}

private func infoForJSON(_ json: Any?) -> [String: Any] {
    let json = json as? [String: Any]
    
    var info: [String: Any] = [:]
    let localizedDescription = NSLocalizedString("There was a problem with the Canvas request.", tableName: "Localizable", bundle: .core, value: "", comment: "generic error message")
    
    if let message = json?["message"] as? String {
        info[NSLocalizedFailureReasonErrorKey] = message
    }
    
    if let reportID = json?["error_report_id"] as? Int {
        info[RequestErrorReportIDKey] = reportID
    }
    
    info[NSLocalizedDescriptionKey] = localizedDescription
    
    return info
}
