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

import SoPersistent
import TooLegit
import CalendarKit
import SoLazy
import DoNotShipThis
import CoreLocation
import Photos
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if unitTesting {
            return true
        }

        window = UIWindow(frame: UIScreen.main.bounds)

        let session = Session.parentTest
        print(session.user.name)
        
        let calendar = Foundation.Calendar.current
        var startDateComponents = DateComponents()
        startDateComponents.calendar = calendar
        startDateComponents.day = 15
        startDateComponents.month = 3
        startDateComponents.year = 2016
        
        var endDateComponents = DateComponents()
        endDateComponents.calendar = calendar
        endDateComponents.day = 16
        endDateComponents.month = 3
        endDateComponents.year = 2016
        
//        let startDate = calendar.dateFromComponents(startDateComponents) ?? Date()
//        let endDate = calendar.dateFromComponents(endDateComponents) ?? Date()
//
//        let calEventVC = try!  CalendarEventList(session: session, startDate: startDate, endDate: endDate, contextCodes: ["course_1"])
//        let calEventVC = try!  CalendarEventObserveeList(session: session, observeeID: "14", startDate: startDate, endDate: endDate, contextCodes: ["course_1"])
//
//        let calendarVC = CalendarMonthViewController.new(session)
//        window?.rootViewController = UINavigationController(rootViewController: calendarVC)

        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()

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
