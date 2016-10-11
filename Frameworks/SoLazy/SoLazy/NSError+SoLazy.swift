//
//  NSError+SoLazy.swift
//  SoLazy
//
//  Created by Derrick Hathaway on 1/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import Marshal

extension NSError {
    public convenience init(subdomain: String, code: Int = 0, sessionID: String? = nil, apiURL: NSURL? = nil, title: String? = nil, description: String, failureReason: String? = nil, data: NSData? = nil, file: String = #file, line: UInt = #line) {

        var userInfo: [String: AnyObject] = [
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
        return (userInfo[ErrorTitleKey] as? String) ?? NSLocalizedString("Unknown Error", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.icanvas.SoLazy")!, value: "", comment: "SoLazy's fallback title for an unknown error")
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

    public var data: NSData? {
        return (userInfo[ErrorDataKey] as? NSData) ?? nil
    }
    
    public var url: String {
        return (userInfo[ErrorURLKey] as? NSURL)
            .flatMap({ $0.absoluteString }) ?? ""
    }
}



// MARK: Reporting
extension NSError {
    
    /// Reports an error either to the user, to the error reporter, or both
    public func report(externally: Bool = true, alertUserFrom: UIViewController? = nil, onDismiss: (() -> ())? = nil) {
     
        if externally == true {
            ErrorReporter.sharedErrorReporter.reportError(self)
        }
        
        guard let viewController = alertUserFrom else { return }
        
        let alert: UIAlertController
        
        if externally == true {
            let title = NSLocalizedString("Error", bundle: .soLazy(), comment: "Title for an error alert")
            let messageTemplate = NSLocalizedString("An unexpected error occured. %@(%@)", bundle: .soLazy(), comment: "Message for an error alert")
            let message = String.localizedStringWithFormat(messageTemplate, self.domain, String(self.code))
            alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        }
        else {
            let reason = localizedFailureReason.map( { NSLocalizedString("\n\nExplanation: ", tableName: nil, bundle: .soLazy(), value: "", comment: "attached to error explanation in dialog") + $0 } ) ?? ""
            let description = localizedDescription + reason
            
            alert = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        }
        
        let dismissTitle = NSLocalizedString("Dismiss", tableName: nil, bundle: .soLazy(), value: "", comment: "Dismiss an error dialog")
        let action = UIAlertAction(title: dismissTitle, style: .Default) { _ in
            onDismiss?()
        }
        alert.addAction(action)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: Alert

extension NSError {
    public func presentAlertFromViewController(viewController: UIViewController, alertDismissed: (()->())? = nil, reportError: (()->())? = nil) {
        print(self.reportDescription)
        
        let reason = localizedFailureReason.map( { NSLocalizedString("\n\nExplanation: ", tableName: nil, bundle: .soLazy(), value: "", comment: "attached to error explanation in dialog") + $0 } ) ?? ""
        let description = localizedDescription + reason
        
        let alert = UIAlertController(title: title, message: description, preferredStyle: .Alert)
        
        if let report = reportError {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Report", tableName: nil, bundle: .soLazy(), value: "", comment: "Option to report an error"), style: .Default, handler: { _ in
                report()
            }))
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", tableName: nil, bundle: .soLazy(), value: "", comment: "Dismiss an error dialog"), style: .Cancel, handler: { _ in
            alertDismissed?()
        }))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    public var reportDescription: String {
        var report = "===== Error Report \(domain)–\(code) =====\n"
        
        for (key, value) in userInfo {
            if key.isEqual(NSUnderlyingErrorKey) { continue } // handled separately
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
    
    public convenience init(jsonError: Marshal.Error, file: String = #file, line: UInt = #line) {
        let reason: String
        switch jsonError {
        case let .TypeMismatch(expected: expected, actual: actual):
            reason = "Expected \(expected) but found \(actual)"
        case let .TypeMismatchWithKey(key: key, expected: expected, actual: actual):
            reason = "Expected \(expected) but found \(actual) for key: \(key)"
        case .KeyNotFound(key: let key):
            reason = "Expected a value for \(key)"
        case .NullValue(key: let key):
            reason = "Unexpected null value for \(key)"
        }
        
        let errorDescription = NSLocalizedString("There was a problem interpreting a response from the server.", tableName: nil, bundle: .soLazy(), value: "", comment: "JSON Parsing error description")

        self.init(subdomain: "SoLazy", description: errorDescription, failureReason: reason)
    }
    
    public func addingInfo(file: String = #file, line: UInt = #line) -> NSError {
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
