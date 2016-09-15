//
//  AppDelegate.swift
//  Parent
//
//  Created by Brandon Pluim on 1/7/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit

import TooLegit
import Keymaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Router.sharedInstance.addRoutes()
        guard let window = window else {
            fatalError("No Window?  The Sky is falling")
        }
        
        let user = TooLegit.User(id: "1", loginID: "test", name: "test", sortableName: "test", email: "test@test.com", avatarURL: NSURL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
        let session = Session(baseURL: NSURL(string: "https://mobile-1-canvas.portal2.canvaslms.com")!, user: user, token: "1~3NVQzNji8JZDHStv91GtBs6CIvNPsZ2Y94NXc2SDRo94qu2gScA6EtJ6LhH4eTC7")
        
        Keymaster.instance.updateMostRecentSession(session)
        
//        if let session = Keymaster.instance.mostRecentSession() {
            Keymaster.instance.currentSession = session
            Router.sharedInstance.session = session
            Router.sharedInstance.routeToLoggedInViewController(window)
//        } else {
//            Router.sharedInstance.routeToLoggedOutViewController(window)
//        }
        
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

