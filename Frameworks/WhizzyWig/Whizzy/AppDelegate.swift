//
//  AppDelegate.swift
//  Whizzy
//
//  Created by Derrick Hathaway on 6/10/15.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        
        let root = WhizzyCarsViewController()
        
        window?.rootViewController = UINavigationController(rootViewController: root)
        
        window?.makeKeyAndVisible()
        
        return true
    }
}
