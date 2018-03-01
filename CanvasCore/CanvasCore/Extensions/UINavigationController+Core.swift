//
//  HelmNavigationController+Core.swift
//  CanvasCore
//
//  Created by Layne Moseley on 3/1/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

public extension UINavigationController {
    
    public func applyDefaultBranding() {
        self.navigationBar.barTintColor = Brand.current.navBgColor
        self.navigationBar.tintColor = Brand.current.navButtonColor
    }
}
