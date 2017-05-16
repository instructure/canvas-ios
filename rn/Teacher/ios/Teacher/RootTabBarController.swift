//
//  RootTabBarController.swift
//  Teacher
//
//  Created by Garrett Richards on 4/27/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    let branding: BrandingModel?
    
    init(branding: BrandingModel?) {
        self.branding = branding
        super.init(nibName: nil, bundle: nil)
        
        if let branding = branding {
            UITabBar.appearance().tintColor = branding.primaryBrandColor
            UITabBar.appearance().barTintColor = UIColor.white
        }
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
        enrollmentsVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: UIImage(named: "courses"), selectedImage: nil)
        return HelmNavigationController(rootViewController: enrollmentsVC)
        
//        let enrollmentsVC = HelmViewController(moduleName: "/", props: [:])
//        let split = HelmSplitViewController()
//        split.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: UIImage(named: "courses"), selectedImage: nil)
//        
//        let emptyNav = HelmNavigationController(rootViewController: EmptyViewController())
//        emptyNav.navigationBar.barTintColor = self.branding?.navBgColor
//        emptyNav.navigationBar.tintColor = self.branding?.navButtonColor
//        
//        split.viewControllers = [HelmNavigationController(rootViewController: enrollmentsVC), emptyNav]
//        split.preferredDisplayMode = .allVisible
//        return split
    }
    
    func inboxTab() -> UIViewController {
        let inboxVC = HelmViewController(moduleName: "/conversations", props: [:])
        inboxVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Inbox", comment: ""), image: UIImage(named: "inbox"), selectedImage: nil)
        return HelmNavigationController(rootViewController: inboxVC)
    }
    
    func profileTab() -> UIViewController {
        let profileVC = HelmViewController(moduleName: "/profile", props: [:])
        profileVC.tabBarItem = UITabBarItem(title: NSLocalizedString("Profile", comment: ""), image: UIImage(named: "profile"), selectedImage: nil)
        return HelmNavigationController(rootViewController: profileVC)
    }
    
    func stagingTab() -> UIViewController {
        let stagingVC = HelmViewController(moduleName: "/staging", props: [:])
        stagingVC.tabBarItem = UITabBarItem(title: "Staging", image: UIImage(named: "link-solid"), selectedImage: nil)
        return HelmNavigationController(rootViewController: stagingVC)
    }
}
