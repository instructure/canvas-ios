//
//  UIViewController+Core.swift
//  CanvasCore
//
//  Created by Layne Moseley on 1/10/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

private var tagAssociationKey: UInt8 = 0

extension UIViewController {
    // This should be used with care
    // I added this because of weird stuff with the launch screen. You can't specify a custom class for it so there is no way to know what it is
    public var tag: String? {
        get {
            return objc_getAssociatedObject(self, &tagAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
