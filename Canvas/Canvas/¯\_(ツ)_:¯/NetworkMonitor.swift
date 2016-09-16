//
//  NetworkMonitor.swift
//  Canvas
//
//  Created by Derrick Hathaway on 5/26/16.
//  Copyright © 2016 Instructure. All rights reserved.
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