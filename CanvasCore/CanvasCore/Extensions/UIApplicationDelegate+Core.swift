//
//  UIApplicationDelegate.swift
//  CanvasCore
//
//  Created by Layne Moseley on 1/12/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

extension UIApplicationDelegate {
    
    public var topViewController: UIViewController? {
        guard let window = self.window else { return nil }
        guard let rootViewController = window?.rootViewController else { return nil }
        var topViewControler = rootViewController
        while topViewControler.presentedViewController != nil {
            topViewControler = topViewControler.presentedViewController!
        }
        return topViewControler
    }
}
