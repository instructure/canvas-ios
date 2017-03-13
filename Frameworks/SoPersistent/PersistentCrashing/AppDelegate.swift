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
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let loading = UIViewController()
        loading.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        window?.rootViewController = loading
        
        NSManagedObjectContext.mainContext.startWithValues { mainContext in
            self.window?.rootViewController = UINavigationController(rootViewController: FavoriteBagelsViewController(context: mainContext))
        }
        NSManagedObjectContext.loadMain()
        
        window?.makeKeyAndVisible()
        return true
    }
}

