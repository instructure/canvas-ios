//
//  AppDelegate+Routes.swift
//  Teacher
//
//  Created by Derrick Hathaway on 10/3/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import CanvasCore

extension AppDelegate {
    func registerNativeRoutes() {
        HelmManager.shared.registerNativeViewController(for: "/courses/:courseID", factory: { props in
            let split = EnrollmentSplitViewController()
            
            let master = HelmViewController(moduleName: "/courses/:courseID", props: props)
            let masterNav = HelmNavigationController()
            masterNav.viewControllers = [EmptyViewController(), master]
            masterNav.view.backgroundColor = .white
            masterNav.delegate = split
            masterNav.interactivePopGestureRecognizer?.isEnabled = false
            
            let emptyNav = HelmNavigationController(rootViewController: EmptyViewController())
            
            split.viewControllers = [masterNav, emptyNav]
            split.view.accessibilityIdentifier = "favorited-course-list.view"
            split.tabBarItem = UITabBarItem(title: NSLocalizedString("Courses", comment: ""), image: UIImage(named: "courses"), selectedImage: nil)
            split.tabBarItem.accessibilityIdentifier = "tab-bar.courses-btn"
            
            return split
        }, withCustomPresentation: { (current, new) in
            guard let tabVC = current.tabBarController else { return }
            var vcs = tabVC.viewControllers ?? []
            vcs[0] = new
            
            let snapshot = tabVC.view.snapshotView(afterScreenUpdates: true)!
            let tabVCView = tabVC.view
            let prevCenter = tabVC.view.center
            let window = UIApplication.shared.delegate!.window!
            
            if let tabVCView = tabVCView {
                tabVCView.center = CGPoint(x: tabVCView.center.x + tabVCView.frame.size.width + 20 /* who knows why */, y: tabVCView.center.y)
                window?.insertSubview(snapshot, belowSubview: tabVC.view)
                
                UIView.animate(withDuration: 0.3, animations: {
                    tabVC.setViewControllers(vcs, animated: false)
                    tabVCView.center = prevCenter
                    snapshot.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: { _ in
                    snapshot.removeFromSuperview()
                })
            }
        })
        HelmManager.shared.registerNativeViewController(for: "/attendance", factory: { props in
            guard
                let destinationURL = (props["launchURL"] as? String).flatMap(URL.init(string:)),
                let courseName = props["courseName"] as? String,
                let courseID = props["courseID"] as? String,
                let courseColor = props["courseColor"].flatMap(RCTConvert.uiColor)
                else { return nil }
            
            return TeacherAttendanceViewController(
                courseName: courseName,
                courseColor: courseColor,
                launchURL: destinationURL,
                courseID: courseID,
                date: Date()
            )
        })
    }
}
