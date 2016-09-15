//
//  AppDelegate.swift
//  Enrollments
//
//  Created by Brandon Pluim on 1/15/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import SoPersistent
import TooLegit
import EnrollmentKit
import SoLazy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if unitTesting { return true }
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: IntroViewController(nibName: nil, bundle: nil))
        
        window?.makeKeyAndVisible()
        
        return true
    }
}


