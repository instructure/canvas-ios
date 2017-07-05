//
//  RootTabBarController.swift
//  Teacher
//
//  Created by Garrett Richards on 4/27/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
        inboxSplit.tabBarItem = UITabBarItem(title: NSLocalizedString("Inbox", comment: ""), image: UIImage(named: "inbox"), selectedImage: nil)
        inboxSplit.tabBarItem.accessibilityIdentifier = "tab-bar.inbox-btn"
        
        let empty = HelmNavigationController()
        if let brand = self.branding {
            empty.navigationBar.barTintColor = brand.navBgColor
            empty.navigationBar.tintColor = brand.navButtonColor
            empty.navigationBar.isTranslucent = false
        }
        inboxSplit.viewControllers = [inboxNav, empty]
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
        stagingVC.tabBarItem = UITabBarItem(title: "Staging", image: UIImage(named: "link-solid"), selectedImage: nil)
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
