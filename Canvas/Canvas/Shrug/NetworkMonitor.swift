
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
import CanvasKit1
import Reachability
import SoPretty


class NetworkMonitor: NSObject {
    static func engage() {
        NSNotificationCenter.defaultCenter().addObserver(sharedMonitor, selector: #selector(networkActivityStarted), name: CKCanvasNetworkRequestStartedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(sharedMonitor, selector: #selector(networkActivityEnded), name: CKCanvasNetworkRequestFinishedNotification, object: nil)
        
    }
    
    private static let sharedMonitor = NetworkMonitor()
    
    private var inflightNetworkOps = 0
    
    func networkActivityStarted() {
        inflightNetworkOps += 1
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func networkActivityEnded() {
        inflightNetworkOps -= 1
        UIApplication.sharedApplication().networkActivityIndicatorVisible = inflightNetworkOps > 0
    }
    
    
    // MARK: Reachability
    private let toast = ToastManager()
    
    func monitorReachability() {
        Reachability.reachabilityForInternetConnection().stopNotifier()
        let reach = Reachability(hostName: "canvas.instructure.com")
        
        reach.reachableBlock = { _ in
            dispatch_async(dispatch_get_main_queue()) {
                self.toast.dismissNotification()
            }
        }
        reach.unreachableBlock = { _ in
            dispatch_async(dispatch_get_main_queue()) {
                let message = NSLocalizedString("Uh-oh! No Internet Connection", comment: "Notification over status bar that displays when not connected to the internet.")
                self.toast.statusBarToastFailure(message)
            }
        }
        
        reach.startNotifier()
    }
}