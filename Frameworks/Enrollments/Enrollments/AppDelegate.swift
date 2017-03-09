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
import EnrollmentKit
import SoLazy
import CoreLocation
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if unitTesting { return true }
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: IntroViewController(nibName: nil, bundle: nil))
        
        window?.makeKeyAndVisible()
        
        ErrorReporter.setErrorHandler { error, presentingVC in
            print(error.reportDescription)
            if let deets = error.alertDetails(reportAction: { print("Yo, Support! \(error.reportDescription)") }) {
                let alert = UIAlertController(title: deets.title, message: deets.description, preferredStyle: .alert)
                deets.actions.forEach(alert.addAction)
                presentingVC?.present(alert, animated: true, completion: nil)
            }
        }
        
        return true
    }
}


