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
import Foundation
import Marshal

extension NSError {
    public convenience init(subdomain: String, code: Int = 0, sessionID: String? = nil, apiURL: URL? = nil, title: String? = nil, description: String, failureReason: String? = nil, data: Data? = nil, file: String = #file, line: UInt = #line) {

        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: description,
            ErrorFileNameKey: file,
            ErrorLineNumberKey: line,
            ErrorSubdomainKey: subdomain,
            ]
        
        if let t = title            { userInfo[ErrorTitleKey] = t }
        if let s = sessionID        { userInfo[ErrorSessionIDKey] = s }
        if let f = failureReason    { userInfo[NSLocalizedFailureReasonErrorKey] = f }
        if let a = apiURL           { userInfo[ErrorURLKey] = a }
        if let d = data             { userInfo[ErrorDataKey] = d }

        self.init(domain: "com.instructure." + subdomain, code: code, userInfo: userInfo)
    }
    
    public var title: String? {
        return (userInfo[ErrorTitleKey] as? String)
    }
    
    public var fileName: String {
        return (userInfo[ErrorFileNameKey] as? String) ?? "Unknown"
    }
    
    public var lineNumber: UInt {
        return (userInfo[ErrorLineNumberKey] as? UInt) ?? 0
    }
    
    public var subdomain: String {
        return (userInfo[ErrorLineNumberKey] as? String) ?? "unknown"
    }
    
    public var sessionID: String {
        return (userInfo[ErrorSessionIDKey] as? String) ?? "Unknown"
    }

    public var data: Data? {
        return (userInfo[ErrorDataKey] as? Data) ?? nil
    }
    
    public var url: String {
        return (userInfo[ErrorURLKey] as? URL)
            .flatMap({ $0.absoluteString }) ?? ""
    }
}


// MARK: Alert

extension NSError {
    public var underlyingErrors: [NSError] {
        return (userInfo[NSUnderlyingErrorKey] as? [NSError])
            ?? (userInfo[NSUnderlyingErrorKey] as? NSError).map { [$0] }
            ?? []
    }
    
    public var reportDescription: String {
        var report = "===== Error Report \(domain)–\(code) =====\n"
        
        for (key, value) in userInfo {
            if (key as? String) == NSUnderlyingErrorKey { continue } // handled separately
            report += "🔑 \(key): \(value)\n"
        }
        
        for error in underlyingErrors {
            report += "===== 💣 Underlying Error =====\n"
            report += error.reportDescription
            report += "===== End Underlying Error =====\n"
        }
        
        report += "===== End Error Report =====\n"
        
        return report
    }
    
    public convenience init<T>(jsonError: MarshalError, parsingObjectOfType objectType: T.Type, file: String = #file, line: UInt = #line) {
        let reason: String
        switch jsonError {
        case let .typeMismatch(expected: expected, actual: actual):
            reason = "While parsing \(objectType), expected \(expected) but found \(actual)"
        case let .typeMismatchWithKey(key: key, expected: expected, actual: actual):
            reason = "While parsing \(objectType), expected \(expected) but found \(actual) for key: \(key)"
        case .keyNotFound(key: let key):
            reason = "While parsing \(objectType), expected a value for \(key)"
        case .nullValue(key: let key):
            reason = "While parsing \(objectType), unexpected null value for \(key)"
        }

        let errorDescription = NSLocalizedString("There was a problem interpreting a response from the server.", bundle: .core, value: "There was a problem interpreting a response from the server.", comment: "JSON Parsing error description")

        self.init(subdomain: "SoLazy", description: errorDescription, failureReason: reason, file: file, line: line)
    }
    
    public func addingInfo(_ file: String = #file, line: UInt = #line) -> NSError {
        guard userInfo[ErrorFileNameKey] == nil else { return self }
        
        var info = userInfo
        info[ErrorFileNameKey] = file
        info[ErrorLineNumberKey] = line
        
        return NSError(domain: domain, code: code, userInfo: info)
    }
}


// MARK: Ye Old Keys
private let ErrorTitleKey = "title" // written before 7:15 am.
private let ErrorFileNameKey = "file_name"
private let ErrorLineNumberKey = "line_number"
private let ErrorSubdomainKey = "framework"
private let ErrorSessionIDKey = "session_id"
private let ErrorDataKey = "server_response"
private let ErrorURLKey = "request_url"
