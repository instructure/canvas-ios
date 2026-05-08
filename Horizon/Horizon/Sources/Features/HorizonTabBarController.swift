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
import HorizonUI
import SwiftUI

public final class HorizonTabBarController: UITabBarController, UITabBarControllerDelegate {
    // MARK: - Properties

    private let router = AppEnvironment.shared.router

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        viewControllers = [
            dashboardTab(),
            learnTab(),
            skillspaceTab(),
            accountTab()
        ]
        tabBar.tintColor = .textDarkest
        UINavigationBar.appearance().tintColor = .textDarkest
        setupTabBarAccessibility()
    }

    private func setupTabBarAccessibility() {
        guard let items = tabBar.items else { return }
        let labels = HorizonTabBarType.allCases

        for (index, item) in items.enumerated() {
            guard index < labels.count else { continue }
            item.accessibilityLabel = labels[index].title
            item.accessibilityTraits = [.tabBar, .button]
        }
    }

    // MARK: - Functions

    private func dashboardTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(DashboardAssembly.makeView())
        )
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = UIColor(Color.huiColors.surface.pagePrimary)
        appearance.shadowImage = UIImage()
        appearance.shadowColor = nil

        vc.navigationBar.shadowImage = UIImage()
        vc.navigationBar.setBackgroundImage(UIImage(), for: .default)
        vc.navigationBar.standardAppearance = appearance
        vc.navigationBar.scrollEdgeAppearance = appearance

        vc.tabBarItem.title = HorizonTabBarType.dashboard.title
        vc.tabBarItem.image = HorizonTabBarType.dashboard.image
        vc.tabBarItem.selectedImage = HorizonTabBarType.dashboard.selectedImage
        return vc
    }

    private func learnTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: LearnAssembly.makeLearnView()
        )
        vc.tabBarItem.title = HorizonTabBarType.learn.title
        vc.tabBarItem.image = HorizonTabBarType.learn.image
        vc.tabBarItem.selectedImage = HorizonTabBarType.learn.selectedImage
        return vc
    }

    private func skillspaceTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: SkillSpaceAssembly.makeView()
        )
        vc.navigationBar.prefersLargeTitles = false
        vc.tabBarItem.title = HorizonTabBarType.skillspace.title
        vc.tabBarItem.image = HorizonTabBarType.skillspace.image
        vc.tabBarItem.selectedImage = HorizonTabBarType.skillspace.selectedImage
        return vc
    }

    private func accountTab() -> UIViewController {
        let vc = CoreNavigationController(
            rootViewController: CoreHostingController(AccountAssembly.makeView())
        )
        vc.tabBarItem.title = HorizonTabBarType.account.title
        vc.tabBarItem.image = HorizonTabBarType.account.image
        vc.tabBarItem.selectedImage = HorizonTabBarType.account.selectedImage
        return vc
    }
}
