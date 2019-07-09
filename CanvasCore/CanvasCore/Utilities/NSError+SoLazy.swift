//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import Foundation
import Marshal

extension NSError {
    @objc public convenience init(subdomain: String, code: Int = 0, sessionID: String? = nil, apiURL: URL? = nil, title: String? = nil, description: String, failureReason: String? = nil, data: Data? = nil, file: String = #file, line: UInt = #line) {

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
        if let d = data             { userInfo[ErrorDataKey] = String(data: d, encoding: .utf8) }

        self.init(domain: "com.instructure." + subdomain, code: code, userInfo: userInfo)
    }
    
    @objc public var title: String? {
        return (userInfo[ErrorTitleKey] as? String)
    }
    
    @objc public var fileName: String {
        return (userInfo[ErrorFileNameKey] as? String) ?? "Unknown"
    }
    
    @objc public var lineNumber: UInt {
        return (userInfo[ErrorLineNumberKey] as? UInt) ?? 0
    }
    
    @objc public var subdomain: String {
        return (userInfo[ErrorLineNumberKey] as? String) ?? "unknown"
    }
    
    @objc public var sessionID: String {
        return (userInfo[ErrorSessionIDKey] as? String) ?? "Unknown"
    }

    @objc public var data: String? {
        if let string = userInfo[ErrorDataKey] as? String {
            return string
        }
        if let data = userInfo[ErrorDataKey] as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    @objc public var url: String {
        return (userInfo[ErrorURLKey] as? URL)
            .flatMap({ $0.absoluteString }) ?? ""
    }
}


// MARK: Alert

extension NSError {
    @objc public var underlyingErrors: [NSError] {
        return (userInfo[NSUnderlyingErrorKey] as? [NSError])
            ?? (userInfo[NSUnderlyingErrorKey] as? NSError).map { [$0] }
            ?? []
    }
    
    @objc public var reportDescription: String {
        var report = "===== Error Report \(domain)–\(code) =====\n"
        
        for (key, value) in userInfo {
            if key == NSUnderlyingErrorKey { continue } // handled separately
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
    
    @objc public func addingInfo(_ file: String = #file, line: UInt = #line) -> NSError {
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
