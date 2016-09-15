//
//  AppDelegate.swift
//  Annotations
//
//  Created by Ben Kraus on 8/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoAnnotated
import PSPDFKit
import Result

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        PSPDFKit.setLicenseKey("JKudHaZ9ZQjVi7IQ2Es0OJml8oRJZ7sukLFDH2b1VN01fj74H57xzgtSRZlm7VHCbTydbPZch5l8LKOvEMNTpdaZ6yu6g+MWqqoUXHXem+XUc+iyNWU45lXe+Ezaxt8f/ZDCSM94w5uGOl52j6w2Ptkp8B4ZNapoXiarusTgT3BlFSiI94cahzWYmq14qhL0eUJFU99G9zY19E0Jw2DcL4m6aBQqoh3CtKvGkMeXo9+E3IBdTKp4UW2f7xwMcrAyzaNfaEHx9fh7f5nxfV6qN5CU5/gOZIZwOLXmaozequ/VoM+03w88+i2RdSLdI6+0dX1cL4aynHo+82DO70ubGHBEJcKSOpVJqz8tRwtSmrbMqZDGIYbQodeX27CVVRfqcNOA40HAeIwlY5J2KCmaAILplkg0fE10kcKZ5F+FcRALi8xkBglmm0Zp9G23kr2")

        let navBar = UINavigationBar.appearance()
        let toolBar = UIToolbar.appearance()
        let canvasBlue = UIColor(red: 14.0/255.0, green: 20.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        navBar.barTintColor = canvasBlue
        navBar.tintColor = UIColor.whiteColor()
        navBar.barStyle = .Black
        toolBar.barTintColor = canvasBlue
        toolBar.tintColor = UIColor.whiteColor()

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

