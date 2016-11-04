
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
    
    

import UIKit
import Foundation
import NotificationKit
import TooLegit
import CanvasKeymaster
import SoLazy

// TODO: Due to an error that occurs in Swift 1.2 and Xcode 6.3 it is not possible to
// create an extension that implements UIApplicationDelegate.  As a workaround the methods
// of the UIApplicationDelegate that pertain to push are calling the same method
// name here with a _swift appended to the name of the method.  When this issue
// no longer exists OR when the app delegate gets rewritten in swift the _swift
// appending methods are no longer necessary and can replace the similarly named
// methods in the app delegate

extension AppDelegate {
    
    // MARK: Handle Registration Callbacks
    func didRegisterForRemoteNotifications(deviceToken: NSData) {
        
        // TODO: figure out how this was being called before the user was logged in (it shouldn't be) this will keep it from crashing in the mean time
        if let client = CanvasKeymaster.theKeymaster().currentClient {
            
            let session = client.authSession
            let controller = NotificationKitController(session: session)
            controller.registerPushNotificationTokenWithPushService(deviceToken, registrationCompletion: { (result) -> () in
                switch result {
                case .Success():
                    // TODO: tally this event to get a feel for how many users are using push
                    print("Success")
                case .Error(let error):
                    self.handleError(error.addingInfo())
                    print("Error: \(error) + error localized: \(error.localizedDescription)")
                }
            })
        }
    }
    
    func didFailToRegisterForRemoteNotifications(error: NSError) {
        handleError(error.addingInfo())
    }
    
    
    // MARK: Handle Remote Notification
    func app(app: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if app.applicationState == .Inactive {
            routeToPushNotificationPayloadURL(userInfo)
        } else {
            handlePushNotificationPayload(userInfo)
        }
    }
    
    func handlePushNotificationPayload(payload: NSDictionary) {
        // TODO: Should be verifying the user id that the notification is for as well as the user who is currently logged in
        // TODO: May need the user to log in before attempting to show the notification
        // TODO: What should we do when the item we're attempting to show no longer exists?  (should probably be handled in the router make sure that it is handled correctly)
        if let message = ((payload["aps"] as? NSDictionary)?["alert"]) as? String {
            let alertController = UIAlertController(title: NSLocalizedString("Notification", comment: ""), message: message, preferredStyle: .Alert)
            if let urlString: NSString = payload["html_url"] as! NSString? {
                let actualURLString: String = swappedPushBetaURLString((urlString as String)) ?? (urlString as String)
                if let notificationURL = NSURL(string: actualURLString) {
                    let laterAction = UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .Cancel) { _ in }
                    alertController.addAction(laterAction)
                    let viewAction = UIAlertAction(title: NSLocalizedString("View", comment: ""), style: .Default) { _ in
                        self.openCanvasURL(notificationURL)
                    }
                    alertController.addAction(viewAction)
                } else {
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel) { _ in }
                    alertController.addAction(okAction)
                }
            } else {
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel) { _ in }
                alertController.addAction(okAction)
            }
            visibleController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func routeToPushNotificationPayloadURL(payload: [NSObject: AnyObject]) {
        if let urlString: NSString = payload["html_url"] as! NSString? {
            let actualURLString: String = swappedPushBetaURLString((urlString as String)) ?? (urlString as String)
            if let notificationURL = NSURL(string: actualURLString) {
                
                self.openCanvasURL(notificationURL)
            }
        }
    }
    
    private func swappedPushBetaURLString(urlString: String) -> String? {
        if let baseURL = CanvasKeymaster.theKeymaster().currentClient.baseURL, let baseURLString = baseURL.absoluteString {
            if baseURLString.rangeOfString("beta") != nil { // if we are currently in beta, the payload's url doesn't have it (a known issue) so we need to swap it out
                let nonBetaBaseURLString = baseURLString.stringByReplacingOccurrencesOfString(".beta", withString: "")
                // Get each host, compare. If they are the same then we are good to add in the .beta to the url
                if let baseURLComponents = NSURLComponents(string: baseURLString), nonBetaBaseURLComponents = NSURLComponents(string: nonBetaBaseURLString), actualURLComponents = NSURLComponents(string: (urlString as String)) {
                    if let baseURLHost = baseURLComponents.host, nonBetaBaseURLHost = nonBetaBaseURLComponents.host, actualURLHost = actualURLComponents.host {
                        if nonBetaBaseURLHost == actualURLHost { // if the stripped "beta" stripped base url == the url given in the push, do the swap with the one containing the "beta"
                            actualURLComponents.host = baseURLHost
                            return actualURLComponents.string
                        }
                    }
                }
            }
        }
        return nil
    }
}
