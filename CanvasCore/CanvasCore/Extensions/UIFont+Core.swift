//
//  UIFont+Core.swift
//  CanvasCore
//
//  Created by Layne Moseley on 9/26/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

extension UIFont {
    open func noLargerThan(_ fontSize: CGFloat) -> UIFont {
        if self.pointSize > fontSize {
            return self.withSize(fontSize)
        }
        
        return self
    }
}
