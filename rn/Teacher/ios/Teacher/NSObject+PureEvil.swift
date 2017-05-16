//
//  NSObject+PureEvil.swift
//  Teacher
//
//  Created by Ben Kraus on 5/9/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation
import ObjectiveC

extension NSObject {
    public func getAssociatedObject<T>(_ key: UnsafeRawPointer) -> T? {
        guard let asT = objc_getAssociatedObject(self, key) as? T else {
            return nil
        }
        
        return asT
    }
    
    public func setAssociatedObject<T: AnyObject>(_ value: T?, forKey key: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN) {
        objc_setAssociatedObject(self, key, value, policy)
    }
}
