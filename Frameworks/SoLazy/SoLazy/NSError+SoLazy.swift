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
    
    public var title: String {
        return (userInfo[ErrorTitleKey] as? String) ?? NSLocalizedString("Unknown Error", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, value: "", comment: "SoLazy's fallback title for an unknown error")
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



// MARK: Reporting
extension NSError {
    
    /// Reports an error either to the user, to the error reporter, or both
    public func report(_ externally: Bool = true, alertUserFrom: UIViewController? = nil, onDismiss: (() -> ())? = nil) {
        
        print(reportDescription)
     
        if externally {
            ErrorReporter.sharedErrorReporter.reportError(self)
        }
        
        guard let viewController = alertUserFrom else { return }
        
        let alert: UIAlertController
        
        if externally {
            let title = NSLocalizedString("Error", bundle: .soLazy(), comment: "Title for an error alert")
            let messageTemplate = NSLocalizedString("An unexpected error occured. %@(%@)", bundle: .soLazy(), comment: "Message for an error alert")
            let message = String.localizedStringWithFormat(messageTemplate, self.domain, String(self.code))
            alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        }
        else {

            let reason = localizedFailureReason.map( { NSLocalizedString("Explanation:", bundle: .soLazy(), value: "Explanation:", comment: "attached to error explanation in dialog") + $0 } ) ?? ""
            
            let description = "\(localizedDescription)\n\n\(reason)"
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        }
        
        let dismissTitle = NSLocalizedString("Dismiss", bundle: .soLazy(), value: "Dismiss", comment: "Dismiss an error dialog")
        let action = UIAlertAction(title: dismissTitle, style: .default) { _ in
            onDismiss?()
        }
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

// MARK: Alert

extension NSError {
    open func presentAlertFromViewController(_ viewController: UIViewController, alertDismissed: (()->())? = nil, reportError: (()->())? = nil) {
        print(self.reportDescription)
        
        let reason = localizedFailureReason.map( { NSLocalizedString("Explanation:", bundle: .soLazy(), value: "Explanation:", comment: "attached to error explanation in dialog") + $0 } ) ?? ""
        
        let description = "\(localizedDescription)\n\n\(reason)"
        
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        if let report = reportError {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Report", bundle: .soLazy(), value: "Report", comment: "Option to report an error"), style: .default, handler: { _ in
                report()
            }))
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", bundle: .soLazy(), value: "Dismiss", comment: "Dismiss an error dialog"), style: .cancel, handler: { _ in
            alertDismissed?()
        }))
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    public var reportDescription: String {
        var report = "===== Error Report \(domain)–\(code) =====\n"
        
        for (key, value) in userInfo {
            if (key as? String) == NSUnderlyingErrorKey { continue } // handled separately
            report += "🔑 \(key): \(value)\n"
        }
        
        let underlying = (userInfo[NSUnderlyingErrorKey] as? [NSError])
            ?? (userInfo[NSUnderlyingErrorKey] as? NSError).map { [$0] }
            ?? []
        
        for error in underlying {
            report += "===== 💣 Underlying Error =====\n"
            report += error.reportDescription
            report += "===== End Underlying Error =====\n"
        }
        
        report += "===== End Error Report =====\n"
        
        return report
    }
    
    public convenience init(jsonError: MarshalError, file: String = #file, line: UInt = #line) {
        let reason: String
        switch jsonError {
        case let .typeMismatch(expected: expected, actual: actual):
            reason = "Expected \(expected) but found \(actual)"
        case let .typeMismatchWithKey(key: key, expected: expected, actual: actual):
            reason = "Expected \(expected) but found \(actual) for key: \(key)"
        case .keyNotFound(key: let key):
            reason = "Expected a value for \(key)"
        case .nullValue(key: let key):
            reason = "Unexpected null value for \(key)"
        }

        let errorDescription = NSLocalizedString("There was a problem interpreting a response from the server.", bundle: .soLazy(), value: "There was a problem interpreting a response from the server.", comment: "JSON Parsing error description")



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
private let ErrorTitleKey = "YeOldeErrorTitleKey" // written before 7:15 am.
private let ErrorFileNameKey = "YeOldeErrorFileNameKey"
private let ErrorLineNumberKey = "YeOldeErrorLineNumberKey"
private let ErrorSubdomainKey = "YeOldeErrorSubdomainKey"
private let ErrorSessionIDKey = "YeOldeErrorSessionIDKey"
private let ErrorDataKey = "YeOldeErrorDataKey"
private let ErrorURLKey = "YeOldeErrorURLKey"
