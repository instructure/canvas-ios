 //////
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
import CoreData
import DoNotShipThis
import TooLegit
import PageKit
import SoLazy
import SoPersistent

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if unitTesting {
            return true
        }
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        // ID of course with no home page for testing: 1623595
        let contextID = ContextID(id: "24219", context: .Course)
        let navController = UINavigationController()
        let session = Session.ivy
        let detailVC = try! Page.DetailViewController(session: session, contextID: contextID, url: "links-to-things") {_, _ in }
        let viewModelFactory: (Session, Page) -> ColorfulViewModel = { session, page in
            Page.colorfulPageViewModel(session: session, page: page)
        }
        let list = try! Page.TableViewController(session: session, contextID: contextID, viewModelFactory: viewModelFactory) { _,_ in
            navController.pushViewController(detailVC, animated: true)
        }

        let route: (UIViewController, NSURL) -> () = { source, url in
            navController.pushViewController(list, animated: true)
        }

        let frontPage = try! PagesHomeViewController(session: session, contextID: contextID, listViewModelFactory: viewModelFactory,
            route: route)
        navController.viewControllers = [frontPage]
        navController.navigationBar.barTintColor = UIColor.colorFromHexString("0E1521")
        navController.navigationBar.tintColor = UIColor.whiteColor()
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
}

