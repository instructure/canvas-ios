
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
import SoSupportive
import TooLegit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)


        let user = SessionUser(id: "1",
                               name: "Brandon",
                               loginID: "bt",
                               sortableName: "Pluim, Brandon",
                               avatarURL: NSURL(string: "https://secure.gravatar.com/avatar/098f6bcd4621d373cade4e832627b4f6?s=50&d=https%3A%2F%2Fmobile-1-canvas.portal2.canvaslms.com%2Fimages%2Fmessages%2Favatar-50.png")!)
        let session = Session(baseURL: NSURL(string: "https://mobiledev.instructure.com")!,
                       user: user,
                       token: "1~JC6sxZ9lNeVJloM6TOhW3pKZUsHIVTA8qwyC3wFNs67ZFsKeaYnkOTtNfdpAeuWN")

        let vc = SupportTicketViewController.new(session, type: .FeatureRequest)
        let navController = UINavigationController(rootViewController: vc)
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

