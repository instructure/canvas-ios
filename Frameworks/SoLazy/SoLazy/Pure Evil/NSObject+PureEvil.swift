//
//  NSObject+PureEvil.swift
//  SoLazy
//
//  Created by Derrick Hathaway on 2/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import ObjectiveC

extension NSObject {
    public func getAssociatedObject<T>(key: UnsafePointer<Void>) -> T? {
        guard let asT = objc_getAssociatedObject(self, key) as? T else {
            return nil
        }

        return asT
    }
    
    public func setAssociatedObject<T: AnyObject>(value: T?, forKey key: UnsafePointer<Void>, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN) {
        objc_setAssociatedObject(self, key, value, policy)
    }
}