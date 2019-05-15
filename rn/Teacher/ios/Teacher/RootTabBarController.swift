//
// Copyright (C) 2017-present Instructure, Inc.
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
import CanvasCore
import Core
import ReactiveSwift
import UserNotifications

class RootTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            StartupManager.shared.markStartupFinished()
        }

        NotificationKitController.registerForPushNotifications()
    }
    
    @objc func configureTabs() {
        viewControllers = [coursesTab(),  toDoTab(), inboxTab()]
        if FeatureFlags.featureFlagEnabled(.newStudentAssignmentView) {
            tabBar.useGlobalNavStyle()
        }
    }
    
    @objc func coursesTab() -> UIViewController {
        let split = EnrollmentSplitViewController()
        let emptyNav = HelmNavigationController(rootViewController: EmptyViewController())
        
        let enrollmentsVC = HelmViewController(moduleName: "/", props: [:])
        enrollmentsVC.view.accessibilityIdentifier = "favorited-course-list.view1"
        enrollmentsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: .icon(.courses), selectedImage: nil)
        enrollmentsVC.tabBarItem.accessibilityIdentifier = "tab-bar.courses-btn"
        enrollmentsVC.navigationItem.titleView = Brand.current.navBarTitleView()
        
        let masterNav = HelmNavigationController(rootViewController: enrollmentsVC)
        masterNav.view.backgroundColor = .white
        masterNav.delegate = split
        masterNav.applyDefaultBranding()
        emptyNav.applyDefaultBranding()
        split.viewControllers = [masterNav, emptyNav]
        split.view.accessibilityIdentifier = "favorited-course-list.view2"
        split.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: .icon(.courses), selectedImage: nil)
        split.tabBarItem.accessibilityIdentifier = "tab-bar.courses-btn"
        split.preferredDisplayMode = .allVisible
        return split
    }

    @objc func toDoTab() -> UIViewController {
        let toDoVC = HelmViewController(moduleName: "/to-do", props: [:])
        toDoVC.view.accessibilityIdentifier = "to-do-list.view"
        toDoVC.tabBarItem = UITabBarItem(title: NSLocalizedString("To Do", comment: ""), image: .icon(.todo), selectedImage: nil)
        toDoVC.tabBarItem.accessibilityIdentifier = "tab-bar.to-do-btn"
        toDoVC.tabBarItem.reactive.badgeValue <~ TabBarBadgeCounts.todoListCountString
        toDoVC.navigationItem.titleView = Brand.current.navBarTitleView()
        let navigation = HelmNavigationController(rootViewController: toDoVC)
        navigation.applyDefaultBranding()
        return navigation
    }
}

// UIKit has a bug, when using the custom transitioning apis. Ash Furrow filed this bug back in iOS 8 days:
// http://openradar.appspot.com/radar?id=5320103646199808
// This fixes that, yay!
extension RootTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NoAnimatedTransitioning()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        tabBarController.resetViewControllerIfSelected(viewController)
        return true
    }
}
