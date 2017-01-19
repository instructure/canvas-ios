//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit
import SoAnnotated
import PSPDFKit
import Result

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        PSPDFKit.setLicenseKey("JKudHaZ9ZQjVi7IQ2Es0OJml8oRJZ7sukLFDH2b1VN01fj74H57xzgtSRZlm7VHCbTydbPZch5l8LKOvEMNTpdaZ6yu6g+MWqqoUXHXem+XUc+iyNWU45lXe+Ezaxt8f/ZDCSM94w5uGOl52j6w2Ptkp8B4ZNapoXiarusTgT3BlFSiI94cahzWYmq14qhL0eUJFU99G9zY19E0Jw2DcL4m6aBQqoh3CtKvGkMeXo9+E3IBdTKp4UW2f7xwMcrAyzaNfaEHx9fh7f5nxfV6qN5CU5/gOZIZwOLXmaozequ/VoM+03w88+i2RdSLdI6+0dX1cL4aynHo+82DO70ubGHBEJcKSOpVJqz8tRwtSmrbMqZDGIYbQodeX27CVVRfqcNOA40HAeIwlY5J2KCmaAILplkg0fE10kcKZ5F+FcRALi8xkBglmm0Zp9G23kr2")

        let navBar = UINavigationBar.appearance()
        let toolBar = UIToolbar.appearance()
        let canvasBlue = UIColor(red: 14.0/255.0, green: 20.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        navBar.barTintColor = canvasBlue
        navBar.tintColor = UIColor.white
        navBar.barStyle = .black
        toolBar.barTintColor = canvasBlue
        toolBar.tintColor = UIColor.white

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

