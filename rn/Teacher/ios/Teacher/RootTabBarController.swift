//
// Copyright (C) 2016-present Instructure, Inc.
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

class RootTabBarController: UITabBarController {
    
    let branding: Brand?
    
    init(branding: Brand?) {
        self.branding = branding
        super.init(nibName: nil, bundle: nil)
        
        if let branding = branding {
            UITabBar.appearance().tintColor = branding.primaryBrandColor
            UITabBar.appearance().barTintColor = UIColor.white
            UITabBar.appearance().unselectedItemTintColor = UIColor(red: 115/255.0, green: 129/255.0, blue: 140/255.0, alpha: 1)
        }
        
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabs()
    }
    
    func configureTabs() {
        var controllers = [coursesTab(), inboxTab(), profileTab()]
        #if DEBUG
        controllers.append(stagingTab())
        #endif
        viewControllers = controllers
    }
    
    func coursesTab() -> UIViewController {
        let enrollmentsVC = HelmViewController(moduleName: "/", props: [:])
        enrollmentsVC.view.accessibilityIdentifier = "favorited-course-list.view"
        enrollmentsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: UIImage(named: "courses"), selectedImage: nil)
        enrollmentsVC.tabBarItem.accessibilityIdentifier = "tab-bar.courses-btn"
        return HelmNavigationController(rootViewController: enrollmentsVC)
    }
    
    func inboxTab() -> UIViewController {
        let inboxVC = HelmViewController(moduleName: "/conversations", props: [:])
        let inboxNav = HelmNavigationController(rootViewController: inboxVC)
        
        let inboxSplit = HelmSplitViewController()
        let empty = HelmNavigationController()
        if let brand = self.branding {
            empty.navigationBar.barTintColor = brand.navBgColor
            empty.navigationBar.tintColor = brand.navButtonColor
            empty.navigationBar.isTranslucent = false
        }
        inboxSplit.viewControllers = [inboxNav, empty]
        inboxSplit.tabBarItem = UITabBarItem(title: NSLocalizedString("Inbox", comment: ""), image: UIImage(named: "inbox"), selectedImage: nil)
        inboxSplit.tabBarItem.accessibilityIdentifier = "tab-bar.inbox-btn"
        inboxSplit.extendedLayoutIncludesOpaqueBars = true
        return inboxSplit
    }
    
    func profileTab() -> UIViewController {
        let profileVC = HelmViewController(moduleName: "/profile", props: [:])
        profileVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: ""), image: UIImage(named: "profile"), selectedImage: nil)
        profileVC.tabBarItem.accessibilityIdentifier = "tab-bar.profile-btn"
        return HelmNavigationController(rootViewController: profileVC)
    }
    
    func stagingTab() -> UIViewController {
        let stagingVC = HelmViewController(moduleName: "/staging", props: [:])
        stagingVC.tabBarItem = UITabBarItem(title: "Staging", image: UIImage(named: "link"), selectedImage: nil)
        stagingVC.tabBarItem.accessibilityIdentifier = "tab-bar.staging-btn"
        return HelmNavigationController(rootViewController: stagingVC)
    }
}

// UIKit has a bug, when using the custom transitioning apis. Ash Furrow filed this bug back in iOS 8 days:
// http://openradar.appspot.com/radar?id=5320103646199808
// This fixes that, yay!
extension RootTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return NoAnimatedTransitioning()
    }
}
