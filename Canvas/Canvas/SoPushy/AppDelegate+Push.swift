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
import CanvasCore
import CanvasKeymaster

extension AppDelegate {
    func routeToPushNotificationPayloadURL(_ payload: [AnyHashable: Any]) {
        if let urlString: NSString = payload["html_url"] as! NSString? {
            let actualURLString: String = swappedPushBetaURLString((urlString as String)) ?? (urlString as String)
            if let notificationURL = URL(string: actualURLString) {
                self.openCanvasURL(notificationURL)
            }
        }
    }
    
    fileprivate func swappedPushBetaURLString(_ urlString: String) -> String? {
        if let baseURLString = CanvasKeymaster.the().currentClient?.baseURL?.absoluteString {
            if baseURLString.range(of: "beta") != nil { // if we are currently in beta, the payload's url doesn't have it (a known issue) so we need to swap it out
                let nonBetaBaseURLString = baseURLString.replacingOccurrences(of: ".beta", with: "")
                // Get each host, compare. If they are the same then we are good to add in the .beta to the url
                if let baseURLComponents = URLComponents(string: baseURLString), let nonBetaBaseURLComponents = URLComponents(string: nonBetaBaseURLString), var actualURLComponents = URLComponents(string: (urlString as String)) {
                    if let baseURLHost = baseURLComponents.host, let nonBetaBaseURLHost = nonBetaBaseURLComponents.host, let actualURLHost = actualURLComponents.host {
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
