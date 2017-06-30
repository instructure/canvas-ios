//
//  UIViewControllerRotationExtensions.swift
//  Teacher
//
//  Created by Ben Kraus on 6/29/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? .all
    }
    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? true
    }
}

extension UITabBarController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
    override open var shouldAutorotate: Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}
