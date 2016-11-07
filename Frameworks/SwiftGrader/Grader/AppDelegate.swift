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
