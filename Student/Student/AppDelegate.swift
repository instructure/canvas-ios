//
//  AppDelegate.swift
//  Student
//
//  Created by Layne Moseley on 8/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import UIKit
import Core

let router = Router()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, AppStateDelegate {
    lazy var appState: AppState = {
        
        router.addRoute("/detail") {
            return DetailViewController.create()
        }
        
        let appState = AppState(router: router)
        return appState
    }()

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print(appState)
        return true
    }
}
