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
        router.addRoute("/courses/:courseID/users/:userID") {_ in
            return DetailViewController.create()
        }

        router.addRoute("/login") { _ in
            return LoginViewController(host: "twilson.instructure.com")
        }

        router.addRoute("/allcourses") { _ in
            return AllCoursesViewController.create()
        }

        let appState = AppState(router: router)
        return appState
    }()

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        print(appState)

        window = UIWindow(frame: UIScreen.main.bounds)
//        let presenter = DashboardPresenter.create()
//        let nav = UINavigationController(rootViewController: presenter)
//        nav.navigationBar.isTranslucent = false
//        nav.navigationBar.barStyle = .black
//        nav.navigationBar.barTintColor = .black
//        nav.navigationBar.tintColor = .white
//        window?.rootViewController = nav

        let vc1 = DashboardViewController.create()
        vc1.title = "Dashboard"
        vc1.tabBarItem = UITabBarItem(title: "Dashboard", image: nil, selectedImage: nil)
        vc1.tabBarItem.accessibilityLabel = "Dashboard_tab"

        let vc2 = UIViewController()
        vc2.view.backgroundColor = .green
        vc2.title = "Calendar"
        vc2.tabBarItem = UITabBarItem(title: "Calendar", image: nil, selectedImage: nil)
        vc2.tabBarItem.accessibilityLabel = "Calendar_tab"

        let vc3 = UIViewController()
        vc3.view.backgroundColor = .blue
        vc3.title = "To Do"
        vc3.tabBarItem = UITabBarItem(title: "To Do", image: nil, selectedImage: nil)
        vc3.tabBarItem.accessibilityLabel = "To Do_tab"

        let vc4 = UIViewController()
        vc4.view.backgroundColor = .yellow
        vc4.title = "Notifications"
        vc4.tabBarItem = UITabBarItem(title: "Notifications", image: nil, selectedImage: nil)
        vc4.tabBarItem.accessibilityLabel = "Notifications_tab"

        let vc5 = UIViewController()
        vc5.view.backgroundColor = .red
        vc5.title = "Inbox"
        vc5.tabBarItem = UITabBarItem(title: "Inbox", image: nil, selectedImage: nil)
        vc5.tabBarItem.accessibilityLabel = "Inbox_tab"

        let tabController = UITabBarController()
        tabController.tabBar.tintColor = .red
        tabController.viewControllers = [vc1, vc2, vc3, vc4, vc5].map { vc in
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            nav.navigationBar.barStyle = .black
            nav.navigationBar.barTintColor = .black
            nav.navigationBar.tintColor = .white
            return nav
        }

        window?.rootViewController = tabController

        return true
    }
}
