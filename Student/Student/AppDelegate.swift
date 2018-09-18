//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import Core

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, AppEnvironmentDelegate {
    var baseURL: String = "https://twilson.instructure.com/"
    var window: UIWindow?

    lazy var environment: AppEnvironment = {
        return AppEnvironment(router: router)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if CommandLine.arguments.contains("RouterDebug") {
            showRouterDebug()
            return true
        }

        // TODO: Remove this at some point
        do {
            let store = environment.database
            try store.clearAllRecords()
            print("Successfully emptied the data store")
        } catch {
            print("Error: Unable to clear data store", error)
        }

        // TODO: Pull the most recent entry out of the keychain instead
        // of showing login view every time
        window?.rootViewController = createLoginViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func showRouterDebug() {
        let tabController = UITabBarController()
        let router = RouterViewController()
        let splitView = UISplitViewController()
        let navigation = UINavigationController(rootViewController: router)
        splitView.viewControllers = [navigation]
        tabController.viewControllers = [splitView]
        window?.rootViewController = tabController
    }

    func createLoginViewController() -> LoginViewController {
        guard let url = URL(string: baseURL), let host = url.host else {
            fatalError()
        }

        let vc = LoginViewController(host: host)
        vc.delegate = self
        return vc
    }

    func createTabController() -> UITabBarController {
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

        return tabController
    }
}

extension AppDelegate: LoginViewControllerDelegate {
    func userDidLogin(authToken: String) {
        Keychain.currentSession = KeychainEntry(token: authToken, baseURL: baseURL)
        // TODO: Persist this keychain entry
        window?.rootViewController = createTabController()
    }
}
