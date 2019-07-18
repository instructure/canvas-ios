//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Dashboard", bundle: .student, comment: ""), image: .icon(.dashboard, .line), selectedImage: .icon(.dashboard, .solid))
        controller.tabBarItem.accessibilityIdentifier = "TabBar.dashboardTab"
        return navigation(for: controller)
    }()

    lazy var calendar: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .green
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Calendar", bundle: .student, comment: ""), image: .icon(.calendarMonth, .line), selectedImage: .icon(.calendarMonth, .solid))
        controller.tabBarItem.accessibilityIdentifier = "TabBar.calendarTab"
        return navigation(for: controller)
    }()

    lazy var todo: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .blue
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("To Do", bundle: .student, comment: ""), image: .icon(.todo), selectedImage: .icon(.todoSolid))
        controller.tabBarItem.accessibilityIdentifier = "TabBar.todoTab"
        return navigation(for: controller)
    }()

    lazy var notifications: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .yellow
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Notifications", bundle: .student, comment: ""), image: .icon(.alerts, .line), selectedImage: .icon(.alerts, .solid))
        controller.tabBarItem.accessibilityIdentifier = "TabBar.notificationsTab"
        return navigation(for: controller)
    }()

    lazy var inbox: UINavigationController = {
        let controller = UIViewController()
        controller.view.backgroundColor = .red
        controller.tabBarItem = UITabBarItem(title: NSLocalizedString("Inbox", bundle: .student, comment: ""), image: .icon(.email, .line), selectedImage: .icon(.email, .solid))
        controller.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
        return navigation(for: controller)
    }()

    private func navigation(for controller: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.useGlobalNavStyle()
        return nav
    }
}
