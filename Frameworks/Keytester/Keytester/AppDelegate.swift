//
//  AppDelegate.swift
//  Keytester
//
//  Created by Brandon Pluim on 1/19/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import SoPersistent
import TooLegit
import Keymaster

let baseURL = NSURL(string: "https://mobile-1-canvas.portal2.canvaslms.com")!
let clientID = "10000000000002"
let clientSecret = "Zyy0dEKxtMFo4waksVsOaDpSH7WArAi8WtG72eg5ZjTjMtm3d55oZ8JnxjC0gFPB"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SelectDomainDataSource {

    var window: UIWindow?
    
    var logoImage: UIImage = UIImage(named: "keymaster_logo_image")!
    var mobileVerifyName: String = "iCanvas"
    var tintTopColor: UIColor = UIColor.blueColor()
    var tintBottomColor: UIColor = UIColor.greenColor()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        let loginVC = LoginViewController.new(baseURL: baseURL, clientID: clientID, clientSecret: clientSecret)
        loginVC.result = { result in
            print(result)
        }
        
        let navController = UINavigationController(rootViewController: loginVC)
        navController.navigationBarHidden = true
        window?.rootViewController = navController
        
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

