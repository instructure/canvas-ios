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
import TooLegit
import AssignmentKit
import SoPersistent
import SoLazy
import DoNotShipThis
import Keymaster
import FileKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if unitTesting {
            return true
        }

        ErrorReporter.setErrorHandler { error, presentingVC in
            print(error.reportDescription)
            if let deets = error.alertDetails(reportAction: { print("Yo, Support! \(error.reportDescription)") }) {
                let alert = UIAlertController(title: deets.title, message: deets.description, preferredStyle: .alert)
                deets.actions.forEach(alert.addAction)
                presentingVC?.present(alert, animated: true, completion: nil)
            }
        }
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let courseID = "968776" // String Tricks for Dummies
//        let courseID: String = "24219" // Beginning iOS
//        let courseID: String = "1140383" // Advanced Lobster Tasting
//        let courseID: String = "1787647" // All Hands On Deck
//        let courseID: String = "1422605"
        
        let navigationController = UINavigationController()
        let session = Session.art
        // Keymaster.sharedInstance.addSession(session)
        let vc = try! AssignmentList(session: session, courseID: courseID)
        
        navigationController.viewControllers = [vc]
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible() 

        return true
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print("received local notification. Probably an assignment reminder. You can handle this later once you have a router")
        
        let alert = UIAlertView()
        alert.title = "Alert"
        alert.message = notification.alertBody
        alert.addButton(withTitle: "Dismiss")
        
        alert.show()
    }

}
