//
//  NSError+Categorization.swift
//  SoLazy
//
//  Created by Derrick Hathaway on 3/7/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

extension NSError {
    public var shouldRecordInCrashlytics: Bool {
        switch (domain, code) {
        case (NSCocoaErrorDomain, 13):  fallthrough // NSCocoaErrorDomain 13 NSUnderlyingException: error during SQL execution : database or disk is full
        case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):  fallthrough
        case (NSURLErrorDomain, NSURLErrorTimedOut):                fallthrough
        case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost):   fallthrough
        case (NSURLErrorDomain, NSURLErrorDataNotAllowed):
            return false
        default:
            return true
        }
    }
    
    public struct AlertDetails {
        public let title: String
        public let description: String
        public let actions: [UIAlertAction]
    }
    
    private var dismissAction: UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Dismiss", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "Dismiss button for error messages"), style: .default, handler: nil)
    }
    
    private func reportAction(action: @escaping (() -> ())) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Report", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "Button to report an error"), style: .default, handler: { _ in action() })
    }
    
    public func alertDetails(reportAction: (() -> ())? = nil) -> AlertDetails? {
        let networkErrorTitle = NSLocalizedString("Network Error", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "Error alert title for network error")
        let reportOrDismiss: [UIAlertAction]
        if let report = reportAction.map({ self.reportAction(action: $0)}) {
            reportOrDismiss = [report, dismissAction]
        } else {
            reportOrDismiss = [dismissAction]
        }
        
        let justDismiss = [dismissAction]
        
        switch (domain, code) {
        case (NSCocoaErrorDomain, 13): // NSCocoaErrorDomain 13 NSUnderlyingException: error during SQL execution : database or disk is full
            let title = NSLocalizedString("Disk Error", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "Error title to alert user their device is out of storage space")
            let description = NSLocalizedString("Your device is out of storage space. Please free up space and try again.", comment: "Error description for file out of space")
            
            return AlertDetails(title: title, description: description, actions: justDismiss)
            
        case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):  fallthrough
        case (NSURLErrorDomain, NSURLErrorTimedOut):                fallthrough
        case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost):   fallthrough
        case (NSURLErrorDomain, NSURLErrorDataNotAllowed):
            let description = NSLocalizedString("\(localizedDescription)\n\nCheck your connection or applicable carrier data limits and try again.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "Error description for network errors resulting from limited or no internet connection. Includes a localized error message from the system e.g. (The request timed out.)")
            
            return AlertDetails(title: networkErrorTitle, description: description, actions: justDismiss)
            
        case (NSURLErrorDomain, NSURLErrorServerCertificateUntrusted):
            return AlertDetails(title: networkErrorTitle, description: localizedDescription, actions: reportOrDismiss)
            
        case ("com.instructure.canvas", 90211): // push channel error. no idea where 90211 comes from.
            let title = NSLocalizedString("Notification Error", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "Error title for push notification registration error")
            let description = NSLocalizedString("There was a problem registering your device for push notifications.", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "Error description for Push Notifications registration error.")
            
            return AlertDetails(title: title, description: description, actions: reportOrDismiss)
            
        default:
            if let description = userInfo[NSLocalizedDescriptionKey] as? String, description != "" {
                let title = NSLocalizedString("Unknown Error", tableName: "Localizable", bundle: Bundle(identifier: "com.instructure.icanvas.SoLazy")!, comment: "An unknown error title")
                return AlertDetails(title: title, description: description, actions: reportOrDismiss)
            }
            
            return nil
        }
    }
}
