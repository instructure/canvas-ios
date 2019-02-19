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
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Dashboard", bundle: .student, comment: ""), image: .icon(.dashboard, .line), selectedImage: nil)
        controller.tabBarItem.accessibilityIdentifier = "Dashboard.tab"
        return navigation(for: controller)
    }()

    lazy var calendar: UINavigationController = {
        return placeholder(title: "Calendar", icon: .icon(.calendarMonth, .line), color: .green)
    }()

    lazy var todo: UINavigationController = {
        return placeholder(title: "To Do", icon: .icon(.todo), color: .blue)
    }()

    lazy var notifications: UINavigationController = {
        return placeholder(title: "Notifications", icon: .icon(.alerts, .line), color: .yellow)
    }()

    lazy var inbox: UINavigationController = {
        return placeholder(title: "Inbox", icon: .icon(.email, .line), color: .red)
    }()

    private func navigation(for controller: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.useGlobalNavStyle()
        return nav
    }

    private func placeholder(title: String, icon: UIImage, color: UIColor) -> UINavigationController {
        let controller = UIViewController()
        controller.view.backgroundColor = color
        controller.tabBarItem = UITabBarItem(title: title, image: icon, selectedImage: nil)
        return navigation(for: controller)
    }
}
