//
//  AppDelegate.swift
//  Pretty
//
//  Created by Derrick Hathaway on 11/23/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: MainPrettyViewController())
        
        window?.makeKeyAndVisible()
        
        return true
    }
}

