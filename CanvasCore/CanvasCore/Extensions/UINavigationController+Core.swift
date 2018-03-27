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
    
    // Sets the barTintColor on self as well as a detail in a split view controller situation
    public func syncBarTintColor(_ color: UIColor?) {
        self.navigationBar.barTintColor = color
        syncStyles()
    }
    
    // Same as above but for tintColor
    public func syncTintColor(_ color: UIColor?) {
        self.navigationBar.tintColor = color
        syncStyles()
    }
    
    // Looks at what is in the master, if in split view, and applies what master has to detail
    public func syncStyles() {
        guard let svc = self.splitViewController else { return }
        guard let master = svc.masterNavigationController else { return }
        guard let detail = svc.detailNavigationController else { return }
        detail.navigationBar.barTintColor = master.navigationBar.barTintColor
        detail.navigationBar.tintColor = master.navigationBar.tintColor
        detail.navigationBar.titleTextAttributes = master.navigationBar.titleTextAttributes
        detail.navigationBar.shadowImage = master.navigationBar.shadowImage
        detail.navigationBar.isTranslucent = master.navigationBar.isTranslucent
        detail.navigationBar.barStyle = master.navigationBar.barStyle
    }
}
