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

class RootViewController: UITabBarController {
    static func create() -> RootViewController {
        let controller = RootViewController()
        controller.viewControllers = [
            controller.dashboard,
            controller.calendar,
            controller.todo,
            controller.notifications,
            controller.inbox,
        ]
        controller.tabBar.useGlobalNavStyle()
        return controller
    }

    lazy var dashboard: UINavigationController = {
        let controller = DashboardViewController.create()
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Dashboard", bundle: .student, comment: ""), image: .icon(.dashboard, .line), selectedImage: .icon(.dashboardCustomSolid))
        controller.tabBarItem.accessibilityIdentifier = "Dashboard.tab"
        return navigation(for: controller)
    }()

    lazy var calendar: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .green
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Calendar", bundle: .student, comment: ""), image: .icon(.calendarMonth, .line), selectedImage: .icon(.calendarMonth, .solid))
        return navigation(for: controller)
    }()

    lazy var todo: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .blue
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("To Do", bundle: .student, comment: ""), image: .icon(.todo), selectedImage: .icon(.todoSolid))
        return navigation(for: controller)
    }()

    lazy var notifications: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .yellow
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Notifications", bundle: .student, comment: ""), image: .icon(.alerts, .line), selectedImage: .icon(.alerts, .solid))
        return navigation(for: controller)
    }()

    lazy var inbox: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .red
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Inbox", bundle: .student, comment: ""), image: .icon(.email, .line), selectedImage: .icon(.email, .solid))
        return navigation(for: controller)
    }()

    private func navigation(for controller: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.useGlobalNavStyle()
        return nav
    }
}
