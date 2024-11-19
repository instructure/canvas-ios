//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import UIKit

final class HorizonTabBarController: UITabBarController, UITabBarControllerDelegate {
    // MARK: - Properties

    private let horizonTabBar = HorizonTabBar()
    private let router = AppEnvironment.shared.router

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setValue(horizonTabBar, forKey: "tabBar")
        horizonTabBar.backgroundColor = .backgroundLightest

        viewControllers = [
            dashboardTab(),
            programsTab(),
            fakeTab(),
            careerTab(),
            inboxTab()
        ]
        tabBar.tintColor = .textDarkest
        UINavigationBar.appearance().tintColor = .textDarkest
        guard let tabBar = tabBar as? HorizonTabBar else { return }

        tabBar.didTapButton = { [weak self] in
            self?.presentChatBot()
        }
    }

    // MARK: - Functions

    private func presentChatBot() {
        let vc = CoreHostingController(AIAssembly.makeChatBotView())
        router.show(vc, from: self, options: .modal(isDismissable: false))
    }

    private func dashboardTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(DashboardAssembly.makeView())
        )
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .backgroundLight
        appearance.shadowImage = UIImage()
        appearance.shadowColor = nil

        vc.navigationBar.shadowImage = UIImage()
        vc.navigationBar.setBackgroundImage(UIImage(), for: .default)
        vc.navigationBar.standardAppearance = appearance
        vc.navigationBar.scrollEdgeAppearance = appearance

        vc.tabBarItem.title = String(localized: "Dashboard", bundle: .horizon)
        vc.tabBarItem.image = UIImage(systemName: "house")
        return vc
    }

    private func programsTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(ProgramsAssembly.makeProgramsView())
        )
        vc.tabBarItem.title = String(localized: "Learn", bundle: .horizon)
        vc.tabBarItem.image = UIImage(systemName: "list.bullet")
        return vc
    }

    private func fakeTab() -> UIViewController {
        .init()
    }

    private func careerTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(CareerAssembly.makeView())
        )
        vc.tabBarItem.title = String(localized: "Career", bundle: .horizon)
        vc.tabBarItem.image = UIImage(systemName: "point.bottomleft.filled.forward.to.point.topright.scurvepath")
        return vc
    }

    private func inboxTab() -> UIViewController {
        let inboxController: UIViewController
        let inboxSplit = CoreSplitViewController()

        inboxController = InboxAssembly.makeInboxViewController()

        let empty = CoreNavigationController()

        inboxSplit.viewControllers = [inboxController, empty]
        let title = "Inbox"
        inboxSplit.tabBarItem = UITabBarItem(title: title, image: .inboxTab, selectedImage: .inboxTabActive)
        inboxSplit.tabBarItem.accessibilityIdentifier = "TabBar.inboxTab"
//        inboxSplit.tabBarItem.makeUnavailableInOfflineMode()
        inboxSplit.extendedLayoutIncludesOpaqueBars = true
        TabBarBadgeCounts.messageItem = inboxSplit.tabBarItem
        return inboxSplit
    }
}

extension HorizonTabBarController {
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        if selectedIndex == 2 { return false }
        return true
    }
}
