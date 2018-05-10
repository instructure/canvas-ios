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
        return UIAlertAction(title: NSLocalizedString("Dismiss", tableName: "Localizable", bundle: .core, comment: "Dismiss button for error messages"), style: .default, handler: nil)
    }
    
    private func reportAction(action: @escaping (() -> ())) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Report", tableName: "Localizable", bundle: .core, comment: "Button to report an error"), style: .default, handler: { _ in action() })
    }
    
    public func alertDetails(reportAction: (() -> ())? = nil) -> AlertDetails? {
        let networkErrorTitle = NSLocalizedString("Network Error", tableName: "Localizable", bundle: .core, comment: "Error alert title for network error")
        let reportOrDismiss: [UIAlertAction]
        if let report = reportAction.map({ self.reportAction(action: $0)}) {
            reportOrDismiss = [report, dismissAction]
        } else {
            reportOrDismiss = [dismissAction]
        }
        
        let justDismiss = [dismissAction]
        
        switch (domain, code) {
        case (NSCocoaErrorDomain, 13): // NSCocoaErrorDomain 13 NSUnderlyingException: error during SQL execution : database or disk is full
            let title = NSLocalizedString("Disk Error", tableName: "Localizable", bundle: .core, comment: "Error title to alert user their device is out of storage space")
            let description = NSLocalizedString("Your device is out of storage space. Please free up space and try again.", comment: "Error description for file out of space")
            
            return AlertDetails(title: title, description: description, actions: justDismiss)
            
        case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):  fallthrough
        case (NSURLErrorDomain, NSURLErrorTimedOut):                fallthrough
        case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost):   fallthrough
        case (NSURLErrorDomain, NSURLErrorDataNotAllowed):
            // This error is now handled on the react native side
            return nil;
        case (NSURLErrorDomain, NSURLErrorServerCertificateUntrusted):
            return AlertDetails(title: networkErrorTitle, description: localizedDescription, actions: reportOrDismiss)
            
        case ("com.instructure.canvas", 90211): // push channel error. no idea where 90211 comes from.
            let title = NSLocalizedString("Notification Error", tableName: "Localizable", bundle: .core, comment: "Error title for push notification registration error")
            let description = NSLocalizedString("There was a problem registering your device for push notifications.", tableName: "Localizable", bundle: .core, comment: "Error description for Push Notifications registration error.")
            
            return AlertDetails(title: title, description: description, actions: reportOrDismiss)
            
        default:
            if var description = userInfo[NSLocalizedDescriptionKey] as? String, description != "" {
                
                if let reason = localizedFailureReason {
                    description += "\n\n" + reason
                }
                
                let title = NSLocalizedString("Unknown Error", tableName: "Localizable", bundle: .core, comment: "An unknown error title")
                return AlertDetails(title: title, description: description, actions: reportOrDismiss)
            }
            
            return nil
        }
    }
}
