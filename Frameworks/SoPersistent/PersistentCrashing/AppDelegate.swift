//
//  AppDelegate.swift
//  PersistentCrashing
//
//  Created by Derrick Hathaway on 1/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
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

