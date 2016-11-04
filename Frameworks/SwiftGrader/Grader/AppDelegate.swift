//
//  AppDelegate.swift
//  Grader
//
//  Created by Derrick Hathaway on 10/12/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import DoNotShipThis
import TooLegit
import SoPretty
import SoIconic

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let vc = try! AssignmentsTableViewController(session: Session.ivy, courseID: "968776")
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        beautify()
        
        return true
    }
    
    
    func beautify() {
        prettyBlue.apply(window!)
    }
}

let tintColor = UIColor(red: 0.0, green: 150/255.0, blue: 1.0, alpha: 1.0)
let prettyBlue = Brand(
    tintColor: tintColor,
    secondaryTintColor: tintColor,
    navBarTintColor: tintColor,
    navForegroundColor: .whiteColor(),
    tabBarTintColor: .whiteColor(),
    tabsForegroundColor: tintColor,
    logo: .icon(.course, filled: true)
)
