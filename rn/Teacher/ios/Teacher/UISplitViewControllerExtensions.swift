//
//  UISplitViewControllerExtensions.swift
//  Teacher
//
//  Created by Garrett Richards on 5/3/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

extension UISplitViewController {
    var masterNavigationController: HelmNavigationController? {
        get {
            if let navigationController = self.viewControllers.first as? HelmNavigationController {
                return navigationController
            }
            return nil
        }
    }

    var detailNavigationController: HelmNavigationController? {
        get {
            if let navigationController = self.viewControllers.last as? HelmNavigationController, self.viewControllers.count > 1 {
                return navigationController
            }
            return nil
        }
    }

    var masterTopViewController: HelmViewController? {
        get {
            if let navigationController = self.viewControllers.first as? HelmNavigationController {
                if let topViewController = navigationController.topMostViewController() as? HelmViewController {
                    return topViewController
                }
            }
            return nil
        }
    }

    var detailTopViewController: HelmViewController? {
        get {
            if let navigationController = self.viewControllers.last as? HelmNavigationController, self.viewControllers.count > 1 {
                if let topViewController = navigationController.topMostViewController() as? HelmViewController {
                 return topViewController
                }
            }
            return nil
        }
    }

    func sourceController(moduleName: String) -> HelmViewController? {
        if let detailTopViewController = detailTopViewController, detailTopViewController.moduleName == moduleName {
            return detailTopViewController
        }

        if let masterTopViewController = masterTopViewController, masterTopViewController.moduleName == moduleName {
            return masterTopViewController
        }
        return nil
    }

    @discardableResult
    func primeEmptyDetailNavigationController() -> HelmNavigationController {
        let navigationController = HelmNavigationController()
        self.showDetailViewController(navigationController, sender: nil)
        return navigationController
    }

    override open var description: String {
        get {
            return "displayMode: \(self.displayMode) master: \(masterTopViewController?.moduleName ?? "N/A") detail: \(detailTopViewController?.moduleName ?? "N/A") masterVC: \( masterNavigationController != nil ? String(describing: masterNavigationController.self) : "N/A") detailVC: \( detailNavigationController != nil ? String(describing: detailNavigationController.self) : "N/A")"
        }
    }
}
